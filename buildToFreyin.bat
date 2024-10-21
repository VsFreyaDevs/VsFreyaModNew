@echo off
echo BUILDING VS FREYA - OPENING FREYIN SONG
lime test windows -DSONG=freyin -DDAMNWTF
echo FREYA MOD CLOSED!
pause
pwd
explorer.exe export\release\windows\bin
