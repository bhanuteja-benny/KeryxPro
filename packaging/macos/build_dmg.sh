#!/bin/bash
# KeryxPro macOS DMG Builder Script
# This script uses the native hdiutil to create a dmg image containing the app bundle.

APP_NAME="KeryxPro"
VERSION="1.0.0"
DMG_NAME="${APP_NAME}_Mac_v${VERSION}.dmg"
SOURCE_APP="../../build/macos/Build/Products/Release/keryxpro.app"
STAGING_DIR="dmg_staging"
OUTPUT_DIR="../../build/macos/installer"

echo "Checking if app bundle exists at $SOURCE_APP..."
if [ ! -d "$SOURCE_APP" ]; then
    echo "Error: Application bundle not found. Please run 'flutter build macos --release' first."
    exit 1
fi

echo "Creating staging directory..."
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"
mkdir -p "$OUTPUT_DIR"

echo "Copying app bundle to staging directory..."
cp -R "$SOURCE_APP" "$STAGING_DIR/"

echo "Creating Applications symlink..."
ln -s /Applications "$STAGING_DIR/Applications"

echo "Creating the DMG..."
# Remove old DMG if exists
rm -f "${OUTPUT_DIR}/${DMG_NAME}"

# Create disk image
hdiutil create -volname "${APP_NAME}" -srcfolder "$STAGING_DIR" -ov -format UDZO "${OUTPUT_DIR}/${DMG_NAME}"

echo "Cleaning up staging directory..."
rm -rf "$STAGING_DIR"

echo "Success! The DMG has been created at: ${OUTPUT_DIR}/${DMG_NAME}"
