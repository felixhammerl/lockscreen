import Darwin
import IOKit
import IOKit.usb
import Foundation


class YubikeyDetector {
    
    enum Event {
        case Matched
        case Terminated
    }
    
    let vendorID: Int
    let productID: Int
    
    var callback: (
    ( _ detector: YubikeyDetector,  _ event: Event,
    _ service: io_service_t
    ) -> Void
    )?
    
    
    private
    let internalQueue: DispatchQueue

    private
    let callbackQueue: DispatchQueue
    
    private
    let notifyPort: IONotificationPortRef
    
    private
    var matchedIterator: io_iterator_t = 0
    
    private
    var terminatedIterator: io_iterator_t = 0
    
    init (yubikey: Yubikey) {
        self.vendorID = yubikey.vid
        self.productID = yubikey.pid
        self.internalQueue = DispatchQueue(label: "IODetector")
        self.callbackQueue = DispatchQueue.global()
        self.notifyPort = IONotificationPortCreate(kIOMasterPortDefault)
        IONotificationPortSetDispatchQueue(notifyPort, self.internalQueue)
    }
    
    deinit {
        self.stopDetection()
    }
    
    func startDetection ( ) -> Bool {
        guard matchedIterator == 0 else { return true }
        
        let matchingDict = IOServiceMatching(kIOUSBDeviceClassName) as NSMutableDictionary
        matchingDict[kUSBVendorID] = NSNumber(value: vendorID)
        matchingDict[kUSBProductID] = NSNumber(value: productID)
        
        let matchCallback: IOServiceMatchingCallback = {
            (userData, iterator) in
            let detector = Unmanaged<YubikeyDetector>
                .fromOpaque(userData!).takeUnretainedValue()
            detector.dispatchEvent(event: .Matched, iterator: iterator)
        };
        let termCallback: IOServiceMatchingCallback = {
            (userData, iterator) in
            let detector = Unmanaged<YubikeyDetector>
                .fromOpaque(userData!).takeUnretainedValue()
            detector.dispatchEvent(
                event: .Terminated, iterator: iterator
            )
        };
        
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        
        let addMatchError = IOServiceAddMatchingNotification(
            self.notifyPort, kIOFirstMatchNotification,
            matchingDict, matchCallback, selfPtr, &self.matchedIterator
        )
        let addTermError = IOServiceAddMatchingNotification(
            self.notifyPort, kIOTerminatedNotification,
            matchingDict, termCallback, selfPtr, &self.terminatedIterator
        )
        
        guard addMatchError == 0 && addTermError == 0 else {
            if self.matchedIterator != 0 {
                IOObjectRelease(self.matchedIterator)
                self.matchedIterator = 0
            }
            if self.terminatedIterator != 0 {
                IOObjectRelease(self.terminatedIterator)
                self.terminatedIterator = 0
            }
            return false
        }
        
        // This is required even if nothing was found to "arm" the callback
        self.dispatchEvent(event: .Matched, iterator: self.matchedIterator)
        self.dispatchEvent(event: .Terminated, iterator: self.terminatedIterator)
        
        return true
    }
    
    
    func stopDetection ( ) {
        guard self.matchedIterator != 0 else { return }
        IOObjectRelease(self.matchedIterator)
        IOObjectRelease(self.terminatedIterator)
        self.matchedIterator = 0
        self.terminatedIterator = 0
    }
    
    private
    func dispatchEvent (event: Event, iterator: io_iterator_t) {
        repeat {
            let nextService = IOIteratorNext(iterator)
            guard nextService != 0 else { break }
            if let cb = self.callback {
                self.callbackQueue.async {
                    cb(self, event, nextService)
                    IOObjectRelease(nextService)
                }
            } else {
                IOObjectRelease(nextService)
            }
        } while (true)
    }
}

func lockScreenImmediate() -> Void {
    let libHandle = dlopen("/System/Library/PrivateFrameworks/login.framework/Versions/Current/login", RTLD_LAZY)
    let sym = dlsym(libHandle, "SACLockScreenImmediate")
    typealias myFunction = @convention(c) () -> Void
    let SACLockScreenImmediate = unsafeBitCast(sym, to: myFunction.self)
    SACLockScreenImmediate()
}

struct Yubikey: Decodable {
    let vid: Int
    let pid: Int
}

var yubikey: Yubikey = Yubikey(vid: 0x1051, pid: 0x0407)
if let url = Bundle.main.url(forResource: "cfg", withExtension: "json") {
    do {
        let data = try Data(contentsOf: url)
        yubikey = try JSONDecoder().decode(Yubikey.self, from: data)
    } catch {
        print("error:\(error)")
    }
} else {
    print("No config file detected. Falling back to default.")
}

let detector = YubikeyDetector(yubikey: yubikey)
detector.callback = {
    (detector, event, service) in
        if event == YubikeyDetector.Event.Terminated {
            print("Yubikey removed.")
            lockScreenImmediate()
        }
}
_ = detector.startDetection()

while true { sleep(1) }
