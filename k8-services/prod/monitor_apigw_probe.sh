#!/bin/bash

COUNTER=0
ERROR=0

while true;
do
	COUNTER=$((COUNTER + 1))
	curl -fs "https://api.transfast.pannovate.net/probes/healthz" > /dev/null || ERROR=$((ERROR + 1))
	echo "Call /healthz: #: $COUNTER | Err: $ERROR"
done
