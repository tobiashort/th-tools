#!/usr/bin/env bash

DIR="/opt/thg-tools"
BIN="$DIR/bin"
rm -rf "$DIR"
mkdir -p "$BIN"
pushd "$DIR" > /dev/null

function install_shell_script() {
  repo="$1"
  shift
  git clone https://github.com/t-hg/"$repo" || return
  for file in "$@"; do
    cp "$repo/$file" "$BIN"
  done
}

function install_go_project() {
  repo="$1"
  file="$1"
  git clone https://github.com/t-hg/"$repo" || return
  pushd "$repo"
  go build
  mv "$file" "$BIN"
  popd
}

install_shell_script compress-pdf compress-pdf
install_shell_script ip-sort ipv4-sort
install_shell_script mtmp mcat mdel msto
install_shell_script rmn rmn
install_shell_script video-to-gif video-to-gif

install_go_project cidr-to-mask
install_go_project ciphersuite-checker
install_go_project cutnstitch
install_go_project git-cleaner
install_go_project html-decode
install_go_project html-encode
install_go_project jwk-rsa-to-der
install_go_project jwt-decode
install_go_project jwt-encode
install_go_project mask-to-cidr
install_go_project pipe-sum
install_go_project ports-to-port-ranges
install_go_project rfc33392unixtime
install_go_project subnet-to-list
install_go_project unixtime2rfc3339
install_go_project url-encode-all
install_go_project url-path-decode
install_go_project url-path-encode
install_go_project url-query-decode
install_go_project url-query-encode

popd > /dev/null
echo
echo "---"
echo "Add line to .bashrc"
echo "export PATH=\$PATH:$BIN"
echo "---"
