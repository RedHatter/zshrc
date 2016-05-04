##
#   Notify on Long Command
#     Display a notificaion when a command takes over 5 seconds to execute.
##

typeset -F2 SECONDS     # Command duration up to tenths of a second

set_cmd ()
{
	last_cmd=$BUFFER
}

accept_line_functions=( set_cmd $accept_line_functions )

notify-maybe ()
{
	(( $? == 0 )) && title="Succeeded" || title="Failed"    # Must be first command
	((cmd_time=SECONDS-cmd_time))

	if ((cmd_time >= 5)); then
		
		if (( cmd_time > 60 )); then
			minutes=$(printf "%.0f\n" $((cmd_time/60)))
			(( $minutes != 1 )) && s="s"
			seconds=$(printf "%.0f\n" $((cmd_time%60)))
			time="Run time\t$minutes minute$s and $seconds seconds."
		else
			time=$(printf "%.0f\n" $cmd_time)
			time="Run time\t$time seconds."
		fi
		notify-send $title "Command\t$last_cmd
$time"
	fi
	cmd_time=-1
}

start ()
{
	cmd_time=$SECONDS
}

precmd_functions=( notify-maybe $precmd_functions )
preexec_functions=( start $preexec_functions )