#!/bin/bash
#set -e
#set -o pipefail

CALL_NAME=$0
USAGE="Usage: ${CALL_NAME} [-h|--help] [-r|--replace] [-e|--enable] [-d|--disable] [-u|--username <github username>]"
HELP=$(cat <<EOF
${USAGE}

	-h,	--help		This help message
	-r,	--replace	Replace the authorized keys with the github ones
	-e,	--enable	Enable sync as a cronjob
	-d,	--disable	Disable the cronjob
	-u,	--username=USER	The GitHub username that the keys should be downloaded from
EOF
)

REPLACE=false
ENABLE=false
DISABLE=false
GITHUB_USER="${USER}"

# Transform long options to short
for arg in "$@"; do
	shift
	case "$arg" in
		"--help") set -- "$@" "-h" ;;
		"--replace") set -- "$@" "-r" ;;
		"--enable") set -- "$@" "-e" ;;
		"--disable") set -- "$@" "-d" ;;
		"--username" | "--user") set -- "$@" "-u" ;;
		*) set -- "$@" "$arg";;
	esac
done

while getopts "redhu:" arg; do
	case "$arg" in
		"r") REPLACE=true ;;
		"e") ENABLE=true ;;
		"d") DISABLE=true ;;
		"u") GITHUB_USER="${OPTARG}" ;;
		"h") echo -e "${HELP}"; exit 0 ;;
		*)
			echo "Unknown argument '${arg}'"
		       	echo -e "${HELP}"
			exit 1
			;;
	esac
done

if $ENABLE; then
	echo "[!] Adding cronjob to download (append, not replace) new authorized keys from GitHub user ${GITHUB_USER} every day at 06:00 AM"
	echo "0 6 * * * ${CALL_NAME} --username ${GITHUB_USER}" | crontab -
	exit 0
fi

if $DISABLE; then
	exit 0
fi

echo "[i] Downloading keys for GitHub user: ${GITHUB_USER}"
GITHUB_KEYS=$(curl -s "https://github.com/${GITHUB_USER}.keys")

if [ "${GITHUB_KEYS}" == "Not Found" ]; then
	echo "[x] SSH keys where not found"
	exit 1
fi

if $REPLACE; then
	echo -e "[!] Replacing authorized keys with:\n\n${GITHUB_KEYS}"
	echo "${GITHUB_KEYS}" > ~/.ssh/authorized_keys
	exit 0
fi

IFS=$(printf '\nx') && IFS="${IFS%x}"
for key in ${GITHUB_KEYS}; do
	if ! grep -sq "${key}" ~/.ssh/authorized_keys; then
		echo -e "[!] Adding authorized key:\n\n${key}"
		echo "${key}" >> ~/.ssh/authorized_keys
	fi
done
