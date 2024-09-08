#!/bin/bash

cd build/app/intermediates/stripped_native_libs/release/out/lib/ || exit 10

rm .DS_Store

zip -r symbols.zip .

mv -f symbols.zip ~/Desktop/

cd ../../../../../../../
