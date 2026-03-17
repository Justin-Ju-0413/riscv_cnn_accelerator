# Nuclei SDK Project Template

This directory is a pre-installation template for packaging the accelerator firmware
as a Nuclei SDK application.

## Intended Layout
- `application/main.c`: project entry point to be built by the SDK
- `config/project.mk`: project-specific architecture and board settings
- `Makefile.template`: top-level build template that sources the SDK environment
- `nuclei_app/`: SDK-native baremetal application template matching the official SDK layout

## After SDK Installation
1. Copy `../build/sdk_env.sh.template` to `../build/sdk_env.sh` and update paths.
2. Confirm the correct board, download method, and toolchain triplet.
3. Adapt `Makefile.template` to the exact Nuclei SDK project style you install.
4. Replace placeholder board settings in `config/project.mk`.
5. Or use `sw/build/install_sdk_app.sh` to stage the SDK-native app into `third_party/nuclei-sdk`.
