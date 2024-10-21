@echo off
echo BUILDING VS FREYA - OPENING CUBICAL SONG
lime test windows -DSONG=cubical -DDAMNWTF
echo FREYA MOD CLOSED!
pause
pwd
explorer.exe export\release\windows\bin
