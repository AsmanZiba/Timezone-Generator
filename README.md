<h1 align="center">🕒 Timezone Generator</h1>
<p align="center">
Smart, portable compiler for IANA timezones — powered by Bash and Java. Runs on Termux, Linux, and Android without root access.
</p>

---

## 📦 Overview

**Timezone Generator** is a fully portable tool for compiling timezone data from official `tzdb` sources. It uses Bash for automation and Java for compacting zoneinfo formats, and supports easy deployment in **Termux**, **Linux**, and **Android (without root access)**.

---

## ⚙️ Features

- 🌍 Auto-Download and builds any tzdata version (e.g. `2025b`)
- 🔧 Automatic environment detection (Termux / Linux)
- ☕ Java-based compaction of zoneinfo data
- 📤 Configurable output paths (/sdcard for Termux, local for Linux)
- 🔁 Customizable tzdata version via script
- 📄 Generates structured setup file using Zone and Link directives
- Run bash script and generate standard time zone file for linux base operation systems.
- 🛡️ Lightweight and dependency-aware install script
- 💬 Interactive output and error handling

---
Android Support

You can build timezone files directly in Android using Termux.  
If your device is rooted, output files can be copied to:

```bash
/system/usr/share/zoneinfo/

> ⚠️ Root access is required to write to this system directory.  
> Use with caution and ensure backups before replacing timezone files.

---

📂 File Structure

| File/Folder         | Description                              |
|---------------------|------------------------------------------|
| compile-tzdata.sh | Main script to download, extract & build |
| ZoneCompactor.java| Compacts zoneinfo from setup file        |
| ZoneInfo.java     | Handles zoneinfo structures              |
| zones/            | Final output directory                   |
| setup             | Auto-generated zone configuration        |
| zoneinfo.*        | Binary output files (for deployment)     |

🧠 Environment Support

| Platform | Status      | Output Destination              |
|----------|-------------|----------------------------------|
| Termux   | ✅ Supported | /sdcard/TimezoneFiles         |
| Linux    | ✅ Supported | tzwork/zones/                 |

Automatic detection ensures scripts behave appropriately per environment.


---

💡 Customization

You can change the tzdata version by editing:

`bash
VERSION=2025b
`

Other options:
- Modify output paths
- Replace or extend Java logic for filtering
- Add install flags like --force to automate overwrites

---

📚 References

- IANA Time Zone Database
- tzdata GitHub Repository
- Java TimeZone Class

---

🧑‍💻 Author

Developed by Asman — blending scripting precision with system-level insight.  
Open to collaboration, feedback, and suggestions ✨

---

<p align="center">Built with ❤️ for Termux, Linux & Android power users</p>
`

## 🚀 Getting Started

### Usage
 **With Android**
install **Termux**:
run 
`bash
bash generator.sh
`
Example (with root):

`bash
su -c cp zoneinfo.dat zoneinfo.idx zoneinfo.version /system/usr/share/zoneinfo/
`
**For Linux (Debian/Ubuntu):**
`bash
bash generator.sh
`
