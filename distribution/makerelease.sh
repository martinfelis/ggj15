#!/bin/bash

cd distribution
cd ..
zip -9 -r  prisonbroke.zip . --exclude=.git/\* --exclude=distribution/\*
mv prisonbroke.zip distribution/prisonbroke.love
cd distribution

# .1 nur um meine gitignore zu umschiffen

unzip love-0.9.1-win32.zip.1
mv love-0.9.1-win32 Prisonbroke
cat Prisonbroke/love.exe prisonbroke.love > Prisonbroke/Prisonbroke.exe
rm Prisonbroke/love.exe
zip -9 -r Prisonbroke_Win32.zip Prisonbroke/
rm -rf Prisonbroke

unzip love-0.9.1-win64.zip.1
mv love-0.9.1-win64 Prisonbroke
cat Prisonbroke/love.exe prisonbroke.love > Prisonbroke/Prisonbroke.exe
rm Prisonbroke/love.exe
zip -9 -r Prisonbroke_Win64.zip Prisonbroke/
rm -rf Prisonbroke

cp prisonbroke.love prisonbroke_source.zip