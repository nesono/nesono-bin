#!/usr/bin/env bash

if [[ ! -r "$HOME/venv/bin/activate" ]]; then
	python -m venv "$HOME/venv"
	# shellcheck disable=SC1091
	source "$HOME/venv/bin/activate"
	pip install click colorama
else
	# shellcheck disable=SC1091
	source "$HOME/venv/bin/activate"
fi

python "$NESONOBININSTALLATIONDIR"/cert_list.py --from_file "$HOME/Nextcloud/websites/cert_check_file.txt"

deactivate
