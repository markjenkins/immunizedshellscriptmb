#!/bin/bash

cvlc --quiet --play-and-exit success01.aif success02.aif 2>/dev/null &
./star_printer_success.sh "$1" "$2"
