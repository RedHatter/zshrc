##
#
#   insert-pair
#     Insert the matching brace, parentheses, quote, etc.
#
##

# Wrapping character keybinds
bindkey "{" insert-pair
bindkey "[" insert-pair
bindkey "(" insert-pair
bindkey "'" insert-pair
bindkey '"' insert-pair

insert-pair ()
{
	zle self-insert
	(( $PENDING > 1 )) && return

	case $KEYS in
		'{')
			RBUFFER='}'$RBUFFER
			;;
		'[')
			RBUFFER=']'$RBUFFER
			;;
		'(')
			RBUFFER=')'$RBUFFER
			;;
		*)
			zle self-insert
			zle backward-char
			;;
	esac
}
zle -N insert-pair