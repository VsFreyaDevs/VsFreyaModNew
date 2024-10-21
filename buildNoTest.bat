@echo off
echo BUILDING VS FREYA - BUILD MODE
lime build windows -DDAMNWTF
echo.
echo FINISHED COMPILING FREYA MOD!
pause
pwd
explorer.exe export\release\windows\bin
