##
#
# Cool things I made
#   display-and-space
#     Display command syntax from manfiles.
#
#   spin-directory
#     Loop through directory stack.
#
#   Run previous command as root
#     Edits the command on accept-line to add sudo at the beginning of the previous command. Has the 
#     advantage over an alias that it stores the new command in history.
#
#   insert-pair
#     Insert the matching brace, parentheses, quote, etc.
#
#   enter-history-search
#     An extended incremental history search. Searches for a line that contains all words.
#     A '!' (can be escaped '\!') in front of a word to search for a line that does not contain that word.
#     Use tab to insert a word instead of selecting the history line.
#     Note: there has got to be a better way to do key bindings!
#
#   Insert History word
#     Extended keybinds for insert-last-word. Shift+Up calls insert-last-word and displays the current
#     history line in POSTDISPLAY, Shift+Left and +Right will then select the corresponding words on the line.
#
#   Move to Key
#     Arrow+Key moves to the key (like vi-find-next-char). Could not use vi-find-next-char as it does not support
#     specifying as a parameter what key to goto.
#
#   Smart edit Function
#     Edit a file in EDITOR or VISUAL depending whether we have graphics, use sudo if needed. If the file is not
#     in current directory use 'locate' to find files and prompt the user to select one.
#
#   Prompt Available
#     Display a progress bar on gnome-terminal when any terminal has a command running.
#
#   Notify on Long Command
#     Display a notificaion when a command over 5 seconds long finishes.
#
# Scripts I use
# 	auto-fu by Takeshi Banse             - auto completion as you type
#   zsh-syntax-highlighting by zsh-users - fish like syntax highlighting
#   rationalise-dot by Mikael Magnusson  - expanding additional dots to move up a directory
#
# TODO
#   Use colors when displaying keybindings
#   Display as many matches as possible when there are too many in completion.
#   Fix auto-fu to play nice with undo.
#   Expand everything on space. (expand-word doesn't work?)
#   Fix colors for file completion so they match ls.
#   Display unity progress bar while dd, apt-get, etc. are running.
#   Use vi-match-bracket
#   More colors!!!
#
##

echo  -e "Hold \e[96m<Left>\e[0m or \e[96m<Right>\e[0m and press a key to move to the indicated character.
Press \e[96m<Ctrl><Up>\e[0m to start advanced history search.
Press \e[96m<Shift><Up>\e[0m to insert a word from history.
Press \e[96m<Crtl><Down>\e[0m to push input to next command prompt.
Press \e[96m<Ctrl><Left>\e[0m or \e[96m<Right>\e[0m to move backward or forward a word, respectively.
Press \3[96m<Ctrl><Delete>\e[0m to delete a word.
Press \e[96m<ESC>\e[0m to clear entire line.
Type \e[96m\\\\\\\\\e[0m to start a new line.
Press \e[96m<Ctrl>h\e[0m to display man pages for current command.
Press \e[96m<Ctrl>\`\e[0m and \e[96m<Ctrl><Shift>\`\e[0m to cycle through directories on stack.
\e[96mdirs\e[0m will display directory stack.
\e[96m~n\e[0m will changed to the nth directory in the stack, \e[96m-\e[0m is equivalent to \e[96m~1\e[0m"

path+=('/home/timothy/Projects/Java/Android/sdk/platform-tools' '/home/timothy/Projects/Java/Android/sdk/tools')

DIRSTACKSIZE=10
DIRSTACKFILE=~/.dirstack

accept_line_functions=( )

{ source /etc/zsh/modules/util.zsh }
{ source /etc/zsh/modules/many.zsh }
{ source /etc/zsh/modules/insert_word.zsh }
{ source /etc/zsh/modules/insert_pair.zsh }
{ source /etc/zsh/modules/directory_stack.zsh }
{ source /etc/zsh/modules/history_search.zsh }
# { source /etc/zsh/modules/move_to_key.zsh } causes cursor to stick
{ source /etc/zsh/modules/notify.zsh }
{ source /etc/zsh/modules/help.zsh }

# General keybinds
KEYTIMEOUT=20
bindkey "^[[D"      backward-char                                   # Left
bindkey "^[[C"      forward-char                                    # Right
bindkey "^[[B"      down-line-or-history                            # Down          - move down a line, or goto next history
bindkey "^[[A"      up-line-or-history                              # Up            - move up a line, or goto previous history
bindkey "^[[F"      end-of-line-hist                                # End           - goto end of line
bindkey "^[[H"      beginning-of-line-hist                          # Home          - goto beginning of line
bindkey "^?"        backward-delete-char                            # Backspace
bindkey "^[[3~"     delete-char                                     # Delete
bindkey "^["        kill-whole-line                                 # Esc           - cut entire line
bindkey "^[[1;5D"   backward-word                                   # Ctrl + Left   - move backward a word
bindkey "^[[1;5C"   forward-word                                    # Ctrl + Right  - move forward a word
bindkey "^[[1;5B"   push-input                                      # Crtl + Down   - push input to next command prompt
bindkey "^[[1;3B"   infer-next-history                              # Alt  + Down   - try to predict what you are going to do by looking a history
bindkey "^[[3;5~"   kill-word                                       # Ctrl + Delete - cut word
bindkey "[6~"       end-of-history                                  # Page Down     - Go to the last history event
bindkey '\\\\'      vi-open-line-below                              # \\            - new line

view-history ()
{
	zle push-input
	many.init History $history
	while true; do
		readkey
		many.read $REPLY || break
	done
	BUFFER=$REPLY
}
zle -N view-history
bindkey "^h" view-history

{ source /etc/zsh/modules/auto_fu.zsh }

# Run last command as root
accept-line ()
{
	if [[ $BUFFER == "g" ]]; then
		BUFFER="sudo "$(fc -ln -1)
	fi

	for function in $accept_line_functions; do
		$function
	done

	zle .accept-line
}
zle -N accept-line

# General aliases
alias trash=gvfs-trash
alias o=gnome-open
alias grep='grep --color'
alias l='ls --color --group-directories-first'
alias ls='ls --color --group-directories-first'
alias ll='ls --group-directories-first -lhAF'
alias ps='ps -A -o user,pid,time,fname,command'
alias mkdir='mkdir -p'        # Make parent directories as needed
alias rm='rm -v'
alias apt='sudo apt-get'
alias apti='apt install'
alias apts='apt-cache search'
alias aptf='apt-file search'
alias -- -='~1'                         # '-' last directory
alias dirs='dirs -v'

# aliases for coloring with grc
if [[ -n $(which grc) ]]; then
	alias color='grc'
	alias ll='grc ls --group-directories-first -lhAF'
	alias ps='grc ps -A -o user,pid,time,fname,command'
	alias diff='grc diff'
	alias make='grc make'
	alias gcc='grc gcc'
	alias configure='grc configure'
	alias ld='grc ld'
	alias ping='grc ping'

	# I don't use these, but why not?
	alias traceroute='grc traceroute'
	alias netstat='grc netstat'
	alias wdiff='grc wdiff'
	alias ldap='grc ldap'
	alias cvs='grc cvs'
fi

# Git aliases
alias commit='git commit -a'
alias push='git push'
alias recommit='git commit --amend'
alias delete='git reset --soft HEAD~1'
alias force='git push -f'
alias log='git log --pretty=oneline'

# Colors for less (manpages)
export LESS_TERMCAP_mb=$(printf "\e[1;4;34m") \
LESS_TERMCAP_md=$(printf "\e[1;34m") \
LESS_TERMCAP_me=$(printf "\e[0m") \
LESS_TERMCAP_se=$(printf "\e[0m") \
LESS_TERMCAP_so=$(printf "\e[0;40;37m") \
LESS_TERMCAP_ue=$(printf "\e[0m") \
LESS_TERMCAP_us=$(printf "\e[4;32m") \

# General settings
setopt AUTO_NAME_DIRS               # Any variable that is a directory can be expanded via ~var syntax
setopt AUTO_CD                      # Tries to cd into any directory executed on
setopt EXTENDED_GLOB                # Treat the '#', '~' and, '^' characters as part of patterns for filename generation
setopt MULTIOS                      # Perform implicit tees when multiple redirections are attempted. Can be a problem
setopt CORRECT_ALL                  # Try to correct spelling of all arguments. Can be irritating
setopt BRACE_CCL                    # Allow brace expansion in the form of foo{a-z}bar
setopt NO_CLOBBER                   # Does not allow '>' redirection to truncate existing files, and '>>' to create files

# History settings
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.history

setopt INC_APPEND_HISTORY           # Append lines to history file as they are executed.
setopt EXTENDED_HISTORY             # Save beginning time and time elapsed
setopt HIST_IGNORE_ALL_DUPS         # Delete duplicate commands
setopt HIST_REDUCE_BLANKS           # Collapse whitespace
setopt HIST_IGNORE_SPACE            # Commands that start with a space will not be add to history

# Setup git info styles for prompt
autoload -Uz vcs_info

# Show +N/-N when your local branch is ahead-of or behind remote HEAD.
zstyle ':vcs_info:git*+set-message:*' hooks git-st
+vi-git-st() {
	local ahead behind
	local -a gitstatus

	# for git prior to 1.7
	# ahead=$(git rev-list origin/${hook_com[branch]}..HEAD | wc -l)
	ahead=$(git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l)
	(( $ahead )) && gitstatus+=( "+${ahead} " )

	# for git prior to 1.7
	# behind=$(git rev-list HEAD..origin/${hook_com[branch]} | wc -l)
	behind=$(git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l)
	(( $behind )) && gitstatus+=( "-${behind} " )

	hook_com[misc]+=${(j:/:)gitstatus}
}

#zstyle ':vcs_info:*' get-revision true
zstyle ':vcs_info:*' stagedstr '+'              # Uncommitted changes
zstyle ':vcs_info:*' unstagedstr '+'            # Unstaged changes 
zstyle ':vcs_info:*' check-for-changes 'yes'    # Does not display unless set
zstyle ':vcs_info:*' actionformats '%F{mag}(%F{red}%m%F{white}%b%B%u%c%%b%F{mag}|%F{white}%a%F{mag})%f '
zstyle ':vcs_info:*' formats '%F{mag}(%F{red}%m%F{white}%b%B%u%c%%b%F{mag})%f '

# Set up prompt
setopt prompt_subst     # Allow variable expansion in prompt strings
# Left prompt: Red if root, + if in sub-shell, print exit status, >
PS1='%(!.%F{red}.%F{blue})%(2L.+.)> %(?..(%?%) )%k%f'
# Right prompt: git info, current dir green when writable yellow otherwise, red if root, time Ding! on hour
RPS1='${vcs_info_msg_0_}${pwd_color}%~ %(!.%F{red}.%F{blue})%(t.Ding!.%D{%L.%M.%S}) %k%f'

# This was written entirely by Mikael Magnusson (Mikachu)
# Type '...' to get '../..' with successive .'s adding /..
rationalise-dot ()
{
	local MATCH
	if [[ $LBUFFER =~ '(^|/| |      |'$'\n''|\||;|&)\.\.$' ]]; then
	  LBUFFER+=/
	  zle self-insert
	  zle self-insert
	else
	  zle self-insert
	fi
}
zle -N rationalise-dot
bindkey -M afu . rationalise-dot

precmd_functions=( vcs_info $precmd_functions )

# Needed for prompt
colors ()
{
	if [[ -w $PWD ]]; then
		pwd_color="%F{green}"
	else
		pwd_color="%F{yellow}"
	fi
}

chpwd_functions=( colors $chpwd_functions )
colors

command_not_found_handler ()
{
	[[ -f /usr/lib/command-not-found ]] || return
	/usr/lib/command-not-found --no-failure-msg -- $1
}