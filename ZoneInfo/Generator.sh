#!/usr/bin/env bash

set -e

# 🌐 Set tzdb version
VERSION=2025b
URL="https://data.iana.org/time-zones/releases/tzdb-${VERSION}.tar.lz"

# 📁 Define working directories
WORKDIR="$HOME/tzwork"
SRCDIR="$WORKDIR/tzdb-${VERSION}"
ZONEDIR="$WORKDIR/zones"
SCRIPT_DIR="$(pwd)"

# 🧠 Detect environment
if command -v termux-info >/dev/null 2>&1; then
  ENV="termux"
else
  ENV="linux"
fi

echo "🧠 Environment detected: $ENV"

# 🔧 Install dependencies
echo "📦 Checking dependencies..."
TOOLS="curl lzip clang javac java awk grep"

for tool in $TOOLS; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "⚠️ '$tool' is missing."
    if [ "$ENV" = "termux" ]; then
      pkg install "$tool" -y
    elif command -v apt-get >/dev/null 2>&1; then
      sudo apt-get update && sudo apt-get install "$tool" -y
    else
      echo "❌ Cannot install '$tool'. Please install it manually."
      exit 1
    fi
  fi
done

# 📥 Download and extract tzdb
echo "📥 Downloading tzdb-${VERSION}..."
mkdir -p "$WORKDIR"
cd "$WORKDIR" || exit

if [ ! -d "$SRCDIR" ]; then
  [ ! -f "tzdb-${VERSION}.tar.lz" ] && curl -O "$URL"
  lzip -d "tzdb-${VERSION}.tar.lz"
  tar xf "tzdb-${VERSION}.tar"
fi

# 🔨 Compile zic
cd "$SRCDIR" || exit
if [ "$ENV" = "termux" ]; then
  echo "🛠️ Building zic with make (Termux)..."
  make -C "$SRCDIR" CC="clang -std=c99"
  ZIC="$SRCDIR/zic"
else
  echo "🛠️ Building zic with clang (Linux)..."
  clang -std=c99 -O2 "$SRCDIR"/*.c -o "$SRCDIR/zic"
  ZIC="$SRCDIR/zic"
fi

# 🌍 Generate zoneinfo files
mkdir -p "$ZONEDIR"
for file in africa antarctica asia australasia etcetera europe factory northamerica southamerica; do
  [ -f "$file" ] && $ZIC -d "$ZONEDIR" "$file" || echo "⚠️ Missing tz source: $file"
done

cp "$SCRIPT_DIR"/ZoneCompactor.java "$SCRIPT_DIR"/ZoneInfo.java "$ZONEDIR"/

# 🧩 Build setup file inside zones
echo "🧩 Generating setup file in $ZONEDIR..."
(
  cat $SRCDIR/* | grep '^Link' | awk '{print $1, $2, $3}'
  (
    cat $SRCDIR/* | grep '^Zone' | awk '{print $2}'
    cat $SRCDIR/* | grep '^Link' | awk '{print $3}'
  ) | LC_ALL="C" sort
) | grep -v Riyadh8 > "$ZONEDIR/setup"

echo "☕ Compiling Java files in $ZONEDIR..."
cd "$ZONEDIR" || exit
javac ZoneCompactor.java ZoneInfo.java

echo "🚀 Running ZoneCompactor..."
java ZoneCompactor setup .

echo "$VERSION" > zoneinfo.version

if [ "$ENV" = "termux" ]; then
  echo "📤 Result output to /sdcard/TimezoneFiles..."
  mkdir -p /sdcard/TimezoneFiles
  cp zoneinfo.dat zoneinfo.idx zoneinfo.version /sdcard/TimezoneFiles
else
  echo "✅ Output saved in $ZONEDIR"
fi

echo "🎉 Build complete."