#!/usr/bin/env bash

key_binding_option='@tmux-window-switcher-key-binding'
key_binding_option_default='C-g'
width_option='@tmux-window-switcher-width'
width_option_default='90%'
height_option='@tmux-window-switcher-height'
height_option_default='90%'
order_strategy_option='@tmux-window-switcher-order-strategy'
order_strategy_option_default='history'

get_tmux_option() {
	local option="${1}"
	local default_value="${2}"

	option_value=$(tmux show-option -gqv "$option")

	if [ -z "${option_value}" ]; then
		echo "${default_value}"
	else
		echo "${option_value}"
	fi
}

key_binding=$(get_tmux_option "${key_binding_option}" "${key_binding_option_default}")
width=$(get_tmux_option "${width_option}" "${width_option_default}")
height=$(get_tmux_option "${height_option}" "${height_option_default}")
order_strategy=$(get_tmux_option "${order_strategy_option}" "${order_strategy_option_default}")

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ "${order_strategy}" == "history" ]]; then
  switcher_script="${script_dir}/window-switcher-history.sh"
else
  switcher_script="${script_dir}/window-switcher.sh"
fi

tmux bind-key "${key_binding}" \
  popup -w "${width}" -h "${height}" -E \
  "${switcher_script} 2> /tmp/tmux-window-switcher.log"
