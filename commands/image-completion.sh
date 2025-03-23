#!/bin/bash

_autocomplete() {
	local cur prev

	cur=${COMP_WORDS[COMP_CWORD]}
	prev=${COMP_WORDS[COMP_CWORD-1]}

	:<<-EOC
	echo
	echo -n "COMP_WORDS: "
	for e in "${COMP_WORDS[@]}"; do
		echo -n "$e "
	done
	echo
	echo "COMP_CWORD $COMP_CWORD"
	EOC

	case ${COMP_CWORD} in
	1)
		COMPREPLY=($(compgen -W "build run" -- ${cur}))
		;;
	2)
		if [[ ${prev} =~ build ]]; then
		COMPREPLY=($(compgen -W "--user=" -- ${cur}))
		fi
		;;
	# --username=` is 3rd, <username> typed is 4th and `--password=` is 5th
	5)
		for e in "${COMP_WORDS[@]}"; do
			if [[ $e =~ user ]]; then
				COMPREPLY=($(compgen -W "--password=" -- ${cur}))
			fi
		done
		;;
	*)
		COMPREPLY=()
		;;
	esac
}

dir=$(dirname -- "$0")
complete -o nospace -F _autocomplete ${dir}/image
