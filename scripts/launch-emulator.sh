#!/bin/bash

mapfile -t emulators < <(emulator -list-avds)

if [ "${#emulators[@]}" -eq 0 ]; then
    echo "No emulators found!"
    exit 1
fi

if [ "${#emulators[@]}" -eq 1 ]; then
    avd_name=${emulators[0]}
else
    echo "Select the AVD you want to launch:"
    for ((i=0; i<${#emulators[@]}; i++)); do
        echo "$i: ${emulators[i]}"
    done
    printf "Enter the index of the AVD you want to launch: "
    read -r avd_index
    avd_name=${emulators[avd_index]}
fi

emulator -avd "$avd_name"

