## Not using .bash_profile, for potential future usage on non-bash systems. See bash manpage.

### SETTINGS FOR NON-INTERACTIVE LOGIN(It's a login because how else did you get to the .profile file specific to my account?)

## If we ever want to add a setting for commands sent over SSH, add them here, below this comment and above the $- case check.

# If not running interactively, don't do anything
# $- is a special bash parameter that returns the option flags used in the current bash shell.
# Further, if it includes i, it means that the shell is interactive
# Check it yourself by running "echo $-"
case $- in
    *i*) ;;
      *) return;;
esac

### DEFAULT START SETTINGS. ORIGIN LOST TO TIME
# Disable the bell
bind "set bell-style visible";

# Ignore case on auto-completion
# Note: bind used instead of sticking these in .inputrc
bind "set completion-ignore-case on";

# Show auto-completion list automatically, without double tab
bind "set show-all-if-ambiguous on";

### SHELL OPTIONS
# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS
shopt -s checkwinsize;

# If set, and Readline is being used, the results of history substitution are not immediately passed to the shell parser.
# Instead, the resulting line is loaded into the Readline editing buffer, allowing further modification.
# This refers to history substitution, like doing "!100" to run command number 100 in the history file. With this enabled, the command will not be executed, it will be put in the commandline first so you can edit it.
shopt -s histverify;

# Disable history substitution. That being things like "sudo !!" where "!!" gets expand to the previous command. Will not work anymore. Needed for ansible --limit
set +H

### BASH COMPLETION SUPPORT

# Add tab completion for many Bash commands
# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

### VARIOUS SETTINGS

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac


### PROMPT COLORS

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

### SET CUSTOM PATH FOR WSL

if [ -d "/usr/lib/wsl" ]; then
    export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/lib/wsl/lib:/snap/bin"
fi

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{bash_path,bash_exports,bash_aliases,bash_functions,bash_extra,bash_prompt}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# Source SSH settings, if applicable

SSH_ENV="$HOME/.ssh/agent-environment"

if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    #ps ${SSH_AGENT_PID} doesn't work under cywgin
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi
