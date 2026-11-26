#pragma once

#include <cstdint>
#include <cstddef>
#include <cstring>
#include <cstdio>

namespace thdj::patches {

// Neversoft / Supervillain QuickBasic Signature
// BootTime_MemCardChecks_Completed (QB Hash: 0x29696c2d)
inline constexpr std::uint8_t kBootMemCardSig[12] = {
    0x2d, 0x6c, 0x69, 0x29, 0xc4, 0x8a, 0x25, 0xdc, 0x00, 0x00, 0x00, 0x00
};

/**
 * Scans a disc sector buffer and applies the on-the-fly bypass
 * for the startup TCR memory card compliance hang.
 */
inline bool apply_boot_memcard_patch(std::uint8_t* buffer, std::size_t size, std::uint32_t sector) {
    if (!buffer || size < 12) return false;
    for (std::size_t i = 0; i + 12 <= size; ++i) {
        if (buffer[i] == 0x2d && std::memcmp(buffer + i, kBootMemCardSig, 12) == 0) {
            buffer[i + 8] = 0x01; // BootTime_MemCardChecks_Completed = 1
            std::fprintf(stderr, "[THDJRecomp] Patched BootTime_MemCardChecks_Completed = 1 at sector %u + %zu\n", sector, i);
            return true;
        }
    }
    return false;
}

} // namespace thdj::patches
