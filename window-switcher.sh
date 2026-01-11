#!/usr/bin/env zsh
#
# Switch TMUX window using FZF.
# src: https://www.reddit.com/r/tmux/comments/rfae7o/navigate_sessions_windows_with_fzf/
#

if ! type tmux >/dev/null 2>&1; then
  return
fi

current_info="$(tmux display-message -p '#S,#W')"
current_session="${current_info%,*}"
current_window="${current_info#*,}"

cmd='echo -e "Session name,Window name,Window index\n$(tmux list-windows -a -F '"'"'#{session_name},#{window_name},#{window_index}'"'"')" | grep -v "^'"${current_session}"','"${current_window}"'," | column -t -s ","'
eval "${cmd}" \
  | fzf --no-reverse \
    --header-lines 1 \
    --header 'CR: switch window | C-x: kill window'\
    --preview 'tmux capture-pane -ep -t {1}:{3}' \
    --bind "ctrl-x:execute-silent(tmux kill-window -t {1}:{3})+reload(${cmd})" \
    --bind 'enter:execute-silent(tmux switch-client -t {1}:{3})+abort'
