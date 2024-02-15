#!/bin/bash
# Removes old revisions of snaps
# CLOSE ALL SNAPS BEFORE RUNNING THIS

## SOURCE: https://superuser.com/a/1330590

set -eu

LANG=C snap list --all | awk '/disabled/{print $1, $3}' |
    while read -r snapname revision; do
        snap remove "$snapname" --revision="$revision"
    done
