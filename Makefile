# Makefile for hybrid Rust (binary) + Swift (dylib) project
# Usage:
#   make          # build swift dylib + rust binary
#   make run      # run with DYLD_LIBRARY_PATH set
#   make swift    # build only the swift dylib
#   make rust     # build only the rust binary
#   make clean    # clean outputs
#
# You can override the deployment target:
#   make MACOSX_DEPLOYMENT_TARGET=13.0
#
# If you need explicit archs later, pass -target to SWIFT_EXTRA_FLAGS
#   make SWIFT_EXTRA_FLAGS="-target arm64-apple-macos12.0"

APP_NAME := notcher
SWIFT_SRCS := macos/Panel.swift macos/NotchHelper.swift
DYLIB := macos/libNotchHelper.dylib

# Reasonable default; override on invocation if needed.
MACOSX_DEPLOYMENT_TARGET ?= 12.0
SWIFT := swiftc
CARGO := cargo

# Extra flags hook (leave empty unless you want to force a target)
SWIFT_EXTRA_FLAGS ?=

.PHONY: all swift rust run clean

all: swift rust

swift: $(DYLIB)

$(DYLIB): $(SWIFT_SRCS)
	@echo "Building Swift dylib → $@"
	@mkdir -p macos
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) \
	$(SWIFT) $(SWIFT_EXTRA_FLAGS) \
	  -emit-library \
	  -o $(DYLIB) \
	  -module-name NotchHelper \
	  -framework AppKit -framework Foundation \
	  $(SWIFT_SRCS)

rust:
	$(CARGO) build

run: all
	DYLD_LIBRARY_PATH=macos target/debug/$(APP_NAME)

clean:
	$(CARGO) clean
	rm -f $(DYLIB)
