#!/usr/bin/env bash

cd /Users/draco892/Documents/GIT/LightZone       
./gradlew :macosx:jpackage

cp -r macosx/release/LightZone.app /Applications/ 