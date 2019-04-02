import Darwin
import IOKit
import IOKit.usb
import Foundation

func lockScreenImmediate() -> Void {
    let libHandle = dlopen("/System/Library/PrivateFrameworks/login.framework/Versions/Current/login", RTLD_LAZY)
    let sym = dlsym(libHandle, "SACLockScreenImmediate")
    typealias myFunction = @convention(c) () -> Void
    let SACLockScreenImmediate = unsafeBitCast(sym, to: myFunction.self)
    SACLockScreenImmediate()
}

class Notifier {
    let callbackQueue: DispatchQueue = DispatchQueue.global()
  
    func dispatchEvent (iterator: io_iterator_t) {
        repeat {
            let next = IOIteratorNext(iterator)
            guard next != 0 else { break }
            self.callbackQueue.async {
                lockScreenImmediate()
                IOObjectRelease(next)
            }
        } while (true)
    }
}

let notifier = Notifier()
let notifierPtr = Unmanaged.passUnretained(notifier).toOpaque()
var iterator: io_iterator_t = 0

let internalQueue: DispatchQueue = DispatchQueue(label: "IODetector")
let notifyPort: IONotificationPortRef = IONotificationPortCreate(kIOMasterPortDefault)
IONotificationPortSetDispatchQueue(notifyPort, internalQueue)
    
let matchingDict = IOServiceMatching(kIOUSBDeviceClassName) as NSMutableDictionary
matchingDict[kUSBVendorID] = 0x1050
matchingDict[kUSBProductID] = "*"

let cb: IOServiceMatchingCallback = { (userData, iterator) in notifier.dispatchEvent(iterator: iterator) };
let error = IOServiceAddMatchingNotification(notifyPort, kIOTerminatedNotification, matchingDict, cb, notifierPtr, &iterator)
guard error == 0 else {
    if iterator != 0 {
        IOObjectRelease(iterator)
        iterator = 0
    }
    exit(1)
}

notifier.dispatchEvent(iterator: iterator)

signal(SIGINT) {
    s in
    if iterator != 0 {
        IOObjectRelease(iterator)
        iterator = 0
    }
    exit(1)
}

CFRunLoopRun()

IOObjectRelease(iterator)
iterator = 0

