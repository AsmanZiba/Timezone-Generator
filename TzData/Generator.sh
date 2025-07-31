#!/usr/bin/env bash

set -e

#🌐 Set tzdb version and download URL
VERSION=2025b
URL="https://data.iana.org/time-zones/releases/tzdb-${VERSION}.tar.lz"

#📁 Define working directories
SCRIPTDIR="$(pwd)/TzData"
WORKDIR="$HOME/tzwork"
SRCDIR="$WORKDIR/tzdb-${VERSION}"
ZONEDIR="$WORKDIR/zones"

#🧠 Detect environment: Termux or Linux
if command -v termux-info >/dev/null 2>&1; then
  ENV="termux"
  OUTPUTDIR="/sdcard/TimezoneFiles"
else
  ENV="linux"
  OUTPUTDIR="/usr/share/zoneinfo"
fi

echo "🔍 Environment detected: $ENV"

echo "🔧 Checking dependencies..."
# List of essential tools
TOOLS="curl lzip clang javac java awk grep"

for tool in $TOOLS; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "⚠️ '$tool' is missing."
    if [ "$ENV" = "termux" ]; then
      pkg install "$tool" -y
    elif command -v apt-get >/dev/null 2>&1; then
      sudo apt-get update && sudo apt-get install "$tool" -y
    else
      echo "⚠️ Cannot install '$tool'. Please install it manually."
      exit 1
    fi
  fi
done

# Special case: check for 'ar' (part of binutils)
if ! command -v ar >/dev/null 2>&1; then
  echo "⚠️ 'ar' is missing. Installing 'binutils'..."
  if [ "$ENV" = "termux" ]; then
    pkg install binutils -y
  elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install binutils -y
  else
    echo "⚠️ Cannot install 'binutils'. Please install it manually."
    exit 1
  fi
fi

echo "📥 Downloading tzdb-${VERSION}..."
mkdir -p "$WORKDIR"
cd "$WORKDIR"

if [ ! -d "$SRCDIR" ]; then
  [ ! -f "tzdb-${VERSION}.tar.lz" ] && curl -O "$URL"
  lzip -d "tzdb-${VERSION}.tar.lz"
  tar xf "tzdb-${VERSION}.tar"
fi

#🛠 Compile zic (timezone compiler)
cd "$SRCDIR"
if [ "$ENV" = "termux" ]; then
  echo "🛠 Building zic with make (Termux)..."
  make -C "$SRCDIR" CC="clang -std=c99"
else
  echo "🛠 Building zic with clang (Linux)..."
  clang -std=c99 -O2 *.c -o zic
fi
ZIC="$SRCDIR/zic"

#📦 Generate .zi files from source
TZFILES="africa antarctica asia australasia europe northamerica southamerica etcetera"

for FORM in main vanguard rearguard; do
    awk -v DATAFORM="$FORM" -f ziguard.awk $TZFILES | awk '!/^Link/' > "$FORM.zi"
done

#📦 Compile .zi files to zoneinfo
mkdir -p "$ZONEDIR"
$ZIC -d "$ZONEDIR" main.zi
$ZIC -d "$ZONEDIR" vanguard.zi
$ZIC -d "$ZONEDIR" rearguard.zi

echo "🧩 Generating setup file..."
[ -f "$ZONEDIR/setup" ] && rm "$ZONEDIR/setup"

grep '^Link' $TZFILES | awk '{print "Link", $2, $3}' >> "$ZONEDIR/setup"
{
  grep '^Zone' $TZFILES | awk '{print $2}'
  grep '^Link' $TZFILES | awk '{print $3}'
} | sort -u >> "$ZONEDIR/setup"

#Compile ZoneCompactor
cp "$SCRIPTDIR"/ZoneCompactor.java "$ZONEDIR"

cd "$ZONEDIR"
echo "🛠️ Compiling ZoneCompactor..."
javac ZoneCompactor.java

echo "🚀 Running ZoneCompactor..."
java ZoneCompactor setup . $SRCDIR/zone.tab . $VERSION

if [ "$ENV" = "termux" ]; then
  echo "📦 Save output files to $OUTPUTDIR"
  mkdir -p $OUTPUTDIR
  cp tzdata $OUTPUTDIR
else
  echo "✅ Output saved in $OUTPUTDIR"
  cp -r Africa America Antarctica Asia Atlantic Australia Europe Etc GMT Indian Pacific $OUTPUTDIR
fi