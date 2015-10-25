#!/bin/zsh

# Keybinds to move to symbol. e.g. <Left>+1 to move to previous 1 or !. Could not use vi-find-prev-char as it reads input from user
typeset -A unshifted # Map ascii characters to their respective keyboard keys
unshifted=(' ' ' ' '!' '1' '"' "'" '#' '3' '$' '4' '%' '5' '&' '7' "'" "'" '(' '9' ')' '0' '*' '8' '+' '=' ',' ',' '-' '-' '.' '.' '/' '/' '0' '0' '1' '1' '2' '2' '3' '3' '4' '4' '5' '5' '6' '6' '7' '7' '8' '8' '9' '9' ':' ';' ';' ';' '<' ',' '=' '=' '>' '.' '?' '/' '@' '2' 'A' 'a' 'B' 'b' 'C' 'c' 'D' 'd' 'E' 'e' 'F' 'f' 'G' 'g' 'H' 'h' 'I' 'i' 'J' 'j' 'K' 'k' 'L' 'l' 'M' 'm' 'n' 'N' 'O' 'o' 'P' 'p' 'Q' 'q' 'R' 'r' 'S' 's' 'T' 't' 'U' 'u' 'V' 'v' 'W' 'w' 'X' 'x' 'Y' 'y' 'Z' 'z' '[' '[' '\' '\' ']' ']' '^' '6' '_' '-' '`' '`' 'a' 'a' 'b' 'b' 'c' 'c' 'd' 'd' 'e' 'e' 'f' 'f' 'g' 'g' 'h' 'h' 'i' 'i' 'j' 'j' 'k' 'k' 'l' 'l' 'm' 'm' 'n' 'n' 'o' 'o' 'p' 'p' 'q' 'q' 'r' 'r' 's' 's' 't' 't' 'u' 'u' 'v' 'v' 'w' 'w' 'x' 'x' 'y' 'y' 'z' 'z' '{' '[' '|' '\' '}' ']' '~' '`')

for key in $unshifted; do
	bindkey "^[[D$key" find-prev-char                               # Left + :ascii:
	bindkey "^[[C$key" find-next-char                               # Right+ :ascii:
done

find-prev-char ()
{
	local i=$CURSOR
	while (( i-- > 0 )); do
		if [[ $unshifted[$LBUFFER[$i]] == $KEYS[-1] ]]; then
			CURSOR=$i-1
			break
		fi
	done
}

find-next-char ()
{
	local i=CURSOR
	while (( i++ < ${#BUFFER} )); do
		if [[ $unshifted[$BUFFER[$i]] == $KEYS[-1] ]]; then
			CURSOR=$i-1
			break
		fi
	done
}

zle -N find-prev-char
zle -N find-next-char