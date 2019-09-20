SHELL = /bin/bash

LOCKSCREEN_BINARY := "lockscreen"
LOCKSCREEN_SOURCE := "lockscreen.swift"
PLIST_FILE := $(notdir $(shell find . -name "*.plist"))
AGENT_NAME := $(basename $(PLIST_FILE))
AGENTS_DIR := "$(HOME)/Library/LaunchAgents"
LOCKSCREEN_DEST := "/usr/local/bin"

lockscreen:
	@echo "Compiling $(LOCKSCREEN_BINARY) binary"; \
	/usr/bin/swiftc "$(LOCKSCREEN_SOURCE)"

install: lockscreen
	@echo "Moving $(LOCKSCREEN_BINARY) binary to $(LOCKSCREEN_DEST)"; \
	/bin/mv "$$(pwd)/$(LOCKSCREEN_BINARY)" "$(LOCKSCREEN_DEST)"
	@/bin/launchctl list | /usr/bin/grep -qw "$(AGENT_NAME)" \
		&& /bin/launchctl unload "$(AGENTS_DIR)/$(PLIST_FILE)" \
		|| :
	@echo "Copying $(PLIST_FILE) to $(AGENTS_DIR)"; \
	/bin/mkdir -p "$(AGENTS_DIR)"; \
	/bin/cp "$(PLIST_FILE)" "$(AGENTS_DIR)/$(PLIST_FILE)"
	@echo "Loading LaunchAgent $(AGENT_NAME)"; \
	/bin/launchctl load "$(AGENTS_DIR)/$(PLIST_FILE)"

remove:
	@echo "Removing $(LOCKSCREEN_BINARY) binary from $(LOCKSCREEN_DEST)"; \
	/bin/rm -f "$(LOCKSCREEN_DEST)/$(LOCKSCREEN_BINARY)"
	@/bin/launchctl list | /usr/bin/grep -qw "$(AGENT_NAME)" \
		&& echo "Unloading LaunchAgent $(AGENT_NAME)" \
		&& /bin/launchctl unload "$(AGENTS_DIR)/$(PLIST_FILE)" \
		|| :
	@echo "Removing $(PLIST_FILE) from $(AGENTS_DIR)"; \
	/bin/rm -f "$(AGENTS_DIR)/$(PLIST_FILE)"

