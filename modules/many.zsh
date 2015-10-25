#!/bin/zsh
#
# Usage:
#   Call `many.init [listname] [values]` then `many.loop` when it returns REPLY
#   will be set to the selected value.
#
# Example:
#   many.init History $history
#   many.loop
#   echo $REPLY
#
##

zmodload zsh/curses

(( size=LINES ))

typeset -i selected pos
pos=1
selected=$size

many.init ()
{
	name=$1
	shift
	elements=( "$@" )
	zcurses init
	many.draw
}

many.loop ()
{
	while true; do
		zcurses input stdscr raw key
		many.read $raw $key
	done
}

many.read ()
{
	case $1 in 
		'q')
			zcurses end
			typeset -g REPLY
			REPLY=$elements[selected]
			return 1
			;;
		"UP")
			if (( selected > 1 )); then
				(( selected <= pos)) && (( pos-- ))
				(( selected-- ))
			fi
			;;
		"DOWN")
			if (( selected < ${#elements} )); then
				(( selected >= pos+size-1)) && (( pos++ ))
				(( selected++ ))
			fi
			;;
		"PPAGE")
			(( pos=pos-size, selected=selected-size ))
			(( pos < 1 )) && pos=1
			(( selected < 1 )) && selected=1
			;;
		"NPAGE")
			(( pos=pos+size, selected=selected+size ))
			(( pos > ${#elements} )) && pos=${#elements}
			(( selected > ${#elements} )) && selected=${#elements}
			;;
	esac

	many.draw
}

many.draw ()
{
	typeset -i offset
	offset=0
	zcurses clear stdscr
	for (( i=0; i+offset < size; i++ )); do
		if (( i+pos == selected )); then
			zcurses attr stdscr black/white
			lines=( ${(@fr:$COLUMNS:)elements[i+pos]} )
			zcurses string stdscr "${(j::)lines}"
			(( offset=offset+${#lines}-1 ))
			zcurses attr stdscr default/default
		else
			zcurses string stdscr "${elements[i+pos]/
*/...}
"
		fi
	done
	zcurses attr stdscr white/black
	zcurses string stdscr "$name line $selected (Press 'q' to select)"
	zcurses attr stdscr default/default
	zcurses refresh
}