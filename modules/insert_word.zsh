##
#
#   Insert History word
#     Extended keybinds for insert-last-word. Shift+Up calls insert-last-word
#     and displays the current history line in POSTDISPLAY, Shift+Left and
#     +Right will then select the corresponding words on the line.
#
##

# Insert history word keybinds
bindkey "^[[1;2A"   insert-last-word                                # Shift+ Up     - select last word of previous history line
bindkey "^[[1;2B"   insert-down-word                                # Shift+ Down   - select last word of next history line
bindkey "^[[1;2C"   insert-next-word                                # Shift+ Right  - select next word of current history line
bindkey "^[[1;2D"   insert-prev-word                                # Shift+ Left   - select previous word of current history line
typeset -i line word
word=-1

insert-prev-word()
{
	cmd=( ${$(fc -l $line $line)##<->} )
	(( word > -${#cmd} )) && word+=-1 || word=-1
	zle .insert-last-word 0 $word
	display-status
}

insert-next-word()
{
	cmd=( ${$(fc -l $line $line)##<->} )
	(( word < -1 )) && word+=1 || word=-${#cmd}
	zle .insert-last-word 0 $word
	display-status
}

insert-last-word()
{
	[[ $LASTWIDGET != reset-prompt ]] && REALLASTWIDGET=$LASTWIDGET

	if [[ $REALLASTWIDGET == insert-(last|down|next|prev)-word ]];then
		line+=-1
	else
		line=-1
	fi
	zle .insert-last-word
	word=-1
	cmd=( ${$(fc -l $line $line)##<->} )
	display-status
}

insert-down-word()
{
	zle .insert-last-word 1
	line+=1
	word=-1
	cmd=( ${$(fc -l $line $line)##<->} )
	display-status
}

# Display the current history line and word. I had to use POSTDISPLAY as 'zle -M' does not support color
display-status()
{
	local bang start end
	bang="!$line:$(( ${#cmd}+word+1 ))"
	start=$(( ${#BUFFER}+${(c)#cmd[1,$word-1]}+${#bang}+2 ))
	end=$(( start+${(c)#cmd[$word]}+1 ))
	POSTDISPLAY="
$bang $cmd
Press <Shift><Up> to insert a word from the previous line.
Press <Shift><Down> to insert a word from the line below.
Press <Shift><Left> to insert the word to the left.
Press <Shift><Right> to insert the word to the right."
	region_highlight=( "P${#BUFFER} $(( ${#BUFFER}+${#bang}+1 )) fg=magenta" "P$start $end fg=blue,bold" )
}

zle -N insert-last-word
zle -N insert-prev-word
zle -N insert-next-word
zle -N insert-down-word