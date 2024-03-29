#!/bin/bash
# Test script for install_spcache.sh

. ./tests/bin/helpers/utils.sh

readonly INSTALL="./bin/install_spcache.sh"

print "${MAGENTA}" 'Test bash installation\n'
"${INSTALL}" -s bash -y
test_spcache_in_path bash

path_counts="$(get_path_counts bash)"
get_file_contents bash

print "${MAGENTA}" "Test that bash re-installation doesn't change paths (nor prompt)\n"
"${INSTALL}" -s "$(which bash)"
test_spcache_in_path bash
check_same_path_counts bash "${path_counts}"
check_same_file_contents bash

print "${MAGENTA}" 'Test that invalid files return the correct exit code\n'
ret=0
bash --login -c 'spcache set --file .gitattributes' || ret=$?
(( ret == 3 ))

print "${MAGENTA}" 'Test that spcache detects prefs file in arbitrary locations\n'
prefs="${HOME}/a/b/spotify/prefs"
mkdir -p "$(dirname "${prefs}")"
touch "${prefs}"
bash --login -c 'spcache set --size 200 --yes'

print "${MAGENTA}" 'Test that spcache reads from same prefs file\n'
bash --login -c 'spcache get --yes' | grep --silent 200

print "${MAGENTA}" 'Test that installation fails on invalid versions\n'
"${INSTALL}" -s bash -v foobar && exit 1

print "${MAGENTA}" 'Test installation of a specific version\n'
"${INSTALL}" -s bash -v "1.0.0"
ls ~/.local/share/spcache
current_version="$(bash --login -c 'spcache --version')"
echo "${current_version}"
echo "${current_version}" | grep --silent -F "1.0.0" # fixed-strings

print "${MAGENTA}" 'Test that the help flag works\n'
"${INSTALL}" -h

print "${MAGENTA}" 'Test that the debug flag works\n'
"${INSTALL}" -d

print "${MAGENTA}" 'Test fish installation\n'
"${INSTALL}" -y -s fish
test_spcache_in_path fish

# shellcheck disable=SC2016
fish_user_paths="$(fish -c 'echo $fish_user_paths')"
print "${MAGENTA}" "Test fish re-installation doesn't change paths.\n"
"${INSTALL}" -s "$(which fish)"
test_spcache_in_path fish

# shellcheck disable=SC2016
[[ "${fish_user_paths}" == "$(fish -c 'echo $fish_user_paths')" ]]

print "${MAGENTA}" 'Test zsh installation\n'
"${INSTALL}" -y -s zsh
test_spcache_in_path zsh
path_counts="$(get_path_counts zsh)"
get_file_contents zsh

print "${MAGENTA}" "Test that zsh re-installation doesn't change paths (nor prompt)\n"
"${INSTALL}" -s "$(which zsh)"
test_spcache_in_path zsh
check_same_path_counts zsh "${path_counts}"
check_same_file_contents zsh

print "${MAGENTA}" 'Test installation without specifying shell\n'
"${INSTALL}" -y

print "${MAGENTA}" 'Test that the script fails on invalid shells\n'
"${INSTALL}" -s invalid_shell && exit 1

print "${MAGENTA}" 'Test that the script fails on invalid options\n'
"${INSTALL}" -x && exit 1

print "${MAGENTA}" 'Test that XDG_DATA_HOME is respected\n'
# create a TEMPORARY directory, which is guaranteed to be unique
dir="$(mktemp -d)"
XDG_DATA_HOME="${dir}" "${INSTALL}" -y
[[ -f "${dir}/spcache/spcache" ]]
rm -rf "${dir}"

print "${MAGENTA}" 'All tests passed!\n'
