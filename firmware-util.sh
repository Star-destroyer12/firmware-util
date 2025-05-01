#!/bin/bash

# Base URL for downloading raw scripts from GitHub repository
script_url="https://raw.githubusercontent.com/Star-destroyer12/firmware-util/main/"

# Ensure we're using bash and fix path resolution with realpath
script_dir="$(dirname "$(realpath "$0")")"
export LC_ALL=C

# Check for ChromeOS and adjust paths accordingly
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

# If this is not a git repository, download necessary files from the new URL
if [ ! -d "$script_dir/.git" ]; then
    script_dir="."

    echo -e "\nDownloading supporting files..."
    rm -rf firmware-util.sh >/dev/null 2>&1
    rm -rf functions.sh >/dev/null 2>&1
    rm -rf sources.sh >/dev/null 2>&1

    # Download files from the raw GitHub repository URLs
    curl -sLO ${script_url}firmware-util.sh
    rc0=$?
    curl -sLO ${script_url}functions.sh
    rc1=$?
    curl -sLO ${script_url}sources.sh
    rc2=$?

    # Check if any of the downloads failed
    if [[ $rc0 -ne 0 || $rc1 -ne 0 || $rc2 -ne 0 ]]; then
        echo -e "Error downloading one or more required files; cannot continue"
        exit 1
    fi
fi

# Source the downloaded scripts
source $script_dir/sources.sh
source $script_dir/firmware-util.sh
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
    echo "MrChromebox Firmware Utility
