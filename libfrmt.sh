frmt() {
   local _types=( "ascii" "dokuwiki" "mediawiki" "html" )
   local action="$1"; shift
   local _dokuwiki _mediawiki _ascii
   local instance="$FUNCNAME"

   declare -A _html=(
      [start]='<html><head><style>
                         details { user-select: none; }
                         details>summary span.icon {
                            width: 24px;
                            height: 24px;
                            transition: all 0.3s;
                            margin-left: auto; }
                         details[open] summary span.icon { transform: rotate(180deg); }
                         summary { display: flex; cursor: pointer; }
                         summary::-webkit-details-marker { display: none; }
                </style></head><body>\n'
      [end]='</body></html>\n'
      [foldstart]='<details><summary>%s</summary><p>\n'
      [foldend]='</p></details>\n'
      [h1]='<h1 style="font-size:160%%;">%s</h1>\n'
      [h2]='<h2 style="font-size:140%%;">%s</h2>\n'
      [h3]='<h3 style="font-size:120%%;">%s</h3>\n'
      [bold]='<b>%s</b>'
      [t_head_start]='<table border=1>\n<tr>'
      [t_head_item]='<th style="padding: 0px;">%s</th>'
      [t_head_end]='</tr>\n'
      [t_line_start]='<tr>'
      [t_line_item]='<td style="padding: 0px;">%s</td>'
      [t_line_end]='</tr>\n'
      [t_end]='</table>\n'
      [pre]='<pre>%s</pre>'
   )

   declare -A _dokuwiki=(
      [foldstart]='\n&lt;WRAP&gt;\n++++ %s |\n'
      [foldend]='++++\n&lt;/WRAP&gt;\n'
      [h1]='====== %s ======\n'
      [h2]='===== %s =====\n'
      [h3]='==== %s ====\n'
      [bold]='** %s **'
      [t_head_start]='\r'
      [t_head_item]='^ %s '
      [t_head_end]='^\n'
      [t_line_start]='\r'
      [t_line_item]='| %s '
      [t_line_end]='|\n'
      [t_end]=' '
      [pre]='  %s\n'
   )

   declare -A _mediawiki=(
      [foldstart]='<div class="toccolours mw-collapsible mw-collapsed">%s<div class="mw-collapsible-content">\n'
      [foldend]='</div></div>\n'
      [h1]='= %s =\n'
      [h2]="== %s ==\n"
      [h3]="=== %s ===\n"
      [bold]="''' %s '''"
      [t_head_start]='{|border=1\n'
      [t_head_item]='! %s\n'
      [t_head_end]=' '
      [t_line_start]='|-\n'
      [t_line_item]='| %s\n'
      [t_line_end]=' '
      [t_end]='|}\n'
      [pre]=' %s\n'
   )

   declare -A _ascii=(
      [foldstart]='\e[7m%s\e[0m\n'
      [foldend]='\r'
      [h1]='\e[1;4m%s\e[0m\n'
      [h2]='\e[4m%s\e[0m\n'
      [h3]='\e[1m%s\e[0m\n'
      [bold]='\e[1m%s\e[0m'
      [t_head_start]=' '
      [t_head_item]='\e[1m%s\e[0m\t'
      [t_head_end]='\n'
      [t_line_start]=' '
      [t_line_item]='%s\t'
      [t_line_end]='\n'
      [t_end]=' \n'
      [pre]='  %s\n'
   )

   _frmt_out() {
      if test "$_FRMTOUTPUT" = "/dev/stdout"; then
         cat
      else
         cat >> "$_FRMTOUTPUT"
      fi
   }

   _frmt_err() {
      ( >%2 printf -- "${instance}: %s\n" "${@}" ) > /dev/null
   }

   _frmt_print() {
      printf -- "${@}" | _frmt_out
   }

   if test "$instance" = "frmt"; then
      case "$action" in
         "new")
            local inst="$1"; shift
            local t="$1"; shift
            local init=1

            # ToDo: argparse
            [[ ! " ${_types[@]} " =~ " $t " ]] && {
               _frmt_err "unknown type $t"
                return 1
            }

            export _FRMTOUTPUT_${inst}="/dev/stdout"
            if test "$1" = "-f" -a "$2" != ""; then
               shift
               rm -f "$1"
               export _FRMTOUTPUT_${inst}="$1"
            fi
            test "$1" = "-b" && init=0
            export _FRMTTYPE_${inst}="$t"
            export _FRMTINIT_${inst}="$init"
            . <(declare -f $instance | sed "1 s/^${instance} /${inst} /")
            local a=_FRMTOUTPUT_${inst}
            local _FRMTOUTPUT="${!a}"
            a=$(declare -p "_${t}") && declare -A _FRMT="${a#*=}"
            test "$init" = 1 -a "${_FRMT[start]}" != "" && _frmt_print "${_FRMT[start]}"
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
      "print") _frmt_print "${@}\n" ;;
      h?|bold|foldstart|foldend|pre)
         test "${_FRMT[$action]}" = "" && 
            { _frmt_err "$action undefined"; return 1; }
         _frmt_print "${_FRMT[$action]}" "${@}"
         ;;
      t_head|t_line)
         printf "${_FRMT[${action}_start]}" | _frmt_out
         for item in "${@}"; do
            printf "${_FRMT[${action}_item]}" "$item" | _frmt_out
         done
         printf "${_FRMT[${action}_end]}" | _frmt_out
         ;;
      t_end) _frmt_print "${_FRMT[t_end]}" ;;
      "del")
         local a=_FRMTINIT_${instance}
         local _FRMTINIT="${!a}"
         test "$_FRMTINIT" = 1 -a "${_FRMT[end]}" != "" && _frmt_print "${_FRMT[end]}"
         unset _FRMTTYPE_${instance}
         unset _FRMTOUTPUT_${instance}
         unset "$instance"
      ;;
      *) _frmt_err "unknown action"; return 1; ;;
   esac
}
