#!/bin/sh

printf "Creating Namespaces...\n"
for F in ./*/*-ns.yaml
do
	printf "    - Creating: %s --- " "$F"
	kubectl apply -f "$F" --wait
done

printf "Creating Services...\n"
for F in ./*/*-service.yaml
do
	if [ ! "$F" = "apigw-service" ]; then
		printf "    - Creating: %s --- " "$F"
		kubectl apply -f "$F" --wait
	fi
done

printf "List of Service IPs...\n"
printf "# List of Service IPs\n\n" > list_of_service_ips.md
for NS in $(kubectl get ns | grep tfs- | awk '{print $1}')
do
	for SVC in $(kubectl get svc -n "$NS" | grep tfs- | awk '{print $1}')
	do
		printf "%s: " "$SVC" >> list_of_service_ips.md
		kubectl get svc "$SVC" -n "$NS" | tail -1 | awk '{print $3}' >> list_of_service_ips.md
		tail -1 list_of_service_ips.md
	done
done

printf "Edit deployment manifest service IPs\n"
for F in ./*/*-deployment.yaml
do
	printf "   - Modifying --- %s for: " "$F"
	printf "AS_URL, "
	asl=$(grep -n ' AS_URL' "$F" | cut -d ':' -f1)
	asip="$(grep 'tfs-as-' list_of_service_ips.md | awk '{print $2}'):10004"
	sed -ri "$(( asl + 1 ))s|(value:)\s*.+|value: \"$asip\"|" "$F"

  printf "CONFIG_URL, "
	col=$(grep -n ' CONFIG_URL' "$F" | cut -d ':' -f1)
	coip="$(grep 'tfs-config-' list_of_service_ips.md | awk '{print $2}'):10008"
	sed -ri "$(( col + 1 ))s|(value:)\s*.+|value: \"$coip\"|" "$F"

	printf "CS_URL, "
	csl=$(grep -n ' CS_URL' "$F" | cut -d ':' -f1)
	csip="$(grep 'tfs-cs-' list_of_service_ips.md | awk '{print $2}'):10003"
	sed -ri "$(( csl + 1 ))s|(value:)\s*.+|value: \"$csip\"|" "$F"

	printf "ELS_URL, "
	ell=$(grep -n ' ELS_URL' "$F" | cut -d ':' -f1)
	elip="$(grep 'tfs-els-' list_of_service_ips.md | awk '{print $2}'):10006"
	sed -ri "$(( ell + 1 ))s|(value:)\s*.+|value: \"$elip\"|" "$F"

	printf "FS_URL, "
	fsl=$(grep -n ' FS_URL' "$F" | cut -d ':' -f1)
	fsip="$(grep 'tfs-fs-' list_of_service_ips.md | awk '{print $2}'):10007"
	sed -ri "$(( fsl + 1 ))s|(value:)\s*.+|value: \"$fsip\"|" "$F"

	printf "KYC_URL, "
	kyl=$(grep -n ' KYC_URL' "$F" | cut -d ':' -f1)
	kyip="$(grep 'tfs-kyc-' list_of_service_ips.md | awk '{print $2}'):10002"
	sed -ri "$(( kyl + 1 ))s|(value:)\s*.+|value: \"$kyip\"|" "$F"

	printf "MPS_URL, "
	mpl=$(grep -n ' MPS_URL' "$F" | cut -d ':' -f1)
	mpip="$(grep 'tfs-mps-' list_of_service_ips.md | awk '{print $2}'):10005"
	sed -ri "$(( mpl + 1 ))s|(value:)\s*.+|value: \"$mpip\"|" "$F"

	printf "PS_URL, "
	psl=$(grep -n ' PS_URL' "$F" | cut -d ':' -f1)
	psip="$(grep 'tfs-ps-' list_of_service_ips.md | awk '{print $2}'):10014"
	sed -ri "$(( psl + 1 ))s|(value:)\s*.+|value: \"$psip\"|" "$F"

	printf "WH_URL\n"
	whl=$(grep -n ' WEBHOOK_URL' "$F" | cut -d ':' -f1)
	whip="$(grep 'tfs-webhook-' list_of_service_ips.md | awk '{print $2}'):10010"
	sed -ri "$(( whl + 1 ))s|(value:)\s*.+|value: \"$whip\"|" "$F"
done

printf "Now edit *-secrets.yaml and run:\n"
# shellcheck disable=SC2183,SC2016
printf 'for F in ./*/*-secrets.yaml
do
	printf "    - Creating: %s --- " "$F"
	kubectl apply -f "$F" --wait
done\n'
