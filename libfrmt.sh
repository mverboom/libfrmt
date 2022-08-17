frmt() {
	local _types=( "ascii" "dokuwiki" "mediawiki" )
	local action="$1"; shift
	local _dokuwiki _mediawiki _ascii
	local instance="$FUNCNAME"

	declare -A _dokuwiki=(
		[foldstart]='\n&lt;WRAP&gt;\n++++ %s |'
		[foldend]='++++\n&lt;/WRAP&gt;\n'
		[h1]='====== %s ======'
		[h2]='===== %s ====='
		[h3]='==== %s ===='
		[bold]='** %s **'
		[t_head_start]=''
		[t_head_item]='^ %s '
		[t_head_end]='^\n'
		[t_line_start]=''
		[t_line_item]='| %s '
		[t_line_end]='|\n'
		[t_end]=''
		[pre]='  %s'
	)

	declare -A _mediawiki=(
		[foldstart]='<div class="toccolours mw-collapsible mw-collapsed">%s<div class="mw-collapsible-content">'
		[foldend]='</div></div>'
		[h1]='= %s ='
		[h2]="== %s =="
		[h3]="=== %s ==="
		[bold]="''' %s '''"
		[t_head_start]='{|border=1\n'
		[t_head_item]='! %s\n'
		[t_head_end]=''
		[t_line_start]='|-\n'
		[t_line_item]='| %s\n'
		[t_line_end]=''
		[t_end]='|}'
		[pre]=' %s'
	)

	declare -A _ascii=(
		[foldstart]='\e[7m%s\e[0m'
		[foldend]=' '
		[h1]='\e[1;4m%s\e[0m'
		[h2]='\e[4m%s\e[0m'
		[h3]='\e[1m%s\e[0m'
		[bold]='\e[1m%s\e[0m'
		[t_head_start]=''
		[t_head_item]='\e[1m%s\e[0m\t'
		[t_head_end]='\n'
		[t_line_start]='\n'
		[t_line_item]='%s\t'
		[t_line_end]='\n'
		[t_end]=' '
		[pre]='  %s'
	)

	_frmt_err() {
		printf -- "${instance}: %s\n" "${@}" > /dev/stderr
	}

	_frmt_print() {
		printf -- "${@}" >> $_FRMTOUTPUT
		echo >> $_FRMTOUTPUT
	}

	if test "$instance" = "frmt"; then
		case "$action" in
			"new")
				local inst="$1"
				local t="$2"
				[[ ! " ${_types[@]} " =~ " $t " ]] && { _frmt_err "unknown type $t"; return 1; }
				export _FRMTTYPE_${inst}="$t"
				export _FRMTOUTPUT_${inst}="/dev/stdout"
				. <(declare -f $instance | sed "1 s/^${instance} /${inst} /")
				return 0
			;;
			*) _frmt_err "unknown action"; return 1; ;;
		esac
	fi

	local a=_FRMTOUTPUT_${instance}
	local _FRMTOUTPUT="${!a}"
	a=_FRMTTYPE_${instance}
	local _FRMTTYPE="${!a}"
	a=$(declare -p "_${_FRMTTYPE}") && declare -A _FRMT="${a#*=}"

	case "$action" in
		"output") test "$1" = "-f" && { shift; rm -f "$1"; }
                    export _FRMTOUTPUT_${instance}="$1" ;;
		"print") _frmt_print "${@}" ;;
		h?|bold|foldstart|foldend|pre)
			test "${_FRMT[$action]}" = "" && 
				{ _frmt_err "$action undefined"; return 1; }
			_frmt_print "${_FRMT[$action]}" "${@}"
			;;
		t_head|t_line)
			printf "${_FRMT[${action}_start]}" >> $_FRMTOUTPUT
			for item in "${@}"; do
				printf "${_FRMT[${action}_item]}" "$item" >> $_FRMTOUTPUT
			done
			printf "${_FRMT[${action}_end]}" >> $_FRMTOUTPUT
			;;
		t_end) _frmt_print "${_FRMT[t_end]}" ;;
		"del")
			unset _FRMTTYPE_${instance}
			unset _FRMTOUTPUT_${instance}
			unset "$instance"
		;;
		*) _frmt_err "unknown action"; return 1; ;;
	esac
}
