# lockscreen

## What this does

Listens to your Yubikey being removed and locks your mac.

Installs a LaunchAgent for your user that will listen to the Yubikey being removed and call a non-public Apple API to lock your screen. Don't even think about putting this into the AppStore, it will *never* be approved b/c of the internal API.

## How to get started

`make`          →  Compile lockscreen binary

`make install`  →  Install lockscreen and load LaunchAgent

`make remove`   →  Remove lockscreen binary and LaunchAgent
