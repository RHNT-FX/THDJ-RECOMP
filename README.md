# THDJRecomp

<p align="center">
  <b>Native PC Port / Static Recompilation of <i>Tony Hawk's Downhill Jam</i> (PlayStation 2)</b>
  <br />
  Targeting modern 64-bit Linux and Windows platforms.
</p>

---

## 🛹 Overview
**THDJRecomp** is an open-source static recompilation project targeting the PlayStation 2 release of **Tony Hawk's Downhill Jam** (*SLUS-21456* / CRC `7D13310A`). 

Unlike emulation, static recompilation decodes the MIPS R5900 Emotion Engine machine code directly into native C++ instructions ahead-of-time. This provides:
- **Silky smooth native performance** on Windows & Linux without typical emulator overhead.
- **Native Resolution & Ultrawide scaling** with proper aspect-ratio correction.
- **Low latency controller support** via modern SDL2 input mappings.
- **Cross-platform rendering** powered by WebGPU / Vulkan backend.
- **Runtime script patches** fixing the startup TCR memory card check hang and IOP audio streaming allocations.

> **Note:** This repository **does NOT contain any copyrighted assets, ISO images, or proprietary game binaries**. Users must provide their own legally acquired PlayStation 2 disc image.

---

## 📂 Repository Structure

```text
THDJRecomp/
├── .github/workflows/        # Automated CI builds (Linux & Windows .exe artifacts)
├── CMakeLists.txt            # Root cross-platform CMake build configuration
├── .recomp.json              # Game and recompilation metadata
├── config/                   # Default configuration templates (keys.ini.example)
├── covers/                   # Cover art, logos, and UI assets
├── patches/                  # Engine & runtime patches:
│   ├── modload_alloc_load_memory.patch       # IOP modload Alloc/FreeLoadMemory for EZPCM
│   └── thdj_disc_boot_memcard_bypass.patch   # Bypass boot QuickBasic memcard hang
├── tools/
│   ├── build.sh              # Linux / Parrot OS recompilation and build automation
│   ├── play.sh               # Native game launcher (Vulkan/wgpu windowed)
│   ├── apply_patches.sh      # Submodule patch applicator
│   └── build.bat             # Windows native build script
├── generated/                # (Git-ignored) Recompiled C++ translation units
└── third_party/
    └── ps2-native-recomp/    # PS2 Static Recompiler toolchain & runtime library
```

---

## 🛠️ Prerequisites

### Linux (Parrot OS / Debian / Ubuntu)
Install Clang, CMake, Ninja, and SDL2 development libraries:
```bash
sudo apt update
sudo apt install -y git clang cmake ninja-build libsdl2-dev pkg-config
```

### Windows
- [Git for Windows](https://git-scm.com/)
- [CMake](https://cmake.org/download/) (version 3.20+)
- [LLVM Clang](https://github.com/llvm/llvm-project/releases) or `llvm-mingw`
- [Ninja Build System](https://ninja-build.org/)

---

## 🚀 Building & Running

### 1. Clone with Submodules
```bash
git clone --recursive https://github.com/RHNT-FX/THDJ-RECOMP.git
cd THDJ-RECOMP
```

### 2. Apply Runtime Patches
```bash
./tools/apply_patches.sh
```

### 3. Recompiling & Building from your ISO (Linux)
Give executable permission to the build script and supply your legal game ISO:
```bash
chmod +x tools/*.sh
./tools/build.sh /path/to/downhill_jam.iso
```

### 4. Playing Natively
Launch the game directly with Vulkan rendering and controller support:
```bash
./tools/play.sh
```
*(Optionally pass a custom ISO path: `./tools/play.sh /path/to/game.iso`)*

---

## 🔧 Technical Patch Notes

- **Startup Memory Card Check Bypass (`patches/thdj_disc_boot_memcard_bypass.patch`):**
  At boot, `THDJ_Initial()` in Neversoft QB bytecode (`z_mainmenu_scripts.q` inside `DATAP.WAD`) enters `DoMemCardChecks` (`0x9643e815`). If `BootTime_MemCardChecks_Completed` (`0x29696c2d`) is `0`, the game displays the PlayStation 2 TCR compliance dialog and waits indefinitely for interactive events. The patch dynamically intercepts the sector read and marks `BootTime_MemCardChecks_Completed = 1`, allowing seamless transition directly into profile selection, autosave setup, and main menu navigation.
- **ModLoad AllocLoadMemory / FreeLoadMemory (`patches/modload_alloc_load_memory.patch`):**
  Implements IOP `modload` syscalls `#28` and `#29` needed for Supervillain's EZPCM audio streaming engine.

---

## 🎮 Controls Configuration
Copy the default config template:
```bash
cp config/keys.ini.example keys.ini
```
Edit `keys.ini` to customize your keyboard or controller bindings.

---

## 📜 Legal Disclaimer
Tony Hawk's Downhill Jam is a trademark of Activision Publishing, Inc. This project is a reverse engineering research endeavor and is not affiliated with, endorsed by, or sponsored by Activision, Toys for Bob, Visual Impact, or Sony Interactive Entertainment. All copyrighted material remains the property of their respective owners.
