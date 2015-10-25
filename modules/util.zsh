#!/bin/zsh

readkey ()
{
	typeset -g REPLY
	read -k char
	case $[ ##$char ] in
		27)
			key="^["
			until [[ "$char" == "" ]]; do
				char=""
				read -k -t char
				key+=$char
			done
			REPLY=$keycodes[$key]
			;;
		127)
			REPLY=$keycodes["^?"]
			;;
		9)
			REPLY=$keycodes["^I"]
			;;
		13)
			REPLY="ENTER"
			;;
		*)
			REPLY=$char
	esac
}

typeset -A keycodes
keycodes=(
"^?" "BACKSPACE"
"^I" "TAB"
"^[" "ESC"
"^[[A" "UP"
"^[[B" "DOWN"
"^[[5~" "PPAGE"
"^[[6~" "NPAGE"
)
