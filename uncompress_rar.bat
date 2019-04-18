@echo off

setlocal

REM Specify the folder to uncompress below:
REM -------------------------------- Compressed file folder_----------------------------
set dirA=D:\ANA_MARIA\demografie\testare_citire_R
REM ------------------------------------------------------------------------------------

REM change to directory
cd %dirA%

REM Specify the extracted files folder below:
REM -------------------------------- Folder to extract to-------------------------------
set dirE=D:\ANA_MARIA\demografie\testare_citire_R
REM ------------------------------------------------------------------------------------


REM Specify where to move processed archives below. This folder must exist:
REM -------------------------------- Processed folder-----------------------------------
md old
set dirC=%dirA%\old
REM ------------------------------------------------------------------------------------

md new
set dirN=%dirA%\new


REM Path to WinRAR executable in Program Files
set path="C:\Program Files\WinRAR\";%path%


echo.
echo All files in %dirA% to be uncompressed
echo.

echo.

FOR %%i IN (*.rar) do (

md %dirN%\%%~ni
unrar e "%%~ni.rar" "%dirN%\%%~ni"
move "%%~ni.rar" "%dirC%"
echo completed uncompressing "%%i" and moved archives or archive to "%dirC%"

)

set path="C:\Program Files\R\R-3.3.2\bin\";%path%
Rscript D:/ANA_MARIA/demografie/testare_citire_R/encrypt.R


cd %dirN%

set zip="C:\Program Files\WinRAR\rar.exe" a -r -u -df

dir /b /o:n /ad > .\folders.txt

for /F "tokens=*" %%A in (.\folders.txt) do if not exist ".\%%~nA.rar" %zip% ".\%%~nA.rar" "%%A"
 
del "*.txt"


goto eof

:eof

endlocal

echo.
echo "Task Completed"
echo.

@pause