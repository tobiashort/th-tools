#!/usr/bin/env bash

set -e

if [ "$EUID" -ne 0 ]
    then echo "Please run as root."
    exit
fi

CLR_WHITE_ON_RED='\033[1;37m\033[41m'
CLR_BLACK_ON_GREEN='\033[0;30m\033[42m'
CLR_RESET='\033[0m'

LOG="/tmp/th-tools"
rm -rf "$LOG"
mkdir -p "$LOG"

INST="/opt/th-tools"
BIN="$INST/bin"
rm -rf "$INST"
mkdir -p "$BIN"
pushd "$INST" > /dev/null

BIN_PREFIX="th"

function install_error() {
    tool="$1"
    echo -ne "\r["
    echo -ne "$CLR_WHITE_ON_RED"
    echo -n "ERR "
    echo -ne "$CLR_RESET"
    echo "] $tool"
}

function install_success() {
    tool="$1"
    echo -ne "\r["
    echo -ne "$CLR_BLACK_ON_GREEN"
    echo -n "DONE"
    echo -ne "$CLR_RESET"
    echo "] $tool"
}

function install_go_project() {
    tool="$1"
    echo -n "[....] $tool "
    set +e
    GIT_TERMINAL_PROMPT=0 git clone https://github.com/tobiashort/"$tool" > "$LOG/$tool.log" 2>&1
    if [ "$?" != "0" ]; then
        install_error "$tool"
        return
    fi
    set -e
    pushd "$tool" > /dev/null
    set +e
    go build > "$LOG/$tool.log" 2>&1
    if [ "$?" != "0" ]; then
        install_error "$tool"
        popd > /dev/null
        return
    fi
    set -e
    ln -s "$(pwd)/$tool" "$BIN/$BIN_PREFIX-$tool"
    popd > /dev/null
    install_success "$tool"
}

install_go_project bin2hex
install_go_project cat
install_go_project cidr-to-mask
install_go_project ciphersuite-checker
install_go_project cols
install_go_project cutnstitch
install_go_project ellipsis
install_go_project file-transfer-over-powershell
install_go_project git-cleaner
install_go_project hex2bin
install_go_project html-decode
install_go_project html-encode
install_go_project ip-sort
install_go_project jwk-rsa-to-der
install_go_project jwt-decode
install_go_project jwt-encode
install_go_project len-sort
install_go_project line
install_go_project mask-to-cidr
install_go_project pipe-sum
install_go_project ports-to-port-ranges
install_go_project raw-deflate
install_go_project raw-inflate
install_go_project rfc33392unixtime
install_go_project subnet-to-list
install_go_project uniqplot
install_go_project unixtime2rfc3339
install_go_project url-encode-all
install_go_project url-path-decode
install_go_project url-path-encode
install_go_project url-query-decode
install_go_project url-query-encode

popd > /dev/null

echo "---"
echo "Logs:     $LOG"
echo "Binaries: $BIN"
echo "---"
