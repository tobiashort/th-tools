#!/usr/bin/env bash

set -e

if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    exit
fi

DIR="/opt/th-tools"
BIN="$DIR/bin"
BIN_PREFIX="th"
rm -rf "$DIR"
rm -rf "$BIN"
mkdir -p "$DIR"
mkdir -p "$BIN"
pushd "$DIR" > /dev/null

function install_shell_script() {
    repo="$1"
    shift
    git clone https://github.com/t-hg/"$repo" || return
    for file in "$@"; do
		ln -s "$(pwd)/$repo/$file" "$BIN/$BIN_PREFIX-$file"
    done
}

function install_go_project() {
    repo="$1"
    file="$1"
    git clone https://github.com/t-hg/"$repo" || return
    pushd "$repo"
    go build
	ln -s "$(pwd)/$file" "$BIN/$BIN_PREFIX-$file"
    popd
}

install_shell_script compress-pdf compress-pdf
install_shell_script ip-sort ipv4-sort
install_shell_script rmn rmn
install_shell_script video-to-gif video-to-gif

install_go_project bin2hex
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
install_go_project jwk-rsa-to-der
install_go_project jwt-decode
install_go_project jwt-encode
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
echo
echo "---"
echo "Add line to .bashrc/.zshrc"
echo "export PATH=$BIN:\$PATH"
echo "---"
