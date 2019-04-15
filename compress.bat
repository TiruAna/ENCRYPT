@echo off

Title compress_rar_rev3.bat

REM updated 12/13/2017

REM This script compresses files in a folder specified by the user 
REM individually or into a single archive in *.rar format (WinRAR's default) 
REM with the option to include subfolders. Saved files are placed in the  
REM specified directory unless otherwise noted. Files with same name but 
REM different exts overwritten by last task for options 1 and 2
REM Option 4 is the most commonly used option

setlocal

REM Specify the folder to compress below:

REM --------------------- Folder to compress -----------------------------------
set dir="C:\Folder4\Folder3\Folder2\Folder 1\Folder"
REM ----------------------------------------------------------------------------

REM Path to WinRAR executable in Program Files. Change if location is different
REM ---------------------- WinRAR Directory ------------------------------------
set path="C:\Program Files\WinRAR\";%path%
REM ----------------------------------------------------------------------------

REM change working dir to dir specified above
cd %dir%

REM Replace space in hour with zero if it's less than 10
SET hr=%time:~0,2%
IF %hr% lss 10 SET hr=0%hr:~1,1%

REM This sets the date like this: mm-dd-yr-hhmmssss (includes 1/100 secs)
Set TODAY=%date:~4,2%-%date:~7,2%-%date:~10,4%-%hr%%time:~3,2%^
%time:~6,2%%time:~9,2%

echo.
echo Folder to compress in *.RAR format:
echo %dir%
echo.
echo.

echo 1. Compress files in dir individually (no subdirs)
echo 2. Compress all files in dir and subdirs individually - no paths
echo 3. Compress all files in dir into a single archive (no subdirs)
echo 4. Compress all files in dir and subdirs into a single archive
echo 5. Compress all files in dir and subdirs into a single archive - no paths
echo 6. Exit
echo.
echo.
:choose
set PROFILE=
set /P PROFILE=Enter your selection (1-7):
if "%PROFILE%"=="1" goto indiv
if "%PROFILE%"=="2" goto sindiv
if "%PROFILE%"=="3" goto onearc
if "%PROFILE%"=="4" goto sonearc
if "%PROFILE%"=="5" goto snponearc
if "%PROFILE%"=="6" goto nochoice
goto choose

REM 1. Compress files in directory individually (no subdirs, excluded by FOR command)
REM Files with same name but different exts overwritten by last task
:indiv
echo.
echo.
FOR %%i IN (*.*) do (
rar a "%%~ni" "%%i"
)
goto eof

REM 2. Compress files in directory and subdirectories individually (no paths)
REM Uses FOR command to recurse through directories. 
REM Files with same name but different exts overwritten by last task
:sindiv
echo.
echo.
FOR /R %%b IN (*.*) do (
rar a -ep "%%~nb" "%%b"
)
goto eof

REM 3. Compress all files in directory into a single archive (no subdirectories)
REM Files not specified, *.* is implied and WinRAR will process all files
:onearc
echo.
echo.
echo Today's date and time will be added to the base filename
set /P name=Enter base filename for archive:
rar a "%name%_%today%" 
goto eof

REM 4. Compress all files in directory and subdirectories into a single archive
:sonearc
echo.
echo.
echo Today's date and time will be added to the base filename
set /P name=Enter base filename for archive:
rar a -r "%name%_%today%" 
goto eof

REM 5. Compress all files in dir and subdirs into a single archive - no paths
:snponearc
echo.
echo.
echo Today's date and time will be added to the base filename
set /P name=Enter base filename for archive:
rar a -r -ep "%name%_%today%" 
goto eof

REM 6. Exit
:nochoice
echo.
echo.
echo No selection made - script exited
:eof

endlocal

echo.
echo "Task Completed"
echo.

pause

REM --------------------------- exit -----------------------------------------
:end
EXIT /B 0