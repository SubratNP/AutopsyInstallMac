#!/bin/bash

set -e

echo "Checking for Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"  # Adjust for Intel if needed
else
  echo "Homebrew is already installed."
fi

echo "Installing Java Liberia JDK 17"
brew tap bell-sw/liberica
brew install --cask liberica-jdk17-full

echo "Installing required packages..."
brew install afflib libewf postgresql@15 testdisk libheif

echo "Downloading GStreamer 1.26.7..."
GST_PKG_URL="https://gstreamer.freedesktop.org/data/pkg/osx/1.26.7/gstreamer-1.0-1.26.7-universal.pkg"
GST_PKG_FILE="/tmp/gstreamer-1.26.7.pkg"
curl -L "$GST_PKG_URL" -o "$GST_PKG_FILE"

echo "Installing GStreamer..."
sudo installer -pkg "$GST_PKG_FILE" -target /

echo "Setting JAVA_HOME and updating PATH..."

JAVA_HOME_PATH="$(/usr/libexec/java_home -v17)"
PROFILE_FILE="$HOME/.zprofile"

echo "# Set JAVA_HOME and add to path >>>" >> "$PROFILE_FILE"
echo "export JAVA_HOME=$(/usr/libexec/java_home)" >> "$PROFILE_FILE"
echo "export PATH=\"\$JAVA_HOME/bin:\$PATH\"" >> "$PROFILE_FILE"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$PROFILE_FILE"
eval "$(/opt/homebrew/bin/brew shellenv)"

echo "Installing Sleuthkit"
brew tap markmckinnon/sleuthkit
brew install markmckinnon/sleuthkit/sleuthkit


Echo "Linking libraries"
sudo mkdir -p /usr/local/lib
sudo ln -s /opt/homebrew/opt/sleuthkit/lib/* /usr/local/lib
Sudo mkdir -p /usr/local/share/java
sudo ln -s /opt/homebrew/opt/sleuthkit/share/java/* /usr/local/share/java

echo "Downloading, unzip and install the Autopsy Application"
curl -L -o /tmp/autopsy.zip https://github.com/markmckinnon/homebrew-sleuthkit/releases/download/Apple/autopsy-4.22.1b3.zip
unzip /tmp/autopsy.zip -d /tmp/autopsy_app
sudo mv /tmp/autopsy_app/*.app /Applications/

echo "Setting permissions for autopsy"
sudo chmod -R a+x /Applications/autopsy.app/Contents/Resources/autopsy/autopsy/markmckinnon
sudo chmod -R a+x /Applications/autopsy.app/Contents/Resources/autopsy/autopsy/solr/bin

echo "Environment updated. Please restart your terminal or run:"
echo "    source $PROFILE_FILE"
