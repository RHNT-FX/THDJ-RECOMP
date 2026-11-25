#!/usr/bin/env bash
set -e

# ==============================================================================
# THDJRecomp - Apply Required Runtime Patches to ps2-native-recomp
# ==============================================================================

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PATCHES_DIR="${PROJECT_ROOT}/patches"
SUBMODULE_DIR="${PROJECT_ROOT}/third_party/ps2-native-recomp"

if [ ! -d "${SUBMODULE_DIR}" ]; then
    echo "[!] Initializing ps2-native-recomp submodule..."
    git submodule update --init --recursive
fi

echo "=========================================================="
echo "    Applying THDJ Patches to ps2-native-recomp Runtime    "
echo "=========================================================="

for patch in "${PATCHES_DIR}"/*.patch; do
    if [ -f "$patch" ]; then
        pname="$(basename "$patch")"
        if git -C "${SUBMODULE_DIR}" apply --check "$patch" >/dev/null 2>&1; then
            git -C "${SUBMODULE_DIR}" apply "$patch"
            echo "[✓] Applied: ${pname}"
        else
            echo "[-] Skipped (already applied or modified): ${pname}"
        fi
    fi
done

echo "=========================================================="
echo "[✓] Patches check complete."
echo "=========================================================="
