#!/bin/bash

COUNTER=0
ERROR=0

while true;
do
	COUNTER=$((COUNTER + 1))
	curl -fs "https://api.transfast.pannovate.net/is-everything-alright" > /dev/null || ERROR=$((ERROR + 1))
	echo "Call /is-everything-alright: #: $COUNTER | Err: $ERROR"
done
