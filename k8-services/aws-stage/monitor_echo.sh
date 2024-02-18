#!/bin/bash

COUNTER=0
ERROR=0

while true;
do
	COUNTER=$((COUNTER + 1))
	curl -fs "https://api.pen.pannovate.net/echo" > /dev/null || ERROR=$((ERROR + 1))
	echo "Call /echo: #: $COUNTER | Err: $ERROR"
done
