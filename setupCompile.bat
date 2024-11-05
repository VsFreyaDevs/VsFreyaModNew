@echo off
color 0a
echo SETTING UP VS FREYA COMPILATION
echo (MAKE SURE YOU HAVE HAXE INSTALLED TO SET UP PROPERLY!!!)
echo Installing dependencies...
echo This might take a few moments depending on your internet speed.
haxelib install hmm --quiet
haxelib run hmm install --quiet
haxelib run lime setup
echo Rebuilding hxcpp...
lime rebuild hxcpp
echo Installing Microsoft Visual Studio Community... (Dependency)
curl -# -O https://download.visualstudio.microsoft.com/download/pr/3105fcfe-e771-41d6-9a1c-fc971e7d03a7/8eb13958dc429a6e6f7e0d6704d43a55f18d02a253608351b6bf6723ffdaf24e/vs_Community.exe
vs_Community.exe --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 -p
del vs_Community.exe
echo Finished!
pause
