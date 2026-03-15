#!/usr/bin/env bash

SCRIPT_DIR="$NESONOBININSTALLATIONDIR"
CERT_CHECK_FILE="$HOME/Nextcloud/websites/cert_check_file.txt"

if command -v uv &> /dev/null; then
	uv run --project "$SCRIPT_DIR" python "$SCRIPT_DIR"/cert_list.py --from_file "$CERT_CHECK_FILE"
else
	# fallback: extract deps from pyproject.toml and use venv+pip
	# shellcheck disable=SC2207
	DEPS=($(python3 -c "
import tomllib, pathlib, re
data = tomllib.loads(pathlib.Path('$SCRIPT_DIR/pyproject.toml').read_text())
for d in data.get('project', {}).get('dependencies', []):
    print(re.split(r'[><=!~]', d)[0])
"))

	if [[ ! -r "$HOME/venv/bin/activate" ]]; then
		python3 -m venv "$HOME/venv"
	fi
	# shellcheck disable=SC1091
	source "$HOME/venv/bin/activate"
	pip install "${DEPS[@]}"

	python "$SCRIPT_DIR"/cert_list.py --from_file "$CERT_CHECK_FILE"

	deactivate
fi
