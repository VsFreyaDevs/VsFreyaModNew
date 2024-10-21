@echo off
echo BUILDING VS FREYA - TEST MODE
lime test windows -DDAMNWTF
echo FREYA MOD CLOSED!
pause
pwd
explorer.exe export\release\windows\bin
