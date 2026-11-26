#!/usr/bin/env bash
set -e

# ==============================================================================
# THDJRecomp - Launch Game Natively on Linux (Parrot OS)
# ==============================================================================

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PS2RUN="${PROJECT_ROOT}/third_party/ps2-native-recomp/build/native-thdj/ps2run"
GAME_DIR="${PROJECT_ROOT}/third_party/ps2-native-recomp/games/thdj"
DISC_ISO="${GAME_DIR}/disc.iso"
MEMCARD="${GAME_DIR}/thdj.ps2"

if [ -n "$1" ] && [ -f "$1" ]; then
    DISC_ISO="$1"
    shift
fi

if [ ! -f "${PS2RUN}" ]; then
    echo "[x] Error: Native executable not found at: ${PS2RUN}"
    echo "[!] Run recompilation first."
    exit 1
fi

echo "=========================================================="
echo "    Launching Tony Hawk's Downhill Jam Native PC Port     "
echo "=========================================================="
echo "[*] Windowed Mode | Widescreen: ON | Renderer: Vulkan (wgpu)"
echo "[*] Low Latency Mode: ON (PS2_FRAME_LATENCY=1)"
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
