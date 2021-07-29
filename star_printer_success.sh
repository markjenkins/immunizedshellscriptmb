#!/bin/bash

DEVICE=/dev/ttyS0

# larger font
echo -e '\x1B:' > $DEVICE

echo -e 'Welcome' $1 "$2!" > $DEVICE
echo -e 'Thank you for caring' > $DEVICE
echo -e 'for your community!' > $DEVICE
# smaller font
echo -e '\x1BM' > $DEVICE
echo -e '\n\n\n\n\n' > $DEVICE
