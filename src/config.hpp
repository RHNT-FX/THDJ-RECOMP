#pragma once

#include <cstdint>
#include <string_view>

namespace thdj {

// Target PlayStation 2 Title Metadata
constexpr std::string_view kGameTitle = "Tony Hawk's Downhill Jam";
constexpr std::string_view kSerial = "SLUS-21456";
constexpr std::uint32_t kDiscCRC = 0x7D13310A;

// Engine & Display Defaults
constexpr int kDefaultWidth = 640;
constexpr int kDefaultHeight = 448;
constexpr double kTargetFPS = 60.0;
constexpr double kWidescreenAspect = 16.0 / 9.0;
constexpr double kStandardAspect = 4.0 / 3.0;

// Memory Card defaults
constexpr std::string_view kDefaultMemcardName = "thdj.ps2";

} // namespace thdj
