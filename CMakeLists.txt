cmake_minimum_required(VERSION 3.20)
project(THDJRecomp VERSION 0.1.0 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Enforce Clang compiler requirement for vector extensions / builtins
if(NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    message(WARNING "PS2Recomp toolchains heavily utilize Clang vector builtins. Clang is strongly recommended!")
endif()

# Output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# Options
option(THDJ_ENABLE_WGPU "Enable WebGPU (Vulkan/D3D12) backend" ON)
option(THDJ_BUILD_LAUNCHER "Build embedded launcher UI" ON)

# Dependencies
find_package(PkgConfig QUIET)
find_package(SDL2 REQUIRED)

# Include directories
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/config
    ${CMAKE_CURRENT_SOURCE_DIR}/patches
    ${SDL2_INCLUDE_DIRS}
)

# Generated recompilation source files
file(GLOB_RECURSE RECOMP_GENERATED_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/generated/*.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/generated/*.c
)

# Placeholder sources if generated/ is not yet populated
if(NOT RECOMP_GENERATED_SOURCES)
    message(STATUS "No generated recompiled sources found yet in 'generated/'. Adding stub runner for build validation.")
    file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/stub_entry.cpp
        "#include <iostream>\n"
        "#include <SDL.h>\n"
        "int main(int argc, char* argv[]) {\n"
        "    std::cout << \"[THDJRecomp] Tony Hawk's Downhill Jam PC Port Initialized.\\n\";\n"
        "    std::cout << \"[THDJRecomp] Run tools/build.sh with your PS2 ISO to generate recompiled sources.\\n\";\n"
        "    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_GAMECONTROLLER) != 0) {\n"
        "        std::cerr << \"SDL_Init failed: \" << SDL_GetError() << \"\\n\";\n"
        "        return 1;\n"
        "    }\n"
        "    std::cout << \"[THDJRecomp] SDL2 initialized successfully.\\n\";\n"
        "    SDL_Quit();\n"
        "    return 0;\n"
        "}\n"
    )
    set(RECOMP_SOURCES ${CMAKE_CURRENT_BINARY_DIR}/stub_entry.cpp)
else()
    set(RECOMP_SOURCES ${RECOMP_GENERATED_SOURCES})
endif()

# Main Target Executable
add_executable(THDJRecomp ${RECOMP_SOURCES})

target_include_directories(THDJRecomp PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/patches
    ${CMAKE_CURRENT_SOURCE_DIR}/generated
)

target_link_libraries(THDJRecomp PRIVATE
    ${SDL2_LIBRARIES}
)

if(WIN32)
    target_link_libraries(THDJRecomp PRIVATE ws2_32 winmm)
elseif(UNIX AND NOT APPLE)
    target_link_libraries(THDJRecomp PRIVATE pthread dl m)
endif()

message(STATUS "Configured THDJRecomp for ${CMAKE_SYSTEM_NAME} (${CMAKE_BUILD_TYPE})")
