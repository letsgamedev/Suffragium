@title Run GDScript Toolkit
@echo off
rem *********************
rem This Script runs gdformat and gdlint on all files in game folder.
rem https://github.com/Scony/godot-gdscript-toolkit
rem *********************
cd ..
echo --- Format ---
gdformat game/
echo.
echo --- Lint ---
gdlint game/
echo.
echo.
pause
