#!/bin/bash
set -Eeuxo pipefail

# -----------------------------------------------------------------------------
# This general entrypoint script provides the control structure for dealing 
# with all possible commands supplied to this container. 
#
# entrypoint.appenv.sh provides a general app environment and entrypoint.d 
# folder scripts are executed in their alphabetical where needed.
#
# It is meant to be adapted or extended in downstream containers.
# -----------------------------------------------------------------------------

# shellcheck disable=SC1091
source /entrypoint.appenv.sh
# shellcheck disable=SC1091
source /entrypoint.sourced.sh
set +x

# Implemented command options
if [ "$#" -eq 0 ]; then
	set -- run "$@"
fi


CMD=( "$@" )

set +u

if [ "$1" = 'run' ]; then
	sourceScriptsInFolder "/entrypoint.d"
	CMD=("${ODOO_CMD}"
		"--addons-path"
		"${ODOO_ADDONSPATH}"
		"${CMD[@]:1}")
fi

if [ "$1" = 'shell' ]; then
	database="$1"
	sourceScriptsInFolder "/entrypoint.d"
	CMD=("${ODOO_CMD}"
		"shell"
		"--addons-path"
		"${ODOO_ADDONSPATH}"
		"-d" "${database}"
		"${CMD[@]:1}")
fi

if [ "$1" = 'scaffold' ]; then
	CMD=("${ODOO_CMD} ${CMD[@]}")
fi

if [ "$1" = 'deploy' ]; then
	CMD=("${ODOO_CMD} ${CMD[@]}")
fi

if [ "$1" = 'apply-patches' ]; then
	# additional arguments will be passed to patch
	# Bind mount (writable) you odoo folder
	# while appling those patches
	CMD=("apply-patches --quiet ${CMD[@]:1}")
fi
set -u

set -x
exec "${CMD[@]}"