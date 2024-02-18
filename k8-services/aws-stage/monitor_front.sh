#!/bin/bash

COUNTER=0
ERROR=0

while true;
do
	COUNTER=$((COUNTER + 1))
	curl -fs "https://api.pen.pannovate.net/front/" > /dev/null || ERROR=$((ERROR + 1))
	echo "Call /front/: #: $COUNTER | Err: $ERROR"
done
