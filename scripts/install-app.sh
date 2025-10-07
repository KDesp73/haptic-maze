#!/bin/bash

module=$(find . -iname 'MainActivity.kt' | cut -d "/" -f2)

if [ $# -ne 1 ] ; then
    printf "Install to emulator, device or waydroid [e/d/w]: "
    read -r device
else
    device="$1"
fi

if [ "$device" != "d" ] && [ "$device" != "e" ] && [ "$device" != "w" ] ; then
    echo "Incorrect device. Try 'e', 'd' or 'w'"
    exit 1
fi

file="$module/build/outputs/apk/debug/$module-debug.apk"

if [ ! -f "$file" ]; then
    echo "Run './gradlew build' first"
    exit 1
fi

if [ "$device" == 'd' ]; then
    adb -d install "$file" 
    exit 0
fi

if [ "$device" == 'w' ]; then
    waydroid app install "$file"
    exit 0
fi

adb install "$file"

exit 0
