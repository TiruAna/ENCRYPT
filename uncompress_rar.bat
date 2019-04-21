@echo off

setlocal

REM Calea unde se gasesc arhivele .rar, scriptul .bat si scriptul.R
set dirA=C:\Users\Glugluta\proiecte\dem

cd %dirA%

echo %DATE%
echo %TIME%

SET hr=%time:~0,2%

SET TODAY=%date:~7,2%-%date:~4,2%-%date:~10,4%_%hr%-%time:~3,2%-%time:~6,2%


md dem_cnp_necriptat_%TODAY%
set dirC=%dirA%\dem_cnp_necriptat_%TODAY%


md dem_cnp_criptat_%TODAY%
set dirN=%dirA%\dem_cnp_criptat_%TODAY%


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

set path="C:\Program Files\R\R-3.5.1\bin\";%path%
Rscript C:/Users/Glugluta/proiecte/dem/encrypt.R


cd %dirN%

set zip="C:\Program Files\WinRAR\rar.exe" a -r -u -df -ep

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