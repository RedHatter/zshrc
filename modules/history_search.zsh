##
#   enter-history-search
#     An extended incremental history search. Searches for a line that contains
#     all words. A '!' (can be escaped '\!') in front of a word to search for a
#     line that does not contain that word. Use tab to insert a word instead of
#     selecting the history line.
#
#  Note: there has got to be a better way to do key bindings!
#
##

# Incremental search keybinds
bindkey "^[[1;5A"   enter-history-search                            # Ctrl + Up

# Search through history for line that contains all words, case-insensitive if
# no upper case letters are in word.
enter-history-search ()
{
	zle push-input
	local string words char key esc pos
	local -i restore direction from m num restore_c
	direction=-1
	restore=$HISTNO
	from=$HISTNO
	bindings=(
"<Up>    -> Search backward"
"<Down>  -> Search forward"
"<Enter> -> Accept search"
"<Tab>   -> Cycle through words to insert"
"<Esc>   -> Cancel search")
	bindings=( ${(r:$COLUMNS:: :)bindings} )
	while true; do
		zle -R "Line $HISTNO, Search for: $string" $bindings
		readkey
		case $REPLY in
			"BACKSPACE")
				string=$string[1,-2]
				;;
			"TAB")
				words=( ${=history[$from]} )
				HISTNO=$restore
				(( HISTNO == HISTCMD )) && zle get-line
				if (( num == 0 )); then
					num=${#words}
				elif (( num == 1 )); then
					BUFFER=${BUFFER% *}
					num=${#words}
				else
					BUFFER=${BUFFER% *}
					num+=-1
				fi
				pos=( ${#BUFFER} )
				BUFFER+=" $words[$num]"
				pos+=( ${#BUFFER} )
				region_highlight=( "${pos[1]} ${pos[2]} fg=black,bg=white" )
				continue
				;;
			"ENTER")
				# POSTDISPLAY=""
				zle -c
				region_highlight=()
				return
				;;
			"UP")
				from=HISTNO-1
				direction=-1
				;;
			"DOWN")
				from=HISTNO+1
				direction=1
				;;
			"ESC")
				HISTNO=$restore
				(( HISTNO == HISTCMD )) && zle get-line
				region_highlight=()
				# POSTDISPLAY=""
				zle -c
				return
				;;
			*)
				string+=$char
				;;
		esac
		words=( ${=string} )
		for (( i=from; i>0 && i<HISTCMD+1; i+=direction )); do
			region_highlight=()
			for word in $words; do
				if [[ $word[1] == "!" ]]; then
					if [[ -n ${word:#*[A-Z]*} ]]; then
						pos=( ${(SBE)=${(L)history[$i]}#$word[2,-1]} )
					else
						pos=( ${(SBE)=history[$i]#$word[2,-1]} )
					fi

					(( pos[1] == 1 && pos[2] == 1 )) || continue 2
				else
					[[ $word[1,2] == '\!' ]] && word=$word[2,-1]

					if [[ -n ${word:#*[A-Z]*} ]]; then
						pos=( ${(SBE)=${(L)history[$i]}#$word} )
					else
						pos=( ${(SBE)=history[$i]#$word} )
					fi

					if (( pos[1] == 1 && pos[2] == 1 )); then
						continue 2
					else
						region_highlight+=( "$(( pos[1]-1 )) $(( pos[2]-1 )) fg=black,bg=white" )
					fi
				fi
			done

			HISTNO=$i
			from=$i
			break
		done
	done
}

zle -N enter-history-search