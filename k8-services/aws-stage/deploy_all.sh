#!/bin/sh

for F in ./*/*deployment.yaml
do
	kubectl apply -f "$F" &
done
