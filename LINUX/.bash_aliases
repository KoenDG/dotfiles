#!/usr/bin/env bash

### EXTRA TASKLIST

#Task List
TASKFILE="$HOME/.bashtask" #Hidden for neatness
NC='\033[0m' # No Color
LIGHTRED='\e[1;31m'
LIGHTBLUE='\e[1;34m'
if [ -f "$TASKFILE" ] && [ $(stat -c %s "$TASKFILE") != 0 ] #Check if file has content
then
    echo -e "${LIGHTRED}Task List${NC} as of ${LIGHTBLUE}$(date -r "$TASKFILE")${NC}"
    echo ""
    cat "$TASKFILE"
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' "-"
else
    echo "Yay! No tasks :)"
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' "-"
    touch "$TASKFILE"
fi
alias tasklist="bash"

### DIRCOLORS AND LS COLORS

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

### SAFETYNETS

# do not delete / or prompt if deleting more than 3 files at a time #
alias rm='rm -I --preserve-root'

# confirmation #
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'

# Parenting changing perms on / #
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

### EDITORS
alias edit="nano -u -c -W --tabsize=4"
alias nano="nano -u -c -W --tabsize=4"


### SYSTEMD
alias systemd_paths="systemctl -p UnitPath show"

alias systemd_system_unit_dir="pkg-config systemd --variable=systemdsystemunitdir"
alias systemd_system_conf_dir="pkg-config systemd --variable=systemdsystemconfdir"


### VARIOUS

# reload bash config
alias reload="source ~/.bashrc"

# some more ls aliases
alias ll='ls -lahF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'


# Enable aliases to be sudo’ed https://askubuntu.com/questions/22037/aliases-not-available-when-using-sudo
alias sudo='sudo '

# Get week number
alias week='date +%V'

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Search running processes
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"

# Show current network connections to the server
alias ipview="netstat -anpl | grep :80 | awk {'print \$5'} | cut -d\":\" -f1 | sort | uniq -c | sort -n | sed -e 's/^ *//' -e 's/ *\$//'"

# Show open ports
alias openports='netstat -nape --inet'

alias tracert="traceroute"

#Generate a random strong password
alias genpasswd="strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 30 | tr -d '\n'; echo"

#Expand current directory structure in tree form
alias treed="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'"

#Show active ports
alias port='netstat -tulpan'

#Use this for when the boss comes around to look busy.
alias busy="cat /dev/urandom | hexdump -C | grep 'ca fe'"

#Print last value returned from previous command
alias lastvalue='RET=$?; if [[ $RET -eq 0 ]]; then echo -ne "\033[0;32m$RET\033[0m "; else echo -ne "\033[0;31m$RET\033[0m "; fi; echo -n " "'

# Canonical hex dump; some systems have this symlinked
command -v hd > /dev/null || alias hd="hexdump -C"

# macOS has no `md5sum`, so use `md5` as a fallback
command -v md5sum > /dev/null || alias md5sum="md5"

# macOS has no `sha1sum`, so use `shasum` as a fallback
command -v sha1sum > /dev/null || alias sha1sum="shasum"

# Trim new lines and copy to clipboard
alias c="tr -d '\n' | pbcopy"

# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# URL-encode strings
alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"'

# Intuitive map function
# For example, to list all directories that contain a certain file:
# find . -name .gitattributes | map dirname
alias map="xargs -n1"

# One of @janmoesen’s ProTip™s
for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
	alias "${method}"="lwp-request -m '${method}'"
done

# Reload the shell (i.e. invoke as a login shell)
alias reload="exec ${SHELL} -l"

# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'

alias cpu="grep 'cpu ' /proc/stat | awk '{usage=(\$2+\$4)*100/(\$2+\$4+\$5)} END {print usage}' | awk '{printf(\"%.1f\n\", \$1)}'"
