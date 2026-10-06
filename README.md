# AutopsyInstallMac

A macOS Apple Silicon (ARM64/aarch64) installation script for **Autopsy Digital Forensics**.

Autopsy does not provide straightforward native Apple Silicon support in its standard installation process. This repository preserves and shares a community-provided installation script that helps set up Autopsy and its required dependencies on Apple Silicon Macs.

> **Note:** This script was not originally written by me. I am sharing it because it was difficult to find and may be useful for others trying to run Autopsy on Apple Silicon Macs.

## What the Script Does

The script automates the installation and configuration of the main components required to run Autopsy on an Apple Silicon Mac.

It performs the following steps:

1. Checks whether **Homebrew** is installed and installs it if necessary.
2. Installs **Liberica JDK 17**, which is required by Autopsy.
3. Installs forensic and supporting libraries:

   * AFFLib
   * libewf
   * PostgreSQL 15
   * TestDisk
   * libheif
4. Downloads and installs **GStreamer 1.26.7**.
5. Configures `JAVA_HOME` and the Homebrew environment.
6. Installs **Sleuth Kit** using the required Homebrew tap.
7. Creates symbolic links for Sleuth Kit libraries.
8. Downloads a prebuilt Apple Silicon-compatible Autopsy application.
9. Installs Autopsy into `/Applications`.
10. Sets executable permissions on required Autopsy components.

## Why This Is Needed on Apple Silicon

Autopsy relies on several native components, particularly **Sleuth Kit and JNI/native libraries**. Native libraries compiled for Intel (`x86_64`) cannot simply be used as ARM64 binaries.

The installation approach used by this script provides an ARM-compatible environment by combining:

```text
Autopsy
   │
   ├── Java 17
   ├── Sleuth Kit
   ├── Native forensic libraries
   ├── GStreamer
   ├── Solr
   └── Other dependencies
```

The script downloads a prebuilt Autopsy application from the Apple Silicon-related release provided by the script's original maintainer and installs the required dependencies separately.

This should be considered a **community/alternative installation method**, rather than assuming that it represents official native Apple Silicon support from the Autopsy project.

## GStreamer

GStreamer is a multimedia framework used by Autopsy for handling multimedia-related functionality such as audio and video processing.

The script downloads the macOS **universal** GStreamer package:

```text
gstreamer-1.0-1.26.7-universal.pkg
```

GStreamer itself is not what makes Autopsy ARM64-compatible. Instead, it provides a required multimedia dependency while the ARM compatibility primarily depends on using compatible Java, Sleuth Kit, and native components.

## Sleuth Kit

Sleuth Kit is a core component of Autopsy's digital forensics functionality.

It provides low-level forensic capabilities for analysing disk images, file systems, metadata, and other digital evidence.

The script installs Sleuth Kit using:

```bash
brew tap markmckinnon/sleuthkit
brew install markmckinnon/sleuthkit/sleuthkit
```

It then creates symbolic links to make the installed libraries available to the Autopsy application.

This is particularly relevant when analysing forensic disk images such as:

```text
.E01
```

(EWF/Expert Witness Format) images.

## Running the Script

Clone the repository:

```bash
git clone https://github.com/SubratNP/AutopsyInstallMac.git
cd AutopsyInstallMac
```

Make the script executable:

```bash
chmod +x install_macos_autopsy_aarch64.sh
```

Run it:

```bash
./install_macos_autopsy_aarch64.sh
```

The installation process may request your macOS administrator password when installing system-level components.

After installation, Autopsy should be available under:

```text
/Applications/autopsy.app
```

## Fix for Case Creation / Startup Issues

On my Apple Silicon setup, Autopsy could launch successfully but encountered an issue when attempting to create a new case.

The following command was used to terminate existing Autopsy/Solr processes and start Autopsy with a clean environment and the Liberica JDK 17 installation explicitly specified:

```bash
pkill -f autopsy; pkill -f solr
env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin" \
  JAVA_HOME="/Library/Java/JavaVirtualMachines/liberica-jdk-17-full.jdk/Contents/Home" \
  /Applications/autopsy.app/Contents/Resources/autopsy/bin/autopsy \
  --jdkhome "/Library/Java/JavaVirtualMachines/liberica-jdk-17-full.jdk/Contents/Home"
```

### What this workaround does

The first part:

```bash
pkill -f autopsy
pkill -f solr
```

terminates existing Autopsy and Solr processes.

The second part:

```bash
env -i
```

starts Autopsy with a clean environment instead of inheriting potentially conflicting environment variables from the current shell.

The command then explicitly sets:

```bash
JAVA_HOME="/Library/Java/JavaVirtualMachines/liberica-jdk-17-full.jdk/Contents/Home"
```

and tells Autopsy to use the same JDK:

```bash
--jdkhome "/Library/Java/JavaVirtualMachines/liberica-jdk-17-full.jdk/Contents/Home"
```

This resolved the case-creation issue on the setup where it was encountered.

> **Note:** This is a workaround observed on a specific Apple Silicon setup. It may not be required on every system and the exact Java installation path may differ depending on how Liberica JDK is installed.

## Requirements

This setup is intended primarily for:

* Apple Silicon Macs
* macOS
* ARM64 / aarch64 architecture
* Java 17

You can check your Mac architecture with:

```bash
uname -m
```

Apple Silicon should return:

```text
arm64
```

Check Java with:

```bash
java -version
```

The setup expects Java 17.

## Limitations

This is an alternative/community installation approach and should not be assumed to provide complete feature parity with Autopsy on officially supported platforms.

Some Autopsy modules or external dependencies may not work correctly on Apple Silicon.

If a particular forensic module is important to your investigation, verify that it works correctly before relying on this setup for actual forensic work.

## Attribution

This repository is intended for **sharing and preservation of an installation script that was difficult to locate**, not to claim authorship of the original script.

The installation script downloads the Autopsy build and uses Sleuth Kit resources associated with:

**Mark McKinnon / homebrew-sleuthkit**

Please refer to the original project and release sources for the latest information and updates.

## Disclaimer

This repository is provided for educational and research purposes.

Autopsy and its dependencies may change over time, and this installation method may stop working with future versions of macOS, Java, Homebrew, Autopsy, or its dependencies.

Always validate your forensic environment before using it for real investigations.

## Repository

GitHub:

https://github.com/SubratNP/AutopsyInstallMac

