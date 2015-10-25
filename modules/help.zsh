#!/bin/zsh

help ()
{
	words=( ${=BUFFER} )
	zle push-input
	BUFFER="man $words[1]"
	zle accept-line
}
zle -N help
bindkey "^H" help

display-and-space ()
{
	zle magic-space
	words=( ${=BUFFER} )
	(( ${#words} > 2 )) && return

	if [[ $words[1] == "sudo" ]]; then
		synopsis=${$(man --nj $words[2] </dev/tty 2> /dev/null 2| grep -A1 SYNOPSIS)##SYNOPSIS[[:space:]]#}
	else
		synopsis=${$(man --nj $words[1] </dev/tty 2> /dev/null 2| grep -A1 SYNOPSIS)##SYNOPSIS[[:space:]]#}
	fi

	if (( ${#synopsis} > 0 )); then
		POSTDISPLAY="
${synopsis[0,$COLUMNS]}"
	else
		POSTDISPLAY=""
	fi
}
zle -N display-and-space
bindkey " " display-and-space