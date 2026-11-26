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
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/config
    ${CMAKE_CURRENT_SOURCE_DIR}/patches
    ${SDL2_INCLUDE_DIRS}
)

# Native source files
file(GLOB_RECURSE THDJ_NATIVE_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/*.c
)

# Generated recompilation source files
file(GLOB_RECURSE RECOMP_GENERATED_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/generated/*.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/generated/*.c
)

set(RECOMP_SOURCES ${THDJ_NATIVE_SOURCES} ${RECOMP_GENERATED_SOURCES})

# Main Target Executable
add_executable(THDJRecomp ${RECOMP_SOURCES})

target_include_directories(THDJRecomp PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
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
