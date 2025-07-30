#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(pwd)"
TZDATA_SCRIPT="$SCRIPT_DIR/TzData/Generator.sh"
ZONEINFO_SCRIPT="$SCRIPT_DIR/ZoneInfo/Generator.sh"

echo "🔍 Detecting timezone format..."

if [ -f /apex/com.android.tzdata/etc/tz/tzdata ]; then
  FORMAT="tzdata"
  echo "✅ System uses tzdata format"
elif [ -f /system/usr/share/zoneinfo/zoneinfo.dat ]; then
  FORMAT="zoneinfo"
  echo "✅ System uses zoneinfo format"
else
  FORMAT="tzdata"
  echo "⚠️ Unknown format. Defaulting to tzdata."
fi

case "$FORMAT" in
  tzdata)
    echo "🚀 Running tzdata Generator..."
    bash "$TZDATA_SCRIPT"
    ;;
  zoneinfo)
    echo "🚀 Running zoneinfo Generator..."
    bash "$ZONEINFO_SCRIPT"
    ;;
esac

echo "✅ Build complete."