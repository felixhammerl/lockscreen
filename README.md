# lockscreen

Listens to your yubikey being removed and locks your mac.

## Get started

Run `./install.sh` in the project root for the guided setup. Or execute the steps manually. I'm not your supervisor.

## launchd 101

* Loading a job: `launchctl load ~/Library/LaunchAgents/com.felixhammerl.lockscreen.plist`
* Unloading a job: `launchctl unload ~/Library/LaunchAgents/com.felixhammerl.lockscreen.plist`
* Starting a job: `launchctl start com.felixhammerl.lockscreen`
* Stopping a job: `launchctl stop com.felixhammerl.lockscreen`

For further information on launchd, please see the following docs:

* [launchd.info](http://www.launchd.info/)
* [Apple Documentation](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html)

