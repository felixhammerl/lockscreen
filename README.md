# lockscreen

## What this does

Listens to your yubikey being removed and locks your mac.

Installs a `launchd` agent for your user that will listen to the yubiey being removed and call a non-public Apple API to lock your screen. Don't even think about putting this into the AppStore, it will *never* be approved b/c of the internal API.

## Get started

Run `./install.sh` in the project root for the guided setup. Or execute the steps manually. I'm not your supervisor.

Run `./uninstall.sh` to stop and remove the agent.

**NB**: You will have to configure the path in the plist, b/c `launchd` does not support globbing anymore. So `~/` is not available. PRs welcome for this problem :)

## launchd 101

* Loading a job: `launchctl load ~/Library/LaunchAgents/com.felixhammerl.lockscreen.plist`
* Unloading a job: `launchctl unload ~/Library/LaunchAgents/com.felixhammerl.lockscreen.plist`
* Starting a job: `launchctl start com.felixhammerl.lockscreen`
* Stopping a job: `launchctl stop com.felixhammerl.lockscreen`

For further information on launchd, please see the following docs:

* [launchd.info](http://www.launchd.info/)
* [Apple Documentation](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html)
