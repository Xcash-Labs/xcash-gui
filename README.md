# XCash Klassic GUI

Copyright (c) 2014-2024, The Monero Project  
Copyright (c) 2026, XCash Labs

XCash Klassic GUI is forked from the Monero GUI project and adapted for the XCash Klassic network.

## Table of Contents

* [Development resources](#development-resources)
* [Vulnerability response](#vulnerability-response)
* [Introduction](#introduction)
* [About this project](#about-this-project)
* [Supporting the project](#supporting-the-project)
* [License](#license)
* [Translations](#translations)
* [Installing the XCash Klassic GUI](#installing-the-xcash-klassic-gui)
* [Compiling the XCash Klassic GUI from source](#compiling-the-xcash-klassic-gui-from-source)
  + [Building Reproducible Windows static binaries with Docker (any OS)](#building-reproducible-windows-static-binaries-with-docker-any-os)
  + [Building Reproducible Linux static binaries with Docker (any OS)](#building-reproducible-linux-static-binaries-with-docker-any-os)
  + [Building Android APK with Docker (any OS) Experimental](#building-android-apk-with-docker-any-os-experimental)
  + [Building on Linux](#building-on-linux)
  + [Building on OS X](#building-on-os-x)
  + [Building on Windows](#building-on-windows)

## Development resources

- Web: [xcashlabs.org](https://xcashlabs.org)
- GitHub: [https://github.com/Xcash-Labs/xcash-gui](https://github.com/Xcash-Labs/xcash-gui)
- Core repository: [https://github.com/Xcash-Labs/xcash-labs-core](https://github.com/Xcash-Labs/xcash-labs-core)
- Explorer: [https://explorer.xcashlabs.org](https://explorer.xcashlabs.org)
- Delegates: [https://xcashlabs.org/delegates/](https://xcashlabs.org/delegates/)

## Vulnerability response

If you discover a security vulnerability in XCash Klassic GUI or the supporting XCash Klassic core software, please report it responsibly through the XCash Labs project channels.

When reporting a vulnerability, include:

- a clear description of the issue
- steps to reproduce it
- affected operating system and build version
- whether funds, private keys, wallet files, or network consensus may be impacted

## Introduction

XCash Klassic is a CryptoNote-based digital currency focused on privacy, security, and decentralization. The XCash Klassic GUI gives users a graphical wallet for creating wallets, restoring wallets, sending and receiving XCK, and interacting with the XCash Klassic network.

**Privacy:** XCash Klassic is based on CryptoNote technology and inherits privacy-focused transaction features from its Monero-derived codebase.

**Security:** Wallet files are encrypted with a passphrase. Wallet recovery is handled through a mnemonic seed that should be written down and stored safely offline.

**Control:** XCash Klassic allows users to control their own funds without relying on a centralized custodian.

## About this project

This repository contains the graphical wallet for XCash Klassic. It is forked from the Monero GUI and adapted for the XCash Klassic network, branding, currency units, addresses, and supporting core binaries.

As with many development projects, the repository on GitHub is the staging area for the latest changes. New changes should be tested before being used in production. For normal users, tagged releases are recommended over development branches.

This project depends on the XCash Klassic core software for wallet and daemon functionality.

## Supporting the project

XCash Klassic is developed and maintained by XCash Labs.

GUI development funding and supporting services may be provided through:

- GitHub Sponsors: [https://github.com/sponsors/Xcash-Labs](https://github.com/sponsors/Xcash-Labs)
- Project website: [https://xcashlabs.org](https://xcashlabs.org)

## License

See [LICENSE](LICENSE).

This project is forked from the Monero GUI project and retains the applicable upstream license notices.

## Translations

The XCash Klassic GUI uses Qt translation files inherited from the Monero GUI project.

Some translated strings may still reference Monero until they are reviewed and updated for XCash Klassic. When adding or changing user-facing text, update the base translation file first and regenerate translation sources as needed.

Useful files and folders:

```text
translations/
*.ts
*.qm
```

## Installing the XCash Klassic GUI

Prebuilt release packages, when available, should be downloaded from the official XCash Labs release channels.

Recommended sources:

- [https://github.com/Xcash-Labs/xcash-gui/releases](https://github.com/Xcash-Labs/xcash-gui/releases)
- [https://xcashlabs.org](https://xcashlabs.org)

Always verify that you are downloading from an official XCash Labs source.

## Compiling the XCash Klassic GUI from source

*Note*: Qt 5.9.7 is the minimum version required to build the GUI.

*Note*: This project is forked from Monero GUI, so some build scripts, dependency names, and internal binary names may still contain `monero` until fully renamed.

### Building Reproducible Windows static binaries with Docker (any OS)

1. Install Docker:

   ```text
   https://docs.docker.com/engine/install/
   ```

2. Clone the repository:

   ```bash
   git clone --branch master --recursive https://github.com/Xcash-Labs/xcash-gui.git
   ```

   Replace `master` with the desired release tag when building a tagged release.

3. Prepare the build environment:

   ```bash
   cd xcash-gui
   docker build --tag xcash:build-env-windows --build-arg THREADS=4 --file Dockerfile.windows .
   ```

   `4` is the number of CPU threads to use.

4. Build:

   ```bash
   docker run --rm -it -v <XCASH_GUI_DIR_FULL_PATH>:/xcash-gui -w /xcash-gui xcash:build-env-windows sh -c 'make depends root=/depends target=x86_64-w64-mingw32 tag=win-x64 -j4'
   ```

   Replace `<XCASH_GUI_DIR_FULL_PATH>` with the absolute path to your `xcash-gui` directory.

5. XCash Klassic GUI Windows static binaries will be placed in:

   ```text
   xcash-gui/build/x86_64-w64-mingw32/release/bin
   ```

### Building Reproducible Linux static binaries with Docker (any OS)

1. Install Docker:

   ```text
   https://docs.docker.com/engine/install/
   ```

2. Clone the repository:

   ```bash
   git clone --branch master --recursive https://github.com/Xcash-Labs/xcash-gui.git
   ```

   Replace `master` with the desired release tag when building a tagged release.

3. Prepare the build environment:

   ```bash
   cd xcash-gui
   docker build --tag xcash:build-env-linux --build-arg THREADS=4 --file Dockerfile.linux .
   ```

4. Build:

   ```bash
   docker run --rm -it -v <XCASH_GUI_DIR_FULL_PATH>:/xcash-gui -w /xcash-gui xcash:build-env-linux sh -c 'make release-static -j4'
   ```

5. XCash Klassic GUI Linux static binaries will be placed in:

   ```text
   xcash-gui/build/release/bin
   ```

6. Optional: compare the `xcash-wallet-gui` SHA-256 hash to a trusted source:

   ```bash
   docker run --rm -it -v <XCASH_GUI_DIR_FULL_PATH>:/xcash-gui -w /xcash-gui xcash:build-env-linux sh -c 'shasum -a 256 /xcash-gui/build/release/bin/xcash-wallet-gui'
   ```

### Building Android APK with Docker (any OS) Experimental

Android support is experimental.

Minimum requirements:

- Android 9 Pie / API 28
- ARMv8-A 64-bit CPU

1. Install Docker:

   ```text
   https://docs.docker.com/engine/install/
   ```

2. Clone the repository:

   ```bash
   git clone --recursive https://github.com/Xcash-Labs/xcash-gui.git
   ```

3. Prepare the build environment:

   ```bash
   cd xcash-gui
   docker build --tag xcash:build-env-android --build-arg THREADS=4 --file Dockerfile.android .
   ```

4. Build:

   ```bash
   docker run --rm -it -v <XCASH_GUI_DIR_FULL_PATH>:/xcash-gui -e THREADS=4 xcash:build-env-android
   ```

5. The APK should be placed in:

   ```text
   xcash-gui/build/Android/release/android-build
   ```

6. Deploy with ADB:

   ```bash
   adb install build/Android/release/android-build/xcash-gui.apk
   ```

7. Troubleshooting:

   ```bash
   adb devices -l
   adb logcat
   ```

   If using ADB inside Docker, make sure the container has USB access:

   ```bash
   docker run -v /dev/bus/usb:/dev/bus/usb --privileged
   ```

### Building on Linux

Tested upstream environments included Ubuntu and Gentoo. Your mileage may vary depending on Qt and dependency versions.

1. Install dependencies.

   Debian / Ubuntu / Mint / Tails:

   ```bash
   sudo apt install build-essential cmake miniupnpc libunbound-dev graphviz doxygen libunwind8-dev pkg-config libssl-dev libzmq3-dev libsodium-dev libhidapi-dev libnorm-dev libusb-1.0-0-dev libpgm-dev libprotobuf-dev protobuf-compiler libgcrypt20-dev libboost-chrono-dev libboost-date-time-dev libboost-filesystem-dev libboost-locale-dev libboost-program-options-dev libboost-regex-dev libboost-serialization-dev libboost-system-dev libboost-thread-dev
   ```

   Gentoo:

   ```bash
   sudo emerge app-arch/xz-utils app-doc/doxygen dev-cpp/gtest dev-libs/boost dev-libs/expat dev-libs/openssl dev-util/cmake media-gfx/graphviz net-dns/unbound net-libs/miniupnpc net-libs/zeromq sys-libs/libunwind dev-libs/libsodium dev-libs/hidapi dev-libs/libgcrypt
   ```

   Fedora:

   ```bash
   sudo dnf install make automake cmake gcc-c++ boost-devel miniupnpc-devel graphviz doxygen unbound-devel libunwind-devel pkgconfig openssl-devel libcurl-devel hidapi-devel libusb-devel zeromq-devel libgcrypt-devel
   ```

2. Install Qt.

   Qt 5.9.7 or newer is required. The recommended approach is to install a compatible Qt 5 version from Qt or your distribution packages.

   Debian / Ubuntu / Mint / Tails:

   ```bash
   sudo apt install qtbase5-dev qtdeclarative5-dev qml-module-qtqml-models2 qml-module-qtquick-controls qml-module-qtquick-controls2 qml-module-qtquick-dialogs qml-module-qtquick-xmllistmodel qml-module-qt-labs-settings qml-module-qt-labs-platform qml-module-qt-labs-folderlistmodel qttools5-dev-tools qml-module-qtquick-templates2 libqt5svg5-dev
   ```

   Gentoo:

   ```bash
   sudo emerge dev-qt/qtcore:5 dev-qt/qtdeclarative:5 dev-qt/qtquickcontrols:5 dev-qt/qtquickcontrols2:5 dev-qt/qtgraphicaleffects:5
   ```

   Optional scanner support:

   Debian / Ubuntu / Mint / Tails:

   ```bash
   sudo apt install qtmultimedia5-dev qml-module-qtmultimedia
   ```

   Gentoo:

   ```bash
   emerge dev-qt/qtmultimedia:5
   ```

3. Clone the repository:

   ```bash
   git clone --recursive https://github.com/Xcash-Labs/xcash-gui.git
   cd xcash-gui
   ```

4. Build:

   ```bash
   make release -j4
   ```

   Add `CMAKE_PREFIX_PATH` if you need to point the build at a custom Qt installation:

   ```bash
   CMAKE_PREFIX_PATH=$HOME/Qt/5.9.7/gcc_64 make release -j4
   ```

The executable can be found in the build release bin folder.

### Building on OS X

1. Install Xcode from the App Store.

2. Install Homebrew:

   ```text
   https://brew.sh/
   ```

3. Install dependencies:

   ```bash
   brew install cmake pkg-config openssl boost unbound hidapi zmq libpgm libsodium miniupnpc expat libunwind-headers protobuf libgcrypt
   ```

4. Install Qt 5:

   ```bash
   brew install qt5
   ```

   Alternatively, install Qt 5.9.7 or newer from Qt.

5. Clone the repository:

   ```bash
   git clone --recursive https://github.com/Xcash-Labs/xcash-gui.git
   cd xcash-gui
   ```

6. Build:

   ```bash
   make release -j4
   ```

   Add `CMAKE_PREFIX_PATH` if needed:

   ```bash
   CMAKE_PREFIX_PATH=$HOME/Qt/5.9.7/clang_64 make release -j4
   ```

The executable can be found in:

```text
build/release/bin
```

For building an application bundle, see:

```text
DEPLOY.md
```

### Building on Windows

The XCash Klassic GUI on Windows is 64-bit only.

1. Install MSYS2:

   ```text
   https://www.msys2.org/
   ```

2. Open a 64-bit MSYS2 shell. Use the **MSYS2 MinGW 64-bit** shortcut, or use `msys2_shell.cmd` with the `-mingw64` parameter.

3. Install MSYS2 packages:

   ```bash
   pacman -S mingw-w64-x86_64-toolchain make mingw-w64-x86_64-cmake mingw-w64-x86_64-boost mingw-w64-x86_64-openssl mingw-w64-x86_64-zeromq mingw-w64-x86_64-libsodium mingw-w64-x86_64-hidapi mingw-w64-x86_64-protobuf-c mingw-w64-x86_64-libusb mingw-w64-x86_64-libgcrypt mingw-w64-x86_64-unbound mingw-w64-x86_64-pcre mingw-w64-x86_64-angleproject
   ```

4. Install Qt 5:

   ```bash
   pacman -S mingw-w64-x86_64-qt5
   ```

5. Install Git:

   ```bash
   pacman -S git
   ```

6. Clone the repository:

   ```bash
   git clone --recursive https://github.com/Xcash-Labs/xcash-gui.git
   cd xcash-gui
   ```

7. Build:

   ```bash
   make release-win64 JOBS=4
   cd build/release
   mingw32-make deploy
   ```

The executable can be found in:

```text
build/release/bin
```

## Notes for maintainers

Because this project is forked from Monero GUI, some remaining references to Monero may still exist in comments, translation files, generated files, dependency names, or upstream documentation.

High-priority files to review when rebranding:

```text
README.md
share/*.metainfo.xml
translations/
src/
qml/
images/
```

Generated build outputs should not be edited manually.
