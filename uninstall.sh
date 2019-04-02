#!/usr/bin/env bash
# shellcheck disable=1090

cd "$(dirname "$0")" || exit 1

PLIST_FILE="com.felixhammerl.lockscreen.plist"
AGENT_NAME="com.felixhammerl.lockscreen"
AGENTS_FOLDER="$HOME/Library/LaunchAgents"
LOCKSCREEN_BINARY="lockscreen"

echo "Terminating active agents..."
PROCESS_RUNNING=$(launchctl list | grep -c "$AGENT_NAME")
if [ $PROCESS_RUNNING != 0 ]; then
  echo "Found $PROCESS_RUNNING agents ..."
	launchctl stop "$AGENT_NAME"
	launchctl unload "$AGENTS_FOLDER/$PLIST_FILE"
  echo "Done."
else
  echo "No agents found."
fi

echo "Removing binary..."
rm "/usr/local/bin/$LOCKSCREEN_BINARY"
echo "Done."
