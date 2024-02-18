#!/bin/sh

# HELPS CHANGE VERSIONS IN EACH DEPLOYMENT MANIFEST WITH $1 COMMAND LINE ARGUMENT.

# NEW_VERSION=1.2.17

if [ "$#" = 0 ] || [ "$1" = "" ]
then
	printf "WARNING! No version arguments provided!\nUSAGE:\n\t%s 1.2.3\n" "$(basename "$0")"
	exit 255
fi

if [ -n "$1" ]
then
	NEW_VERSION="$1"
fi

exit_err(){
	printf "\e[0;91mERROR: %s! Error code [%s]\e[0m\n" "$1" "$2"
	exit "$2"
}

exit_OK(){
	printf "\e[0;92m%s\e[0m\n" "All operations seem to be propperly done! Bye now."
	exit 0
}

delete_backups(){
	for F in ./*/*deployment.yaml.bak
	do
		printf "\t\e[0;93m- Deleting: \e[0;94m%s\e[0m!" "$F"
		rm "$F" || exit_err "Cannot delete file: $F" "$?"
		printf "\e[0;92m - deleted!\e[0m\n"
	done
	echo
	exit_OK
}

main(){
	for F in ./*/*deployment.yaml
	do
		cp "$F" "$F.bak"
		printf "\e[0;93m\t- Updating: \e[0;94m%s:\e[0m\n" "$F"
		BASE_IMAGE="$(grep '  image:' "$F" | awk '{print $2}' | awk -F ':' '{print $1}')" || exit_err "Image string cannot be found!" "$?"
		sed -i -re "s|($BASE_IMAGE).*$|\1:$NEW_VERSION|" "$F" || exit_err "Updated image version filed!" "$?"
		NPM_VER_LN="$(grep -n 'npm_package_version' -A1 "$F" | tail -1 | awk -F '-' '{print $1}')" || exit_err "NPM Version string cannot be found!" "$?"
		sed -i -re "$NPM_VER_LN s|(value:\s*).*$|\1\"$NEW_VERSION\"|" "$F" || exit_err "Updating NPM version failed!" "$?"
		printf " - %s\n" "$(grep '  image' "$F")"
		printf " - %s\n" "$(grep 'npm_package_version' -A1 "$F")"
	done
}

printf "This will update deployments manifests to version: \e[0;94m%s!\e[0m\n" "$NEW_VERSION"
printf "\e[0;93mIs this correct? Continue?\e[0m [Y(es)/N(o)]: "
read -r do_updates
case $do_updates in
	[Yy]* )
		printf "You answered \e[0;93mYES\e[0m!\n"
		main
		;;
	[Nn]* )
		printf "You answered \e[0;93mNO\e[0m, exiting\n"
		exit_OK
		;;
	* )
		printf "Wrong Answer %s! Answer either yes or no!\n" "$do_updates"
		;;
esac

while true;
do
	printf "\e[0;93mChanges have been made to the files! If everything seems OK with displayed changes,\n"
	printf "do you wish to delete backup files creted during this operation?\e[0m [Y(es)/N(o)]: "
	read -r yesno
	case $yesno in
		[Yy]* )
			printf "You answered \e[0;93mYES!\e[0m\n"
			delete_backups
			;;
		[Nn]* )
			printf "You answered \e[0;93mNO\e[0m, exiting.\n"
			exit_OK
			;;
		* )
			printf "Invalid answer: %s! Answer either yes or no!\n" "$yesno"
			;;
	esac
done
