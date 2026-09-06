#!/bin/bash

# Setup Android Emulator for testing
# Usage: setup-android-emulator.sh [API_LEVEL] [ANDROID_VERSION]

set -e

API_LEVEL=${1:-33}
ANDROID_VERSION=${2:-android-33}
EMULATOR_NAME="test-emulator"

echo "Setting up Android emulator with API level $API_LEVEL..."

# Accept Android SDK licenses
yes | sdkmanager --licenses 2>/dev/null || true

# Install required packages
echo "Installing Android SDK components..."
sdkmanager --install "platforms;$ANDROID_VERSION" > /dev/null 2>&1 || true
sdkmanager --install "system-images;$ANDROID_VERSION;google_apis;x86_64" > /dev/null 2>&1 || true
sdkmanager --install "emulator" > /dev/null 2>&1 || true

# Create emulator
echo "Creating virtual device..."
echo "no" | avdmanager create avd \
  --force \
  --name "$EMULATOR_NAME" \
  --package "system-images;$ANDROID_VERSION;google_apis;x86_64" \
  --device "pixel_4a" 2>/dev/null || true

# Configure emulator for faster execution
EMULATOR_CONFIG="$HOME/.android/avd/$EMULATOR_NAME.avd/config.ini"
if [ -f "$EMULATOR_CONFIG" ]; then
  echo "Configuring emulator settings..."
  sed -i 's/^hw.lcd.density=.*/hw.lcd.density=420/' "$EMULATOR_CONFIG" || true
  echo "hw.gpu.enabled=yes" >> "$EMULATOR_CONFIG" || true
  echo "hw.gpu.mode=auto" >> "$EMULATOR_CONFIG" || true
  echo "hw.keyboard=yes" >> "$EMULATOR_CONFIG" || true
  echo "showDeviceFrame=no" >> "$EMULATOR_CONFIG" || true
fi

# Launch emulator
echo "Launching Android emulator..."
$ANDROID_SDK_ROOT/emulator/emulator \
  -avd "$EMULATOR_NAME" \
  -no-audio \
  -no-boot-anim \
  -gpu swiftshader_indirect \
  -memory 2048 \
  -cores 4 \
  -accel on \
  -partition-size 2048 \
  2>&1 | tee /tmp/emulator.log &

EMULATOR_PID=$!
echo "Emulator PID: $EMULATOR_PID"

# Wait for emulator to start
echo "Waiting for emulator to be ready..."
sleep 10

# Check if emulator is running
for i in {1..60}; do
  if adb devices | grep -q "emulator.*device"; then
    echo "✅ Emulator is ready!"
    break
  fi
  echo "Waiting... ($i/60)"
  sleep 2
done

echo "Android emulator setup complete!"
