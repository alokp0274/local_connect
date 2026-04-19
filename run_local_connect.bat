@echo off
setlocal

cd /d "%~dp0"

echo ==========================================
echo   LocalConnect Flutter Launcher
echo ==========================================
echo.

:: Ensure dependencies are up to date
echo [1/2] Checking dependencies...
call flutter pub get
if errorlevel 1 (
    echo ERROR: flutter pub get failed. Check your pubspec.yaml.
    pause
    exit /b 1
)

echo [2/2] Ready to launch!
echo.
echo ==========================================
echo   Select a launch target:
echo ==========================================
echo.
echo   1. Run on Windows desktop
echo      (Requires Developer Mode: start ms-settings:developers)
echo.
echo   2. Run on Edge browser (web)  [RECOMMENDED]
echo      Opens at http://localhost:5555
echo      (Auto-falls back to another port if 5555 is busy)
echo.
echo   3. Enable Windows Developer Mode (opens Settings)
echo.
echo   4. Auto device picker
echo.
echo   5. Run on Android device/emulator (ADB)
echo.
set /p choice=Select option (1/2/3/4/5): 

if "%choice%"=="1" goto run_windows
if "%choice%"=="2" goto run_edge
if "%choice%"=="3" goto enable_devmode
if "%choice%"=="4" goto run_auto
if "%choice%"=="5" goto run_android

echo Invalid option. Defaulting to Edge (web)...
goto run_edge

:check_symlink_support
set "SYMLINK_OK="
set "SYMLINK_TEST=%TEMP%\local_connect_symlink_test_%RANDOM%_%RANDOM%"
del /f /q "%SYMLINK_TEST%" >nul 2>nul
mklink "%SYMLINK_TEST%" "%~f0" >nul 2>nul
if not errorlevel 1 (
    set "SYMLINK_OK=1"
    del /f /q "%SYMLINK_TEST%" >nul 2>nul
)
exit /b 0

:run_windows
echo.
call :check_symlink_support
if not defined SYMLINK_OK (
    echo Windows desktop debug requires symbolic link support, but it is not available in this shell.
    echo Falling back to Edge debug so you can keep working immediately.
    echo.
    echo To restore Windows desktop debug:
    echo   1. Enable Developer Mode: start ms-settings:developers
    echo   2. Restart VS Code or open a new terminal
    echo   3. Run this launcher again and choose option 1
    echo.
    goto run_edge
)

echo Starting on Windows desktop...
echo TIP: If this fails with symlink error, choose option 3 to enable Developer Mode.
echo.
call flutter run -d windows
goto end

:run_edge
echo.
echo Starting on Edge browser at http://localhost:5555 ...
echo.
call flutter run -d edge --web-port=5555
if errorlevel 1 (
    echo.
    echo Port 5555 may be busy. Retrying on an automatic port...
    call flutter run -d edge
)
goto end

:enable_devmode
echo.
echo Opening Windows Developer Mode settings...
start ms-settings:developers
echo After enabling Developer Mode, restart this launcher and choose option 1.
echo.
pause
goto end

:run_auto
echo.
echo Starting with auto device picker...
echo.
call flutter run --web-port=5555
if errorlevel 1 (
    echo.
    echo Port 5555 may be busy. Retrying on an automatic port...
    call flutter run
)
goto end

:run_android
echo.
echo Starting Android mobile debugging...
echo.

:: Ensure ANDROID_SDK_ROOT is set
if not defined ANDROID_SDK_ROOT (
    if exist "%LOCALAPPDATA%\Android\Sdk" set "ANDROID_SDK_ROOT=%LOCALAPPDATA%\Android\Sdk"
)
if defined ANDROID_SDK_ROOT if not defined ANDROID_HOME set "ANDROID_HOME=%ANDROID_SDK_ROOT%"

:: Ensure Java is available for Gradle Android builds
where java >nul 2>nul
if errorlevel 1 (
    if not defined JAVA_HOME (
        :: Try machine-level JAVA_HOME from registry
        for /f "skip=2 tokens=1,2,*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v JAVA_HOME 2^>nul') do (
            if /I "%%A"=="JAVA_HOME" set "JAVA_HOME=%%C"
        )

        :: Try common JDK install folders
        if not defined JAVA_HOME if exist "C:\Program Files\Java" (
            for /f "delims=" %%J in ('dir /b /ad "C:\Program Files\Java\jdk-*" 2^>nul') do (
                if exist "C:\Program Files\Java\%%J\bin\java.exe" set "JAVA_HOME=C:\Program Files\Java\%%J"
            )
        )
        if not defined JAVA_HOME if exist "C:\Program Files\Eclipse Adoptium" (
            for /f "delims=" %%J in ('dir /b /ad "C:\Program Files\Eclipse Adoptium\jdk-*" 2^>nul') do (
                if exist "C:\Program Files\Eclipse Adoptium\%%J\bin\java.exe" set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\%%J"
            )
        )
        if not defined JAVA_HOME if exist "C:\Program Files\Android\Android Studio\jbr" (
            set "JAVA_HOME=C:\Program Files\Android\Android Studio\jbr"
        )
    )
    if defined JAVA_HOME if exist "%JAVA_HOME%\bin\java.exe" (
        echo Using JAVA_HOME: %JAVA_HOME%
        set "PATH=%JAVA_HOME%\bin;%PATH%"
    )
)

where java >nul 2>nul
if errorlevel 1 (
    echo WARNING: java command not found in current shell PATH.
    echo Continuing anyway - Flutter may still use a configured JDK.
    echo If build fails, set JAVA_HOME to your JDK 17 folder.
)

set "ADB_BIN="
set "SDK_BASE="
set "EMULATOR_BIN="
set "AVDMANAGER_BIN="
set "HAS_SYSTEM_IMAGES="
set "HAS_AVD="

if defined ANDROID_SDK_ROOT set "SDK_BASE=%ANDROID_SDK_ROOT%"
if not defined SDK_BASE if defined ANDROID_HOME set "SDK_BASE=%ANDROID_HOME%"
if not defined SDK_BASE if exist "%LOCALAPPDATA%\Android\Sdk" set "SDK_BASE=%LOCALAPPDATA%\Android\Sdk"

if defined SDK_BASE if exist "%SDK_BASE%\emulator\emulator.exe" set "EMULATOR_BIN=%SDK_BASE%\emulator\emulator.exe"
if defined SDK_BASE if exist "%SDK_BASE%\cmdline-tools\latest\bin\avdmanager.bat" set "AVDMANAGER_BIN=%SDK_BASE%\cmdline-tools\latest\bin\avdmanager.bat"
if defined SDK_BASE if not defined AVDMANAGER_BIN if exist "%SDK_BASE%\tools\bin\avdmanager.bat" set "AVDMANAGER_BIN=%SDK_BASE%\tools\bin\avdmanager.bat"
if defined SDK_BASE if exist "%SDK_BASE%\system-images" set "HAS_SYSTEM_IMAGES=1"
if exist "%USERPROFILE%\.android\avd" set "HAS_AVD=1"

:: 1) Prefer PATH
where adb >nul 2>nul
if not errorlevel 1 set "ADB_BIN=adb"

:: 2) Try Android SDK env vars
if not defined ADB_BIN if defined ANDROID_SDK_ROOT (
    if exist "%ANDROID_SDK_ROOT%\platform-tools\adb.exe" set "ADB_BIN=%ANDROID_SDK_ROOT%\platform-tools\adb.exe"
)
if not defined ADB_BIN if defined ANDROID_HOME (
    if exist "%ANDROID_HOME%\platform-tools\adb.exe" set "ADB_BIN=%ANDROID_HOME%\platform-tools\adb.exe"
)

:: 3) Try common Windows SDK install locations
if not defined ADB_BIN if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" set "ADB_BIN=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
if not defined ADB_BIN if exist "%USERPROFILE%\AppData\Local\Android\sdk\platform-tools\adb.exe" set "ADB_BIN=%USERPROFILE%\AppData\Local\Android\sdk\platform-tools\adb.exe"

if not defined ADB_BIN (
    echo ERROR: adb not found.
    echo.
    echo Quick fix steps:
    echo   1. Install Android Studio, then install Android SDK Platform-Tools.
    echo   2. Or install standalone Platform-Tools from Google.
    echo   3. Set either ANDROID_SDK_ROOT or ANDROID_HOME to your SDK folder.
    echo      Example: C:\Users\%USERNAME%\AppData\Local\Android\Sdk
    echo   4. Add this to PATH: ^<SDK^>\platform-tools
    echo.
    echo After setup, re-run this launcher and choose option 5.
    goto end
)

echo Using ADB: %ADB_BIN%

call "%ADB_BIN%" start-server >nul 2>nul

set hasDevice=
set firstDevice=
set hasUnauthorized=
set unauthorizedDevice=
set hasOffline=
set offlineDevice=
echo Connected Android devices:
for /f "skip=1 tokens=1,2" %%A in ('"%ADB_BIN%" devices') do (
    if "%%A"=="" goto android_list_done
    if "%%B"=="device" (
        echo   - %%A
        if not defined firstDevice set "firstDevice=%%A"
        set hasDevice=1
    )
    if "%%B"=="unauthorized" (
        echo   - %%A ^(unauthorized^)
        if not defined unauthorizedDevice set "unauthorizedDevice=%%A"
        set hasUnauthorized=1
    )
    if "%%B"=="offline" (
        echo   - %%A ^(offline^)
        if not defined offlineDevice set "offlineDevice=%%A"
        set hasOffline=1
    )
)

:android_list_done
if defined hasUnauthorized if not defined hasDevice (
    echo.
    echo Your Android device is connected but not authorized for ADB yet.
    echo.
    echo Fix steps on phone and PC:
    echo   1. Keep USB connected and unlock the phone screen.
    echo   2. Tap "Allow USB debugging" and check "Always allow from this computer".
    echo   3. If no popup appears: in Developer options, tap "Revoke USB debugging authorizations", then reconnect USB.
    echo   4. On PC, run: adb kill-server ^&^& adb start-server
    echo   5. Re-run this launcher and choose option 5.
    echo.
    goto end
)

if defined hasOffline if not defined hasDevice (
    echo.
    echo Android device is detected as offline.
    echo Try unplugging/replugging USB, switching USB mode to File Transfer, and re-running option 5.
    echo.
    goto end
)

if not defined hasDevice (
    echo No Android device/emulator detected.
    echo Connect a phone with USB debugging enabled or start an emulator.
    echo.
    if not defined EMULATOR_BIN (
        echo Android Emulator is not installed in your SDK.
    )
    if not defined HAS_SYSTEM_IMAGES (
        echo No Android system images are installed.
    )
    if not defined HAS_AVD (
        echo No Android Virtual Device ^(AVD^) has been created yet.
    )
    echo.
    echo Quick fix steps:
    echo   1. Install Android Studio if it is not already installed.
    echo   2. In SDK Manager, install:
    echo      - Android Emulator
    echo      - Android SDK Platform-Tools
    echo      - At least one Android system image ^(for example API 34 Google APIs x86_64^)
    echo   3. In Device Manager, create a new virtual device.
    echo   4. Start that emulator, then re-run this launcher and choose option 5.
    echo.
    if defined EMULATOR_BIN if defined HAS_AVD (
        echo Installed AVDs:
        dir /b "%USERPROFILE%\.android\avd\*.ini" 2>nul
        echo.
        call flutter emulators
    )
    goto end
)

echo.
set /p androidId=Enter Android device ID (or press Enter for auto target): 
if "%androidId%"=="" (
    if defined firstDevice (
        echo Auto-selected device: %firstDevice%
        call flutter run -d %firstDevice%
    ) else (
        echo ERROR: Could not auto-select an Android device ID.
    )
) else (
    call flutter run -d %androidId%
)
goto end

:end
echo.
echo ==========================================
echo   Launcher finished.
echo ==========================================
pause
endlocal
