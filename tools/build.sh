#!/usr/bin/env bash
set -e

# ==============================================================================
# THDJRecomp - Build and Recompile Automation Script (Linux / Parrot OS)
# ==============================================================================

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${PROJECT_ROOT}/build"
ISO_PATH="$1"

echo "========================================================"
echo "         THDJRecomp - Tony Hawk's Downhill Jam          "
echo "        Native PC Static Recompilation Pipeline         "
echo "========================================================"

# Check compiler
if command -v clang++ >/dev/null 2>&1; then
    export CC=clang
    export CXX=clang++
    echo "[✓] Using Clang compiler: $(clang++ --version | head -n 1)"
else
    echo "[!] Clang not found! Please run: sudo apt install clang"
    echo "[!] Falling back to standard g++ (may fail on PS2 vector builtins)."
fi

# Check CMake & Ninja
if ! command -v cmake >/dev/null 2>&1; then
    echo "[x] Error: cmake is required. Run: sudo apt install cmake"
    exit 1
fi

GENERATOR="Unix Makefiles"
if command -v ninja >/dev/null 2>&1; then
    GENERATOR="Ninja"
fi

# Step 1: Recompilation from ISO if provided
if [ -n "${ISO_PATH}" ]; then
    if [ ! -f "${ISO_PATH}" ]; then
        echo "[x] Error: ISO file '${ISO_PATH}' not found!"
        exit 1
    fi
    echo "[*] Processing PS2 ISO: ${ISO_PATH}"
    
    # Check if ps2-native-recomp submodule exists
    if [ ! -d "${PROJECT_ROOT}/third_party/ps2-native-recomp" ]; then
        echo "[*] Initializing ps2-native-recomp submodule..."
        git submodule update --init --recursive
    fi

    # Apply runtime patches
    if [ -f "${PROJECT_ROOT}/tools/apply_patches.sh" ]; then
        bash "${PROJECT_ROOT}/tools/apply_patches.sh"
    fi
    
    echo "[*] Translating PS2 MIPS instructions to C++..."
    mkdir -p "${PROJECT_ROOT}/generated"
    # Recompiler execution hook
    if [ -f "${PROJECT_ROOT}/third_party/ps2-native-recomp/scripts/port.sh" ]; then
        bash "${PROJECT_ROOT}/third_party/ps2-native-recomp/scripts/port.sh" thdj "${ISO_PATH}" --native-only
        
        # Compile recorded VU vector programs ahead-of-time (AOT)
        if [ -x "${PROJECT_ROOT}/third_party/ps2-native-recomp/build/tools/vurecomp" ]; then
            echo "[*] Translating PS2 Vector Unit programs (VU0/VU1) to native C++..."
            "${PROJECT_ROOT}/third_party/ps2-native-recomp/build/tools/vurecomp" \
                "${PROJECT_ROOT}/third_party/ps2-native-recomp/games/thdj/vu1" \
                "${PROJECT_ROOT}/third_party/ps2-native-recomp/generated/thdj" \
                --vu0-dir "${PROJECT_ROOT}/third_party/ps2-native-recomp/games/thdj/vu0" || true
        fi
    else
        echo "[i] Place recompiled translation units into '${PROJECT_ROOT}/generated/'"
    fi
else
    echo "[i] No ISO path specified. Running standard project build."
    echo "[i] Usage to recompile ISO: ./tools/build.sh /path/to/downhill_jam.iso"
fi

# Step 2: Build Native Executable
echo "[*] Configuring CMake (${GENERATOR})..."
cmake -B "${BUILD_DIR}" -G "${GENERATOR}" -DCMAKE_BUILD_TYPE=Release "${PROJECT_ROOT}"

echo "[*] Compiling THDJRecomp..."
cmake --build "${BUILD_DIR}" --config Release -j"$(nproc)"

echo "========================================================"
echo "[✓] Build completed successfully!"
echo "[✓] Binary output: ${BUILD_DIR}/bin/THDJRecomp"
echo "========================================================"
