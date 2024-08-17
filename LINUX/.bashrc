## https://manpages.org/bash
# When an interactive shell that is not a login shell is started, bash reads and executes commands from /etc/bash.bashrc and ~/.bashrc, if these files exist.
# This may be inhibited by using the --norc option.
# The --rcfile file option will force bash to read and execute commands from file instead of /etc/bash.bashrc and ~/.bashrc.

### EXAMPLES

## Interactive and login(goes straight to .profile):
# - SSH into a system and log in as a specific user
# - Log in directly on one of the standard TTY console, on the baremetal machine.

## Interactive and non-login:
# - Using "sudo su <USER>"
# - Running a "screen"

## Non-interactive and login(goes straight to .profile):
# - Sending a command over SSH

## Non-interactive and non-login:
# - Running any script


### WHEN IS THIS FILE RUN
# - Interactive shell that is not a login.
# - In which case /etc/bash.bashrc will first be read, if it exists.


## If running an interactive shell, source ~/.profile
[ -n "$PS1" ] && source ~/.profile

## If not running an interactive shell, do nothing special
