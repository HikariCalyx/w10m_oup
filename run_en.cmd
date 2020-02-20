@echo off
title  INITIAL - HCTSW Windows 10 Mobile Offline Updater V5.2
if not exist %systemroot%\system32\winload.exe (
echo.
echo ERROR: Your OS is unsupported. 
pause>nul
exit
)
cd %~dp0
if exist temp rd /s /q temp
if exist pkgs rd /s /q pkgs
md temp
md pkgs
set appver=1056
powershell -?>nul
if %errorlevel% equ 9009 (
echo.
echo ERROR: You don't have PowerShell enabled, or you're using
echo Lite Windows build.
echo.
echo Please enable PowerShell and try again.
pause>nul
exit
)
for /f %%a in ('powershell -Command "Get-Date -format yyyyMMdd_HHmmss"') do set timestamp=%%a
set path=%path%;%~dp0bin
rem echo %path%
title  VERIFY - HCTSW Windows 10 Mobile Offline Updater V5.2
rem selfcheck
echo.
echo Checking file integrity on server...
echo.
if not exist win10oup.exe goto errornameincorrect
bin\md5 -l -n win10oup.exe>temp\execmd5sum.txt
set /p md5sum=<temp\execmd5sum.txt
del temp\execmd5sum.txt
bin\wget -q -O temp\md5sum http://fds.hikaricalyx.com/win10oup/%appver%/md5sum
rem echo %errorlevel%
if "%errorlevel%"=="8" (
echo ERROR: This is unreleased executable! Where did you get that from?
echo.
echo Press any key to ignore this and continue.
echo.
pause>nul
goto bypass
)
if "%errorlevel%"=="4" (
echo ERROR: Server that verifies file corresponding can't be accessed.
echo You may continue, but we can't guarantee this tool came from
echo Hikari Calyx Tech correctly.
echo.
echo Press any key to ignore this and continue.
echo/
pause>nul
goto bypass
)
set /p emd5sum=<temp\md5sum
if not "%md5sum%"=="%emd5sum%" (
echo ERROR: This tool is tampered and we can't guarantee if it's
echo correct. You may continue.
echo.
echo IF YOU BOUGHT THIS FROM OTHERS, YOU'VE BEEN SCAMMED!
echo.
echo.Win10 OUP Project is never intent to be sold - you should ask
echo for refund or report reseller who sold you this package.
echo.
echo Press any key to ignore this and continue.
echo.
pause>nul
goto bypass
)
echo Verify pass! Thanks for supporting Hikari Calyx Tech.
echo.
:bypass
title WELCOME - HCTSW Windows 10 Mobile Offline Updater V5.2
if not exist logs md logs
echo.Support page:
echo.(Global) https://forum.xda-developers.com/windows-10-mobile/guide-win10-mobile-offline-update-t3527340
echo.(CN1) https://www.dospy.wang/thread-6363-1-1.html
echo.(CN2) https://bbs.letitfly.me/d/1056
echo.
echo Hi there! This tool is meant for Updating your Phone to
echo Windows 10 Mobile 10586.107.
echo.
echo This script is written by Hikari Calyx and will usable on
echo most of Windows Phone 8.1 devices.
echo.
echo IF YOU BOUGHT THIS FROM OTHERS, YOU'VE BEEN SCAMMED!
echo.
echo.Win10 OUP Project is never intent to be sold - you should ask
echo for refund or report reseller who sold you this package.
echo.
echo Press any key to proceed.
echo.
pause>nul
echo.
echo.
echo We've opened "Device and Printers" for you.
echo.
echo To ensure the tool will work as expect, please remove all of
echo your Windows Phones inside the list.
control printers
echo.
echo When you're done, press any key to proceed.
echo.
pause>nul
:wdrt1
echo.
echo Detecting if you have installed WDRT...
echo.
>nul reg query "HKCU\SOFTWARE\Microsoft\Care Suite\Windows Device Recovery Tool"
if %errorlevel%==1 (
echo.
echo.ERROR: You haven't install WDRT properly. We will direct you
echo.to the download page of WDRT.
echo.
start https://support.microsoft.com/help/12379/windows-10-mobile-device-recovery-tool-faq
echo Installed now? Press any key to try again.
pause>nul
goto wdrt1
)
echo Good, you have WDRT installed.
echo.
echo.Please connect your phone to PC, and press any key to if
echo.You have connected the phone properly to PC.
pause>nul
echo.
:modellisting
getdulogs -l
echo.
echo If your phone is listed above, input "yes" (without quotes)
echo.and press Enter to continue.
set /p econfirm=
if "%econfirm%"=="yes" goto next1
goto modellisting
:next1
set econfirm=0
title ANALYZE - HCTSW Windows 10 Mobile Offline Updater V5.2
echo.
echo Analyzing the phone, please wait...
echo.
getdulogs -o .\logs\log_%timestamp%.cab
if not exist ".\logs\log_%timestamp%.cab" (
echo.
echo ERROR: Package is not dumped properly. Please try again.
pause>nul
exit
)
>nul expand .\logs\log_%timestamp%.cab -F:InstalledPackages.csv temp\
>nul expand .\logs\log_%timestamp%.cab -F:DuTroubleshooting.reg temp\
>temp\mver.txt findstr /C:"\"MajorVersion\"=\"" temp\DuTroubleshooting.reg
set /p mver=<temp\mver.txt
del temp\mver.txt
set mver=%mver:~19,4%
if not exist temp\DuTroubleshooting.reg (
echo.
echo ERROR: Your phone currently has Windows 10 Mobile running,
echo thus this tool will not work for it.
pause>nul
exit
)
if %mver% equ "10" (
echo.
echo ERROR: Your phone currently has Windows 10 Mobile running,
echo thus this tool will not work for it.
pause>nul
exit
)
>temp\pbb.txt findstr /C:"\"ParentBranchBuild\"=\"" temp\DuTroubleshooting.reg
set /p pbb=<temp\pbb.txt
del temp\pbb.txt
set pbb=%pbb:~24,7%
if %pbb% lss "14219" (
echo.
echo ERROR: Your phone currently has build older than 8.10.14219.341
echo running, thus your phone can't be updated. Please update your
echo phone to this build first.
pause>nul
exit
)
findstr PhoneManufacturerModelName temp\DuTroubleshooting.reg>temp\pmmn.txt
set /p pmmn=<temp\pmmn.txt
set pmmn=%pmmn:~33,16%
findstr "RM-1017 RM-1018 RM-1019 RM-1020 W1- A62 E260 E8" temp\pmmn.txt
if %errorlevel% equ 0 set 4gbrom=1
findstr "C62 8X 6990LVW" temp\pmmn.txt
if %errorlevel% equ 0 set htc8x=1
findstr 0P6B1 temp\pmmn.txt
if %errorlevel% equ 0 (
set htcm8=1
set gsm=1
)
findstr 6995LVW temp\pmmn.txt
if %errorlevel% equ 0 (
set htcm8=1
set gsm=0
)
del temp\pmmn.txt
if "%4gbrom%"=="1" (
echo.
echo WARNING: You're trying to push packages to phones with only 4GB ROM.
echo.
echo Press any key to ignore this.
pause>nul
)
if "%htc8x%"=="1" (
echo.
echo WARNING: You're trying to push packages to HTC 8X.
echo It's almost unusable, or could kill your phone!
echo.
echo Press any key to ignore this.
pause>nul
)
findstr PhoneMobileOperatorName temp\DuTroubleshooting.reg>temp\pmon.txt
set /p pmon=<temp\pmon.txt
set pmon=%pmon:~30,8%
del temp\pmon.txt
echo.
echo Processing packages that will be pushed to the phone...
echo.
findstr Microsoft temp\InstalledPackages.csv>temp\pkglist1.txt
bin\awk -F, "{print $2}" temp\pkglist1.txt>temp\pkglist2.txt
>temp\pkglist3.txt findstr /V MMOSLOADER temp\pkglist2.txt
for /f %%i in (temp\pkglist3.txt) do echo copy repo\%%i.spk* pkgs\>>temp\pkgcopy.cmd
if "%htcm8%"=="1" (
findstr MS_NAVIGATIONBAR.MainOS_LANG pkglist3.txt>htcm8_navbarlist.txt
for /f %%i in (htcm8_navbarlist.txt) do echo copy repo\htcm8_navbar\%%i pkgs\>>temp\pkgcopy2.cmd
)
echo.
echo Copying packages, please wait...
>nul call temp\pkgcopy.cmd
del temp\pkgcopy.cmd
if "%htcm8%"=="1" (
>temp\copiedpkgs.txt dir /b pkgs\
findstr ms_navigationbar.mainos_lang temp\copiedpkgs.txt >temp\copiednavbar.txt 
for /f %%i in (temp\copiednavbar.txt) do echo del pkgs\%%i >>temp\delpkg.cmd
>nul temp\delpkg.cmd
>nul temp\pkgcopy2.cmd
if exist temp\pkgcopy2.cmd del temp\pkgcopy2.cmd
if "%gsm%"=="1" (
echo. Copying East Asian Language Packs...
echo.
>nul copy repo\microsoft.prerelease_protected.mainos_lang_zh* pkgs\
>nul copy repo\microsoft.prerelease_protected.mainos_lang_ja* pkgs\
>nul copy repo\microsoft.prerelease_protected.mainos_lang_ko* pkgs\
>nul copy repo\microsoft.mainos.production_lang_zh* pkgs\
>nul copy repo\microsoft.mainos.production_lang_ja* pkgs\
>nul copy repo\microsoft.mainos.production_lang_ko* pkgs\
)
)

title PUSHING - HCTSW Windows 10 Mobile Offline Updater V5.2
echo.
echo Pushing packages, please wait...
echo.
echo.Please wait patiently until the process complete.
iutool -V -p .\pkgs
echo.
echo All done. Please check if your phone is pushed successfully.
echo Thanks for supporting my work. 
echo.
echo Press any key to exit.
pause>nul
goto eof

:errornameincorrect
echo.
echo ERROR: Executable file name incorrect.
echo Please rename it to win10oup.exe before proceed.
pause>nul
goto eof

:eof
