#!/bin/bash

# Ensure we're using bash and fix path resolution with realpath
script_dir="$(dirname $(realpath "$0"))"
script_url="https://raw.githubusercontent.com/MrChromebox/scripts/main/"
export LC_ALL=C

# Check if we're on ChromeOS and adjust paths accordingly
if grep -q "Chrom" /etc/lsb-release ; then
    # Needed for ChromeOS/ChromiumOS v82+
    mkdir -p /usr/local/bin
    cd /usr/local/bin
else
    cd /tmp
fi

# Reset terminal and print a startup message
printf "\ec"
echo -e "\nMrChromebox Firmware Utility Script starting up"

# Check for command line parameters or expired CrOS certs
if ! curl -sLo /dev/null https://mrchromebox.tech/index.html || [[ "$1" = "-k" ]]; then
    export CURL="curl -k"
else
    export CURL="curl"
fi

# If this is not a git repository, download necessary files
if [ ! -d "$script_dir/.git" ]; then
    script_dir="."

    echo -e "\nDownloading supporting files..."
    rm -rf firmware.sh >/dev/null 2>&1
    rm -rf functions.sh >/dev/null 2>&1
    rm -rf sources.sh >/dev/null 2>&1
    $CURL -sLO ${script_url}firmware.sh
    rc0=$?
    $CURL -sLO ${script_url}functions.sh
    rc1=$?
    $CURL -sLO ${script_url}sources.sh
    rc2=$?
    if [[ $rc0 -ne 0 || $rc1 -ne 0 || $rc2 -ne 0 ]]; then
        echo -e "Error downloading one or more required files; cannot continue"
        exit 1
    fi
fi

source $script_dir/sources.sh
source $script_dir/firmware.sh
source $script_dir/functions.sh

cd /tmp

# Perform preliminary setup
prelim_setup
prelim_setup_result="$?"

# Save diagnostic report
diagnostic_report_save
troubleshooting_msg=(
    " * diagnostics report has been saved to /tmp/mrchromebox_diag.txt"
    " * go to https://forum.chrultrabook.com/ for help"
)
if [ "$prelim_setup_result" -ne 0 ]; then
    IFS=$'\n'
    echo "MrChromebox Firmware Utility setup was unsuccessful" > /dev/stderr
    echo "${troubleshooting_msg[*]}" > /dev/stderr
    exit 1
fi

# Define function before using in trap
function check_unsupported() {
    if [ "$isUnsupported" = true ]; then
        IFS=$'\n'
        echo "MrChromebox Firmware Utility didn't recognize your device" > /dev/stderr
        echo "${troubleshooting_msg[*]}" > /dev/stderr
    fi
}

trap 'check_unsupported' EXIT

menu_fwupdate
