#!/bin/bash

cd build/app/intermediates/stripped_native_libs/release/stripReleaseDebugSymbols/out/lib/ || exit 10

rm .DS_Store

zip -r symbols.zip .

mv -f symbols.zip ~/Desktop/

cd ../../../../../../../../

cp build/app/outputs/bundle/release/app-release.aab ~/Desktop/ || exit 5
