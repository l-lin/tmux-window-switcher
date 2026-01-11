#!/usr/bin/env zsh
#
# Order tmux windows by most recent match in history.
#

if ! type tmux >/dev/null 2>&1; then
  return
fi

script_dir="$( cd "$( dirname "${0}" )" && pwd )"
history_tracker="${script_dir}/history-tracker.sh"

switch_to_window() {
  local session_name="${1}"
  local window_name="${2}"
  local window_index="${3}"

  "${history_tracker}" save "${session_name}" "${window_name}" "${window_index}"

  tmux switch-client -t "${session_name}:${window_index}"
}

if [[ "${1}" == "switch" ]]; then
  switch_to_window "${2}" "${3}" "${4}"
  return
fi

current_info="$(tmux display-message -p '#S,#W')"
current_session="${current_info%,*}"
current_window="${current_info#*,}"

cmd="${history_tracker} list | grep -v \"^${current_session},${current_window},\" | column -t -s ','"
eval "${cmd}" \
  | fzf --no-reverse \
    --header-lines 1 \
    --header 'CR: switch window | C-x: kill window' \
    --preview 'tmux capture-pane -ep -t {1}:{3}' \
    --bind "ctrl-x:execute-silent(tmux kill-window -t {1}:{3})+reload(${cmd})" \
    --bind 'enter:execute-silent('"${script_dir}"'/window-switcher-history.sh switch {1} {2} {3})+abort'

