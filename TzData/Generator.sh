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
declare -A TOOL_PACKAGES=(
  [curl]="curl"
  [lzip]="lzip"
  [clang]="clang"
  [javac]="openjdk-17-jdk"
  [java]="openjdk-17-jdk"
  [awk]="gawk"
  [grep]="grep"
  [ar]="binutils"
)

for tool in "${!TOOL_PACKAGES[@]}"; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "⚠️ '$tool' is missing."
    package="${TOOL_PACKAGES[$tool]}"
    
    if [ "$ENV" = "termux" ]; then
      pkg install "$package" -y
    elif command -v apt-get >/dev/null 2>&1; then
      sudo apt-get update && sudo apt-get install "$package" -y
    else
      echo "⚠️ Cannot install '$tool' (package: $package). Please install it manually."
      exit 1
    fi
  fi
done

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