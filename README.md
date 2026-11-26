# 🛹 THDJRecomp: Tony Hawk's Downhill Jam PC Port

<p align="center">
  <b>Native Static Recompilation of <i>Tony Hawk's Downhill Jam</i> (PlayStation 2) for Windows & Linux</b><br>
  <i>Researched, reverse-engineered, and ported natively by RHNT-FX</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Windows%20%7C%20Linux-blue?style=flat-square" alt="Platform" />
  <img src="https://img.shields.io/badge/Language-C%2B%2B20-orange?style=flat-square" alt="Language" />
  <img src="https://img.shields.io/badge/Target-SLUS--21456-green?style=flat-square" alt="Target" />
  <img src="https://img.shields.io/badge/Renderer-WebGPU%20%2F%20Vulkan%20%2F%20D3D12-purple?style=flat-square" alt="Graphics" />
</p>

---

## 🎮 What is THDJRecomp? (For Everyone)

Have you ever wanted to play **Tony Hawk's Downhill Jam** on your modern PC without dealing with heavy emulator setup, frame drops, or input lag?

**THDJRecomp is NOT an emulator.**

Instead of running an emulator (like PCSX2) that pretends to be a PlayStation 2 console while eating up your CPU and battery, **THDJRecomp statically recompiles** the original PS2 machine code directly into modern C++ code.

In simple terms:
- **It runs like a real PC game:** Compiles directly into a native `.exe` (Windows) or binary (Linux).
- **Buttery smooth 60 FPS:** Extreme performance with minimal CPU and GPU usage.
- **Modern Graphics Backend:** Powered by WebGPU, Vulkan, and Direct3D 12 with native widescreen support.
- **Plug & Play Controllers:** Modern SDL2 gamepad and keyboard support right out of the box.

---

## 💿 Bring Your Own Game (Legal Requirement)

Like other open-source recompilation projects (*Zelda64Recomp*, *MC1Recomp*, *Jak Project*), **this repository contains NO copyrighted assets, ISO images, game models, or proprietary game code**.

To play, you must supply your own legal dump of the PlayStation 2 game disc:
- **Title:** *Tony Hawk's Downhill Jam (USA)*
- **Serial:** `SLUS-21456`
- **CRC32:** `7D13310A`
- **Format:** `.iso` (Standard 2048-byte sector PS2 DVD image)

You can place your dump directly in the project folder named `disc.iso`, or pass the file path directly to the launcher script.

---

## 🚀 Getting Started

### 🪟 Windows (10 / 11)

#### 1. Prerequisites
- [Git for Windows](https://git-scm.com/)
- [CMake](https://cmake.org/download/) (version 3.20+)
- [LLVM Clang](https://github.com/llvm/llvm-project/releases) (or install via `winget install LLVM.LLVM`)
- [Ninja Build System](https://ninja-build.org/) (optional, recommended)

#### 2. Clone the Repository
Open Command Prompt or PowerShell:
```cmd
git clone --recursive https://github.com/RHNT-FX/THDJ-RECOMP.git
cd THDJ-RECOMP
```

#### 3. Build the Executable
Run the automated Windows batch builder:
```cmd
tools\build.bat
```

#### 4. Play!
Drag and drop your legal ISO onto `play.bat` or run:
```cmd
tools\play.bat "C:\path\to\Tony Hawks Downhill Jam (USA).iso"
```

---

### 🐧 Linux (Parrot OS / Ubuntu / Debian / Arch)

#### 1. Prerequisites
Install Clang, CMake, Ninja, and SDL2 development headers:
```bash
sudo apt update
sudo apt install -y git clang cmake ninja-build libsdl2-dev pkg-config
```

#### 2. Clone the Repository
```bash
git clone --recursive https://github.com/RHNT-FX/THDJ-RECOMP.git
cd THDJ-RECOMP
```

#### 3. Apply Engine Patches & Build
```bash
chmod +x tools/*.sh
./tools/apply_patches.sh
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build
```

#### 4. Play!
```bash
./tools/play.sh /path/to/downhill_jam.iso
```

---

## 🔍 Behind The Scenes: How I Solved the Startup Freeze

When I first booted the game natively, it launched cleanly at 60 FPS, but immediately got stuck on the infamous red screen:

> *"Checking memory card (8MB)(for PlayStation®2) in MEMORY CARD slot 1. Do not remove memory card..."*

No matter what buttons were pressed, the game refused to proceed. Here is how I investigated, reverse-engineered, and solved the issue:

### 1. Digging into the Game's Scripting Engine
I analyzed the filesystem of *Tony Hawk's Downhill Jam* (`DATAP.WAD` and `STREAMP.WAD`). Under the hood, the game relies on Neversoft & Supervillain's **QuickBasic (QB) bytecode engine** (`qb.pak`) to control everything from UI menus to game states.

### 2. Identifying the Culprit Script
By tracing the game's startup sequence inside `z_mainmenu_scripts.q`, I located the entry point `THDJ_Initial()`. Before showing any 3D graphics or main menu buttons, the engine calls a verification function: `DoMemCardChecks` (checksum hash `0x9643e815`).

### 3. The Infinite Loop Discovery
Inspecting `DoMemCardChecks`, I found it checks a global QuickBasic variable:
```c
BootTime_MemCardChecks_Completed (Hash: 0x29696c2d)
```
- When `BootTime_MemCardChecks_Completed == 0`: The game displays the red compliance warning dialog and enters a `wait` loop waiting for low-level PS2 interrupt callbacks that do not exist on a native PC runtime. The game freezes forever.
- When `BootTime_MemCardChecks_Completed == 1`: The function executes `if (BootTime_MemCardChecks_Completed == 1) return true;` immediately, bypassing the wait loop and transitioning smoothly to the profile creation screen!

### 4. The Solution: Dynamic On-The-Fly Disc Patch
Rather than modifying the user's original ISO file (which would alter file hashes and risk corruption), I engineered a real-time signature scanner in the disc reader (`patches/thdj_disc_boot_memcard_bypass.patch`):
- As the game reads sectors from `DATAP.WAD`, the runtime scans for the signature of `BootTime_MemCardChecks_Completed`.
- When found, it automatically flips the byte from `0x00` to `0x01` directly in memory.
- **Result:** The game cleanly transitions from boot straight into "Pick Game to Load", "Autosave Setup", and the "ENTER NAME" keyboard profile screen!

In addition, I implemented missing IOP system calls (`AllocLoadMemory` #28 and `FreeLoadMemory` #29 in `patches/modload_alloc_load_memory.patch`) to support the Supervillain EZPCM audio streaming engine.

---

## 🎮 Controls

The game supports standard gamepads (Xbox, PlayStation, 8BitDo) as well as keyboard controls:

| PS2 Action | Gamepad (Xbox / PS) | Keyboard |
| :--- | :--- | :--- |
| **Cross (A / Accept)** | A / ✕ | Space / Enter |
| **Circle (B / Back)** | B / ◯ | E / Escape |
| **Square (Crouch / Drift)** | X / ▢ | Left Mouse / Left Shift |
| **Triangle (Grind)** | Y / △ | Right Mouse / W |
| **D-Pad / Analog** | D-Pad / Left Stick | Arrow Keys / WASD |
| **Pause / Menu** | Start / Options | Esc / P |

> 💡 **Tip:** Custom keybindings can be configured in `config/keys.ini`. For low input latency, `PS2_FRAME_LATENCY=1` is enabled by default in the launchers.

---

## 📂 Project Architecture

```text
THDJRecomp/
├── src/                      # Native C++ Port Core & Launcher
│   ├── main.cpp              # Cross-platform entry point, CLI parser & runner
│   ├── config.hpp            # Game metadata, resolution & video aspect definitions
│   └── patches.hpp           # On-the-fly signature patch scanner
├── config/                   # Input mapping & controller configuration templates
├── covers/                   # Box art & visual assets
├── patches/                  # Standalone runtime diff patches:
│   ├── modload_alloc_load_memory.patch       # IOP audio streaming memory fix
│   └── thdj_disc_boot_memcard_bypass.patch   # Startup memory card freeze bypass
├── tools/                    # One-click developer automation:
│   ├── build.bat / build.sh  # Native compilers for Windows & Linux
│   ├── play.bat / play.sh    # Low-latency one-click game launchers
│   └── apply_patches.sh      # Submodule patch applicator
└── third_party/
    └── ps2-native-recomp/    # PS2 Static Recompiler toolchain & runtime
```

---

## 👤 Author & Research
- **RHNT-FX** — Reverse engineering, QuickBasic script decompilation, memory card bypass patch, and native port integration.
- Powered by the [ps2-native-recomp](https://github.com/exoteric33/ps2-native-recomp) toolchain.

---

## 📜 Legal Disclaimer
Tony Hawk's Downhill Jam is a trademark of Activision Publishing, Inc. This project is a non-profit reverse-engineering research project. No copyrighted assets, proprietary game ISOs, or game binaries are distributed in this repository. Please support the original creators by using your legally owned copy of the game.
