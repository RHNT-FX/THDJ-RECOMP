@echo off
setlocal enabledelayedexpansion

echo ========================================================
echo          THDJRecomp - Tony Hawk's Downhill Jam          
echo          Windows Native Build and Packaging             
echo ========================================================

set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR%..
set BUILD_DIR=%PROJECT_ROOT%\build

if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

where clang++ >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo [OK] Clang compiler detected.
    set CC=clang
    set CXX=clang++
) else (
    echo [WARN] Clang not found in PATH! Make sure LLVM or llvm-mingw is installed.
)

where ninja >nul 2>&1
if %ERRORLEVEL% equ 0 (
    set GENERATOR=Ninja
) else (
    set GENERATOR=MinGW Makefiles
)

echo [*] Configuring CMake (%GENERATOR%)...
cmake -B "%BUILD_DIR%" -G "%GENERATOR%" -DCMAKE_BUILD_TYPE=Release "%PROJECT_ROOT%"
if %ERRORLEVEL% neq 0 (
    echo [FAIL] CMake configuration failed!
    exit /b %ERRORLEVEL%
)

echo [*] Compiling THDJRecomp.exe...
cmake --build "%BUILD_DIR%" --config Release
if %ERRORLEVEL% neq 0 (
    echo [FAIL] Compilation failed!
    exit /b %ERRORLEVEL%
)

echo ========================================================
echo [OK] Build complete! Executable located at:
echo %BUILD_DIR%\bin\THDJRecomp.exe
echo ========================================================
pause
