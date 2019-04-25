@echo off

setlocal

REM -------------------------------------------------------- Seteaza calea --------------------------------------------

set dirA=D:\ANA_MARIA\Demografie

REM -------------------------------------------------------------------------------------------------------------------


cd %dirA%

if not exist *.rar goto exit

SET hr=%time:~0,2%
IF %hr% lss 10 SET hr=0%hr:~1,1%

SET TODAY=%date:~7,2%-%date:~4,2%-%date:~10,4%_%hr%-%time:~3,2%-%time:~6,2%


md dem_cnp_necriptat_%TODAY%
set dirC=%dirA%\dem_cnp_necriptat_%TODAY%


md dem_cnp_criptat_%TODAY%
set dirN=%dirA%\dem_cnp_criptat_%TODAY%


REM ---------------------------- Seteaza calea catre executabilul WinRAR din Program Files --------------------------

set path="C:\Program Files\WinRAR\";%path%

REM -----------------------------------------------------------------------------------------------------------------


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



REM ------------------------------ Seteaza calea catre executabilul Rscript din Program Files ------------------------

set path="C:\Program Files\R\R-3.3.2\bin\";%path%

REM ------------------------------------------------------------------------------------------------------------------


REM ------------------------------------------- Apeleaza scriptul R --------------------------------------------------
Rscript D:\ANA_MARIA\Demografie\encrypt.R
REM ------------------------------------------------------------------------------------------------------------------


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