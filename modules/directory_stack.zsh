##
#
#   spin-directory
#     Loop through directory stack.
#
##

zmodload zsh/mapfile
dirstack=( "${(f)mapfile[$DIRSTACKFILE]}" )

update ()
{
	[[ $PWD == $HOME ]] && return
	local dir
	local tempstack
	for dir in $dirstack; do
		[[ $dir == ${(q)PWD}* ]] && return
		[ ! -d "$DIRECTORY" ] && continue
		(( ${#tempstack} >= DIRSTACKSIZE-1 )) && continue
		[[ ${(q)PWD} != $dir* ]] && tempstack=( $dir $tempstack )
	done

	dirstack=( ${(q)PWD} $tempstack )
	mapfile[$DIRSTACKFILE]=${(F)dirstack}
}

chpwd_functions=( update $chpwd_functions )

typeset -i spin_pos=1
spin-directory ()
{
	# Start spin if cursor changes
	if [[ $CURSOR != $spin_cur ]]; then
		spin_cur=$CURSOR
		spin_len=-1
		spin_pos=1
	fi

	# Replace value in buffer
	RBUFFER="$dirstack[$spin_pos]$RBUFFER[$spin_len+1, -1]"
	spin_len=${#dirstack[$spin_pos]}

	# At last, loop to first
	if ((spin_pos == ${#dirstack})); then
		spin_pos=1
	else
		spin_pos+=1
	fi
}
zle -N spin-directory
bindkey "^@" spin-directory

spin-directory-back ()
{
	# Start spin if cursor changes
	if [[ $CURSOR != $spin_cur ]]; then
		spin_cur=$CURSOR
		spin_len=-1
		((spin_pos=${#dirstack}-1))
	fi

	# Replace value in buffer
	RBUFFER="$dirstack[$spin_pos]$RBUFFER[$spin_len+1, -1]"
	spin_len=${#dirstack[$spin_pos]}

	# At first, loop to last
	if [[ $spin_pos == 1 ]]; then
		((spin_pos=${#dirstack}))
	else
		spin_pos+=-1
	fi
}
zle -N spin-directory-back
bindkey "^^" spin-directory-back