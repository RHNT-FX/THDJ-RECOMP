@echo off
setlocal enabledelayedexpansion

:: ==============================================================================
:: THDJRecomp - Launch Game Natively on Windows
:: ==============================================================================

set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR%..
set PS2RUN=%PROJECT_ROOT%\third_party\ps2-native-recomp\build\native-thdj\ps2run.exe
set GAME_DIR=%PROJECT_ROOT%\third_party\ps2-native-recomp\games\thdj
set DISC_ISO=%GAME_DIR%\disc.iso
set MEMCARD=%GAME_DIR%\thdj.ps2

:: Check command-line argument for ISO path
if not "%~1"=="" (
    if exist "%~1" (
        set DISC_ISO=%~1
    )
)

:: Auto-detect ISO in project root if not in game folder
if not exist "%DISC_ISO%" (
    if exist "%PROJECT_ROOT%\Tony Hawks Downhill Jam (USA).iso" (
        set DISC_ISO=%PROJECT_ROOT%\Tony Hawks Downhill Jam (USA).iso
    ) else if exist "%PROJECT_ROOT%\disc.iso" (
        set DISC_ISO=%PROJECT_ROOT%\disc.iso
    )
)

if not exist "%PS2RUN%" (
    echo [x] Error: Native executable not found at: %PS2RUN%
    echo [!] Please build the project first using tools\build.bat or download the latest release.
    pause
    exit /b 1
)

if not exist "%DISC_ISO%" (
    echo ==========================================================
    echo [x] Error: Game ISO not found!
    echo ==========================================================
    echo [i] Please supply your legally dumped copy of:
    echo     Tony Hawk's Downhill Jam (USA) (SLUS-21456)
    echo.
    echo [i] Place your ISO in the project root named 'disc.iso' or pass it directly:
    echo     tools\play.bat "C:\path\to\your_game.iso"
    echo ==========================================================
    pause
    exit /b 1
)

echo ==========================================================
echo     Launching Tony Hawk's Downhill Jam Native PC Port     
echo ==========================================================
echo [*] Windowed Mode ^| Widescreen: ON ^| Renderer: Vulkan / D3D12
echo [*] Low Latency Mode: ON (PS2_FRAME_LATENCY=1)
echo [*] Disc Image: %DISC_ISO%
echo [*] Memory Card: %MEMCARD%
echo ==========================================================

set PS2_FRAME_LATENCY=1

"%PS2RUN%" ^
    --disc "%DISC_ISO%" ^
    --window ^
    --widescreen ^
    --game-dir "%GAME_DIR%" ^
    --memcard "%MEMCARD%" ^
    %*

if %ERRORLEVEL% neq 0 (
    echo [!] Game exited with error code %ERRORLEVEL%
    pause
)
