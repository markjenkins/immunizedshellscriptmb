#!/bin/bash

DEVICE=/dev/ttyS0

# larger font
echo -e '\x1B:' > $DEVICE

echo -e 'not verified!' > $DEVICE
echo -e 'please think of those'  > $DEVICE
echo -e 'closest to you and'  > $DEVICE
echo -e '(voluntarily) proceed' > $DEVICE
echo -e 'to your local' > $DEVICE
echo -e 'vaccination centre' > $DEVICE
echo -e '\n\n\n\n\n' > $DEVICE

# smaller font
echo -e '\x1BM' > $DEVICE
