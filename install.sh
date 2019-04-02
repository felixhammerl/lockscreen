#!/usr/bin/env bash
# shellcheck disable=1090

cd "$(dirname "$0")" || exit 1

LOCKSCREEN_BINARY="lockscreen"
LOCKSCREEN_SOURCE="lockscreen.swift"
PLIST_FILE="com.felixhammerl.lockscreen.plist"
AGENT_NAME="com.felixhammerl.lockscreen"
AGENTS_FOLDER="$HOME/Library/LaunchAgents"

echo "Configuring the lockscreen agent..."

if [ ! -f "/usr/local/bin/$LOCKSCREEN_BINARY" ]; then
	echo "Compiling binary..."
	swiftc "$LOCKSCREEN_SOURCE"
	echo "Moving to /usr/local/bin ..."
  mv "$LOCKSCREEN_BINARY" /usr/local/bin
	echo "Done."
fi

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

echo "Starting the agent..."
cp "$PLIST_FILE" "$AGENTS_FOLDER/$PLIST_FILE"
launchctl load "$AGENTS_FOLDER/$PLIST_FILE"
echo "Done."
