#!/bin/sh

for NS in $(kubectl get ns | grep tfs- | awk '{print $1}')
do
	echo "$NS"
	for POD in $(kubectl get po -n "$NS" | grep tfs- | awk '{print $1}')
	do
		echo "$POD"
		kubectl describe po "$POD" -n "$NS" | grep -i "Image:"
	done
done
