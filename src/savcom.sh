#! /usr/bin/env bash
#  ___  __ ___   _____ ___  _ __ ___  
# / __|/ _` \ \ / / __/ _ \| '_ ` _ \ 
# \__ \ (_| |\ V / (_| (_) | | | | | |
# |___/\__,_| \_/ \___\___/|_| |_| |_|
#                                     
# Copyright (C) 2021-2024, Stéphane MEYER.
#
# SAVCOM is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>
#
# SAVCOM
# C : 2021/04/19
# M : 2024/05/13
# D : Save commands.

declare __version="0.2.1"

declare SAVDIR="$HOME/.config/savcom/com"
declare BINDIR="$HOME/.local/bin"

_help() {
cat << HELP
savcom: version ${__version}.
Save commands.

Commands:
  savcom                                   - reads from standard input.
  savcom do <name> '<command> [arguments]' - create/replace.
  savcom ed <name>                         - edit.
  savcom cp <name> <newname>               - copy.
  savcom mv <name> <newname>               - rename.
  savcom rm <name>                         - delete.
  savcom dp <file>                         - dump existing shortcuts in a file.
  savcom ls [name|glob]                    - print shortcuts list.
  savcom fix                               - search and fix broken/missing shortcut links.
  savcom help                              - show this help and exit.
  savcom version                           - show program version and exit.

HELP
}

_msg() {
  # error/message display.

  local _type msg

  case $1 in
    E) _type="error: "; msg="$2" ;;   # error
    W) _type="warning: "; msg="$2" ;; # warning
    M) msg="$2"                       # message
  esac

  case $1 in
    E | W ) >&2 echo "${_type}${msg}" ;;
        M ) echo "$msg"
  esac
}

confirm() {
  # ask user for confirmation.

  local prompt
  prompt="${1:-"sure?"}"

  printf "%s [y/N]: " "$prompt"
  read -r
  [[ ${REPLY,,} == "y" ]] && return 0
  return 1
}

do_com() {
  # create/modify given command shortcut
  
  local name cmd
  name=$1; shift
  cmd=("$@")

  [[ ! $name || ! ${cmd[*]} ]] && {
    _msg E "missing parameters."
    return 1
  }

  # does command shortcut already exist?
  local _com
  _com="$(which "$name" 2> /dev/null)" && {
    if [[ $(readlink -f "$_com") =~ \.com$ ]]; then
      [[ $NOCONFIRM ]] && {
        _msg M "skipped: $name already exists."
        return 0
      }
      _msg W "a command shortcut named '${name}' already exists."
      confirm "overwrite?" || return 1
      local FORCE=1
    else
      _msg E "'${name}' found in ${_com}."
      return 1
    fi
  }

  [[ -d $SAVDIR ]] ||
    mkdir -p "$SAVDIR"

  local com
  com="$SAVDIR/${name}.com"

  local script

read -d "" -r script <<- SAVCOM
#! /usr/bin/env sh
${cmd[@]}
SAVCOM

  echo -e "$script" > "$com"
  chmod 700 "$com"

  [[ $FORCE ]] && rm "${BINDIR}/${name}"
  ln -s "$com" "${BINDIR}/${name}" &&
    _msg M "${name}: command shortcut created."
}

ed_com() {
  local name
  name="$1"

  [[ $name ]] || {
    _msg E "command shortcut name missing."
    return 1
  }

  local com
  com="${SAVDIR}/${name}.com"

  if [[ -a $com ]]; then
    [[ $EDITOR ]] || {
      _msg E "EDITOR environment variable not set."
      return 1
    }
    "${EDITOR}" "$com"
  else
    _msg E "${name}: no such command shortcut."
    return 1
  fi
}

op_com() {
  local cmd from to msg
  cmd=$1; shift
  from="$1"
  to="$2"

  [[ ! $from || ! $to ]] && {
    _msg E "missing parameters."
    return 1
  }

  which "$to" &> /dev/null && {
    _msg E "${to} is an existing command/com."
    return 1
  }

  local com_src link_src
  com_src="${SAVDIR}/${from}.com"
  link_src="${BINDIR}/${from}"

  if [[ -a $com_src ]] && [[ -L $link_src ]]; then
    local com_dst link_dst
    com_dst="${SAVDIR}/${to}.com"
    link_dst="${BINDIR}/${to}"

    "$cmd" "$com_src" "$com_dst" 2> /dev/null || {
      [[ $cmd  == "cp" ]] && msg="copy"
      [[ $cmd  == "mv" ]] && msg="rename"
      _msg E "${from} -> ${to}: could not ${msg}."
      return 1
    }

    [[ $cmd == "mv" ]] && rm "$link_src"
    ln -s "$com_dst" "$link_dst" && {
      [[ $cmd  == "cp" ]] && msg="copied"
      [[ $cmd  == "mv" ]] && msg="renamed"
      _msg M "${from} -> ${to}: command shortcut ${msg}."
    }
  else
    _msg E "no such command shortcut: ${from}."
    return 1
  fi
}

rm_com() {
  [[ $1 ]] && {
    local name dst link
    name="$1"
    dst="${SAVDIR}/${name}.com"
    link="${BINDIR}/${name}"

    [[ -a $dst ]] || {
      _msg E "${name}: no such command shortcut."
      return 1
    }
    [[ $NOCONFIRM ]] || {
      confirm "warning: delete '${name}' command shortcut?" || return 1
    }

    rm "$link" 2> /dev/null
    rm "$dst" 2> /dev/null || {
      _msg E "${name}: could not delete command shortcut"
      return 1
    }
    _msg M "${name}: command shortcut deleted."
    return 0
  }
  _msg E "command shortcut name missing."
}

ls_com() {
  local _com name cmd

  [[ $1 == "-d" ]] && { shift; local DUMP=1; }
  
  [[ $1 ]] && _com="$1" || _com="*"

  compgen -G "${SAVDIR}/${_com}.com" &> /dev/null || {
    >&2 echo "no result."
    return 1
  }
  
  for f in "${SAVDIR}"/${_com}.com; do
    name="$(basename "${f%*.com}")"
    while read -r; do
      [[ $REPLY =~ ^#.+$ ]] && continue
      cmd="$REPLY"
    done < "$f"
    if [[ $DUMP ]]; then
      printf "do %s %s\n" "$name" "$cmd"
    else
      printf "%s=%s\n" "$name" "$cmd"
    fi
  done
}

dp_com() {
  # dump existing command shortcuts into a file.

  [[ $1 ]] || {
    _msg E "filename missing."
    return 1
  }

  [[ -a "$1" ]] && {
    _msg W "$1 already exists,"
    confirm "overwrite?" || return 1
  }

  ls_com -d > "$1"

  _msg M "done."
}

fix_coms() {
  # search and fix broken/missing shortcut links.
  local f name link state count=0
  for f in ${SAVDIR}/*.com; do
    name="$(basename $f)"
    name="${name//.com}"
    # broken link
    link="$(readlink -q ${BINDIR}/${name})"
    [[ $link ]] && ! [[ -f "$link" ]] && {
      if ! [[ -f $link ]]; then
        confirm "warning: delete broken link ${name}?" &&
          rm "${BINDIR}/${name}" &> /dev/null
      fi
    }
    # missing link
    which "${BINDIR}/${name}" &> /dev/null || {
      ln -s "$f" "${BINDIR}/${name}" && {
        _msg M "${name}: missing [fixed]"
        ((count++))
    }
  }
  done
  ((count)) &&
    _msg M "fixed $((count)) links."
  ((count)) ||
    _msg M "nothing to do."
}

if (( $# > 0 )); then
  case $1 in
    do     ) shift; do_com "$@" ;;
    ed     ) shift; ed_com "$@" ;;
    cp     ) shift; op_com "cp" "$@" ;;
    mv     ) shift; op_com "mv" "$@" ;;
    rm     ) shift; rm_com "$@" ;;
    dp     ) shift; dp_com "$@" ;;
    ls     ) shift; ls_com "$@" ;;
    fix    ) shift; fix_coms   ;;
    help   ) _help ;;
    version) _msg M "savcom version ${__version}." ;;
    *      ) _msg E "invalid command: $1"; exit 1
  esac
else
  NOCONFIRM=1
  LINE=0
  while IFS= read -r; do
    ((++LINE))

    # ignore comments, dp, ed, ls and help commands...
    [[ $REPLY =~ ^#.*$ ]] && continue
    [[ $REPLY =~ ^cp.*$ ]] && continue
    [[ $REPLY =~ ^mv.*$ ]] && continue
    [[ $REPLY =~ ^ed.*$ ]] && continue
    [[ $REPLY =~ ^dp.*$ ]] && continue
    [[ $REPLY =~ ^ls.*$ ]] && continue
    [[ $REPLY =~ ^help.*$ ]] && continue
    [[ $REPLY =~ ^fix.*$ ]] && continue

    mapfile -t arglist <<< "${REPLY// /$'\n'}"
    set -- "${arglist[@]}"
    echo -n "${1}: "
    case $1 in
      do) shift; do_com "$@" || { _msg E "on line ${LINE}."; } ;;
      rm) shift; rm_com "$@" || { _msg E "on line ${LINE}."; } ;;
      * ) _msg E "invalid command: ${1} (line ${LINE})."; exit 1
    esac
  done
fi
