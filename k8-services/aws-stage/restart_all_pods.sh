#!/bin/sh

for NS in $(kubectl get ns | grep tfs- | awk '{print $1}')
do
	echo "$NS"
	kubectl rollout restart deployment -n "$NS"
done
