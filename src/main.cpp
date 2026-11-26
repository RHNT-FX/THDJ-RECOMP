#include "config.hpp"
#include "patches.hpp"
#include <iostream>
#include <string>
#include <vector>
#include <filesystem>
#include <cstdlib>

#if __has_include(<SDL.h>)
#include <SDL.h>
#elif __has_include(<SDL2/SDL.h>)
#include <SDL2/SDL.h>
#endif

namespace fs = std::filesystem;

static void print_banner() {
    std::cout << "==========================================================\n";
    std::cout << "   " << thdj::kGameTitle << " (" << thdj::kSerial << ")\n";
    std::cout << "   Native PC Static Recompilation Port\n";
    std::cout << "==========================================================\n";
}

static void print_usage(const char* prog) {
    std::cout << "Usage:\n";
    std::cout << "  " << prog << " [path/to/game.iso] [options]\n\n";
    std::cout << "Options:\n";
    std::cout << "  --disc <iso>       Path to legal game ISO image\n";
    std::cout << "  --memcard <card>   Path to memory card file (default: " << thdj::kDefaultMemcardName << ")\n";
    std::cout << "  --window           Launch in windowed mode\n";
    std::cout << "  --fullscreen       Launch in fullscreen mode\n";
    std::cout << "  --widescreen       Enable 16:9 widescreen presentation\n";
    std::cout << "  --help             Show this help message\n";
}

int main(int argc, char* argv[]) {
    print_banner();

    std::string disc_path;
    std::string memcard_path = std::string(thdj::kDefaultMemcardName);
    bool windowed = true;
    bool widescreen = true;

    for (int i = 1; i < argc; ++i) {
        std::string arg = argv[i];
        if (arg == "--help" || arg == "-h") {
            print_usage(argv[0]);
            return 0;
        } else if (arg == "--disc" && i + 1 < argc) {
            disc_path = argv[++i];
        } else if (arg == "--memcard" && i + 1 < argc) {
            memcard_path = argv[++i];
        } else if (arg == "--window") {
            windowed = true;
        } else if (arg == "--fullscreen") {
            windowed = false;
        } else if (arg == "--widescreen") {
            widescreen = true;
        } else if (disc_path.empty() && !arg.starts_with("-")) {
            disc_path = arg;
        }
    }

    // Check project root / default locations if not provided
    if (disc_path.empty()) {
        const std::vector<std::string> candidates = {
            "Tony Hawks Downhill Jam (USA).iso",
            "disc.iso",
            "games/thdj/disc.iso",
            "third_party/ps2-native-recomp/games/thdj/disc.iso"
        };
        for (const auto& c : candidates) {
            if (fs::exists(c)) {
                disc_path = c;
                break;
            }
        }
    }

    if (disc_path.empty() || !fs::exists(disc_path)) {
        std::cerr << "[!] Error: PlayStation 2 game disc image not found!\n";
        std::cerr << "[i] Please supply your legally dumped copy of " << thdj::kGameTitle << " (" << thdj::kSerial << ").\n";
        std::cerr << "[i] Example: " << argv[0] << " /path/to/downhill_jam.iso\n\n";
        print_usage(argv[0]);
        return 1;
    }

    std::cout << "[*] Selected Disc: " << disc_path << "\n";
    std::cout << "[*] Memory Card:   " << memcard_path << "\n";
    std::cout << "[*] Mode:          " << (windowed ? "Windowed" : "Fullscreen") 
              << " | Widescreen: " << (widescreen ? "ON" : "OFF") << "\n";

    // Set lower frame latency environment variable for snappy input
    #if defined(_WIN32)
    _putenv("PS2_FRAME_LATENCY=1");
    #else
    setenv("PS2_FRAME_LATENCY", "1", 1);
    #endif

    // Locate ps2run runtime executable
    std::string runtime_exe;
    #if defined(_WIN32)
    const std::vector<std::string> run_candidates = {
        "third_party\\ps2-native-recomp\\build\\native-thdj\\ps2run.exe",
        "bin\\ps2run.exe",
        "ps2run.exe"
    };
    #else
    const std::vector<std::string> run_candidates = {
        "third_party/ps2-native-recomp/build/native-thdj/ps2run",
        "bin/ps2run",
        "./ps2run"
    };
    #endif

    for (const auto& r : run_candidates) {
        if (fs::exists(r)) {
            runtime_exe = r;
            break;
        }
    }

    if (!runtime_exe.empty()) {
        std::cout << "[*] Executing runtime: " << runtime_exe << "\n";
        std::string cmd = runtime_exe + " --disc \"" + disc_path + "\"";
        if (windowed) cmd += " --window";
        if (widescreen) cmd += " --widescreen";
        if (!memcard_path.empty()) cmd += " --memcard \"" + memcard_path + "\"";
        return std::system(cmd.c_str());
    }

    std::cout << "[✓] THDJRecomp native bootstrap ready.\n";
    return 0;
}
