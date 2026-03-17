# Project-specific settings to be adapted after the Nuclei SDK is installed.

APP_NAME := cnn_accel_demo
CORE ?= n300
ARCH_EXT ?= rv32imac
ABI ?= ilp32
BOARD ?= your_e203_board
DOWNLOAD ?= ilm

# Add project-local include directories here after integrating with the SDK.
APP_INCDIRS += $(CURDIR)/application $(CURDIR)/../inc
