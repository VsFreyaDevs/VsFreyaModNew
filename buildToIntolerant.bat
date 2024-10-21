@echo off
echo BUILDING VS FREYA - OPENING INTOLERANT SONG
lime test windows -DSONG=intolerant -DDAMNWTF
echo FREYA MOD CLOSED!
pause
pwd
explorer.exe export\release\windows\bin
