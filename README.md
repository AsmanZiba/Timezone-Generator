<h1 align="center">🕒 Timezone Generator</h1>
<p align="center">
Smart, portable compiler for IANA timezones — powered by Bash and Java. Runs on Termux, Linux, and Android without root access.
</p>

---

## 📦 Overview

**Timezone Generator** is a fully portable tool for compiling timezone data from official `tzdb` sources. It uses Bash for automation and Java for compacting zoneinfo formats, and supports easy deployment in **Termux**, **Linux**, and **Android (without root access)**.

---

## ⚙️ Features

- 🌍 Downloads and builds any tzdata version (e.g. `2025b`)
- 🔧 Automatic environment detection (Termux / Linux / Android)
- ☕ Java-based compaction of zoneinfo data
- 📤 Creates `zoneinfo.dat`, `zoneinfo.idx`, and version metadata for update newest version time zones in world.
- Run bash script and generate standard time zone file for linux base operation systems.
- 📁 Simple push to `/system/usr/share/zoneinfo/` on rooted Android devices
- 🛡️ Lightweight and dependency-aware install script
- 💬 Interactive output and error handling

---

## 🚀 Getting Started

### Install dependencies

For **Termux**:

```bash
pkg install curl lzip clang openjdk-17
