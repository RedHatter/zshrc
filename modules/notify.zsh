typeset -F2 SECONDS     # Command duration up to tenths of a second

set_cmd ()
{
	last_cmd=$BUFFER
}

accept_line_functions=( set_cmd $accept_line_functions )

notify-maybe ()
{
	((cmd_time=SECONDS-cmd_time))

	if ((cmd_time >= 5)); then
		
		(( $? == 0 )) && title="Succeeded" || title="Failed"
		
		if (( cmd_time > 60 )); then
			time="Run time\t$((cmd_time/60)) minutes."
		else
			time="Run time\t$cmd_time seconds."
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