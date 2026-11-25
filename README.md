# 🛹 THDJRecomp: Tony Hawk's Downhill Jam PC Port

<p align="center">
  <b>Native Static Recompilation of <i>Tony Hawk's Downhill Jam</i> (PlayStation 2) for PC (Linux & Windows)</b><br>
  <i>Researched, reverse-engineered, and ported natively by RHNT-FX</i>
</p>

---

## 🎮 What is THDJRecomp? (For Everyone)

Have you ever wanted to play **Tony Hawk's Downhill Jam** on your modern PC without dealing with heavy emulator setup, frame drops, or input lag? 

**THDJRecomp is NOT an emulator.** 

Instead of running an emulator (like PCSX2) that pretends to be a PlayStation 2 console while eating up your CPU and battery, **THDJRecomp statically recompiles** the original PS2 machine code directly into modern C++ code.

In simple terms:
- **It runs like a real PC game:** Compiles directly into a native executable for Linux and Windows.
- **Buttery smooth 60 FPS:** Extreme performance with minimal CPU and GPU usage.
- **Modern Graphics Backend:** Powered by WebGPU & Vulkan with true widescreen aspect-ratio support.
- **Plug & Play Controllers:** Modern SDL2 gamepad and keyboard support right out of the box.

> **Note:** This repository **does NOT contain any copyrighted assets, ISO images, or proprietary game binaries**. Users must supply their own legally acquired PlayStation 2 disc image (*SLUS-21456* / CRC `7D13310A`).

---

## 🔍 Behind The Scenes: How I Solved the Startup Freeze

When I first booted the game natively, it launched cleanly at 60 FPS, but immediately got stuck on the infamous red screen:

> *"Checking memory card (8MB)(for PlayStation®2) in MEMORY CARD slot 1. Do not remove memory card (8MB)(for PlayStation®2), controller, or reset/switch off the console."*

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
Rather than modifying the user's original ISO file (which would alter file hashes and risk corruption), I engineered a real-time signature scanner in the disc reader (`runtime/src/disc.cpp`):
- As the game reads sectors from `DATAP.WAD`, the runtime scans for the signature of `BootTime_MemCardChecks_Completed`.
- When found, it automatically flips the byte from `0x00` to `0x01` directly in memory.
- **Result:** The game cleanly transitions from boot straight into "Pick Game to Load", "Autosave Setup", and the "ENTER NAME" keyboard profile screen!

In addition, I implemented missing IOP system calls (`AllocLoadMemory` #28 and `FreeLoadMemory` #29) to support the Supervillain EZPCM audio streaming engine.

---

## 🚀 Quick Start Guide (Beginner-Friendly)

### Step 1: Install Dependencies (Linux / Parrot OS / Ubuntu)
Open your terminal and run:
```bash
sudo apt update
sudo apt install -y git clang cmake ninja-build libsdl2-dev pkg-config
```

### Step 2: Clone the Project
```bash
git clone --recursive https://github.com/RHNT-FX/THDJ-RECOMP.git
cd THDJ-RECOMP
```

### Step 3: Apply the Patches
Run the patch applicator to automatically inject my boot & audio fixes:
```bash
./tools/apply_patches.sh
```

### Step 4: Play Natively!
Launch the game directly:
```bash
./tools/play.sh
```
*(You can also specify your own ISO: `./tools/play.sh /path/to/downhill_jam.iso`)*

---

## 🎮 Controls

The game supports standard gamepads (Xbox, PlayStation, 8BitDo) as well as keyboard controls:

| PS2 Action | Gamepad (Xbox / PS) | Keyboard |
| :--- | :--- | :--- |
| **Cross (A / Accept)** | A / ✕ | Space / Enter |
| **Circle (B / Back)** | B / ◯ | Escape / Backspace |
| **Square (Crouch / Drift)** | X / ▢ | Left Shift |
| **Triangle (Grind)** | Y / △ | W |
| **D-Pad / Analog** | D-Pad / Left Stick | Arrow Keys |
| **Pause / Menu** | Start / Options | Enter / P |

Custom keybindings can be configured in `config/keys.ini`.

---

## 📂 Project Structure

```text
THDJRecomp/
├── config/                   # Input mapping & configuration templates
├── covers/                   # Box art & visual assets
├── patches/                  # My custom engine & runtime fixes:
│   ├── modload_alloc_load_memory.patch       # IOP audio streaming memory fix
│   └── thdj_disc_boot_memcard_bypass.patch   # Startup memory card freeze bypass
├── tools/
│   ├── apply_patches.sh      # 1-click script to apply my fixes to the runtime
│   ├── play.sh               # Easy 1-click game launcher
│   ├── build.sh              # Full recompiler & build automation
│   └── build.bat             # Windows native build script
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
