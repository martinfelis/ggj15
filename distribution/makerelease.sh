#!/bin/bash

cd distribution
cd ..
zip -9 -q -r  prisonbroke.zip . --exclude=.git/\*
mv prisonbroke.zip distribution/prisonbroke.love
cd distribution

# .1 nur um meine gitignore zu umschiffen

unzip love-0.9.1-win32.zip.1
mv love-0.9.1-win32 Prisonbroke
cat Prisonbroke/love.exe prisonbroke.love > Prisonbroke/Prisonbroke.exe
zip -9 -r Prisonbroke_Win32.zip Prisonbroke/
rm -rf Prisonbroke

unzip love-0.9.1-win64.zip.1
mv love-0.9.1-win64 Prisonbroke
cat Prisonbroke/love.exe prisonbroke.love > Prisonbroke/Prisonbroke.exe
zip -9 -r Prisonbroke_Win64.zip Prisonbroke/
rm -rf Prisonbroke