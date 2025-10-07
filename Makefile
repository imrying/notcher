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
DYLIB := .build/debug/libNotchHelper.dylib
MACOSX_DEPLOYMENT_TARGET ?= 12.0
SWIFT_EXTRA_FLAGS ?=
CARGO := cargo

.PHONY: all swift rust run clean

all: swift rust

# Build Swift Package
swift:
	@echo "Building Swift package → $(DYLIB)"
	MACOSX_DEPLOYMENT_TARGET=$(MACOSX_DEPLOYMENT_TARGET) \
	swift build $(SWIFT_EXTRA_FLAGS) \
	--product NotchHelper

rust:
	$(CARGO) build

run: all
	DYLD_LIBRARY_PATH=.build/debug target/debug/$(APP_NAME)

clean:
	$(CARGO) clean
	swift package clean
