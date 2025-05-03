@echo off
echo Setting up Firebase configuration for LaughLab

echo Adding pub cache to PATH temporarily...
set PATH=%PATH%;C:\Users\dusti\AppData\Local\Pub\Cache\bin

echo Running flutterfire configure...
flutterfire configure

echo Configuration complete!
pause 