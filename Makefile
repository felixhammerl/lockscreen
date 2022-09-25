SHELL = /bin/bash

LOCKSCREEN_BINARY := "lockscreen"
LOCKSCREEN_SOURCE := "lockscreen.swift"
PLIST_FILE := $(notdir $(shell find . -name "*.plist"))
AGENT_NAME := $(basename $(PLIST_FILE))
AGENTS_DIR := "$(HOME)/Library/LaunchAgents"
LOCKSCREEN_DEST := "/opt/com.felixhammerl.lockscreen"

lockscreen:
	@echo "Compiling $(LOCKSCREEN_BINARY) binary ..."; \
	/usr/bin/swiftc "$(LOCKSCREEN_SOURCE)" 
	@echo "Done!"

install: lockscreen
	@echo "Checking if installation folder $(LOCKSCREEN_DEST) exists..."; \
	if [ -d "$(LOCKSCREEN_DEST)" ]; then \
		echo "Installation folder $(LOCKSCREEN_DEST) already exists."; \
		sudo chown -R ${USER} "$(LOCKSCREEN_DEST)"; \
	else \
		echo "Creating installation folder $(LOCKSCREEN_DEST) ..."; \
		sudo /bin/mkdir -p "$(LOCKSCREEN_DEST)"; \
		sudo chown -R ${USER} "$(LOCKSCREEN_DEST)"; \
	fi
	@echo "Moving $(LOCKSCREEN_BINARY) binary to $(LOCKSCREEN_DEST) ..."; \
	/bin/mv "$$(pwd)/$(LOCKSCREEN_BINARY)" "$(LOCKSCREEN_DEST)/$(LOCKSCREEN_BINARY)"
	@/bin/launchctl list | /usr/bin/grep -qw "$(AGENT_NAME)" \
		&& /bin/launchctl unload "$(AGENTS_DIR)/$(PLIST_FILE)" \
		|| :
	@echo "Copying $(PLIST_FILE) to $(AGENTS_DIR) ..."; \
	/bin/mkdir -p "$(AGENTS_DIR)"; \
	/bin/cp "$(PLIST_FILE)" "$(AGENTS_DIR)/$(PLIST_FILE)"
	@echo "Loading LaunchAgent $(AGENT_NAME) ..."; \
	/bin/launchctl load "$(AGENTS_DIR)/$(PLIST_FILE)"
	@echo "Done!"

remove:
	@echo "Removing $(LOCKSCREEN_BINARY) ..."; \
	sudo /bin/rm -rf "$(LOCKSCREEN_DEST)"
	@/bin/launchctl list | /usr/bin/grep -qw "$(AGENT_NAME)" \
		&& echo "Unloading LaunchAgent $(AGENT_NAME) ..." \
		&& /bin/launchctl unload "$(AGENTS_DIR)/$(PLIST_FILE)" \
		|| :
	@echo "Removing $(PLIST_FILE) from $(AGENTS_DIR) ..."; \
	/bin/rm -f "$(AGENTS_DIR)/$(PLIST_FILE)"
	@echo "Done!"

