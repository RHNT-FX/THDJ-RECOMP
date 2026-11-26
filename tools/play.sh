#!/usr/bin/env bash
set -e

# ==============================================================================
# THDJRecomp - Launch Game Natively on Linux (Parrot OS / Ubuntu / Debian)
# ==============================================================================

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PS2RUN="${PROJECT_ROOT}/third_party/ps2-native-recomp/build/native-thdj/ps2run"
GAME_DIR="${PROJECT_ROOT}/third_party/ps2-native-recomp/games/thdj"
DISC_ISO="${GAME_DIR}/disc.iso"
MEMCARD="${GAME_DIR}/thdj.ps2"

# Check argument
if [ -n "$1" ] && [ -f "$1" ]; then
    DISC_ISO="$1"
    shift
fi

# Auto-detect ISO in project root if not in game folder
if [ ! -f "${DISC_ISO}" ]; then
    if [ -f "${PROJECT_ROOT}/Tony Hawks Downhill Jam (USA).iso" ]; then
        DISC_ISO="${PROJECT_ROOT}/Tony Hawks Downhill Jam (USA).iso"
    elif [ -f "${PROJECT_ROOT}/disc.iso" ]; then
        DISC_ISO="${PROJECT_ROOT}/disc.iso"
    fi
fi

if [ ! -f "${PS2RUN}" ]; then
    echo "[x] Error: Native executable not found at: ${PS2RUN}"
    echo "[!] Run recompilation first using ./tools/build.sh"
    exit 1
fi

if [ ! -f "${DISC_ISO}" ]; then
    echo "=========================================================="
    echo "[x] Error: Game ISO not found!"
    echo "=========================================================="
    echo "[i] Please supply your legally dumped copy of:"
    echo "    Tony Hawk's Downhill Jam (USA) (SLUS-21456)"
    echo ""
    echo "[i] Place your ISO in the project root named 'disc.iso' or pass it directly:"
    echo "    ./tools/play.sh /path/to/your_game.iso"
    echo "=========================================================="
    exit 1
fi

echo "=========================================================="
echo "    Launching Tony Hawk's Downhill Jam Native PC Port     "
echo "=========================================================="
echo "[*] Windowed Mode | Widescreen: ON | Renderer: Vulkan (wgpu)"
echo "[*] Low Latency Mode: ON (PS2_FRAME_LATENCY=1)"
echo "[*] Disc Image: ${DISC_ISO}"
echo "[*] Memory Card: ${MEMCARD}"
echo "=========================================================="

export PS2_FRAME_LATENCY=1

exec "${PS2RUN}" \
    --disc "${DISC_ISO}" \
    --window \
    --widescreen \
    --game-dir "${GAME_DIR}" \
    --memcard "${MEMCARD}" \
    "$@"
