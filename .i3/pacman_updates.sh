#!/bin/bash

updates=`pacman -Qu | wc -l`

if [[ -z "$updates" ]]; then
   echo "0 updates"
fi

if [[ "$updates" == "1" ]]; then
   echo "1 update"
else
   echo "$updates updates"
fi
