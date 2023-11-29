#!/usr/bin/env bash

# Create a new directory and enter it
function mkd() {
	mkdir -p "$@" && cd "$_";
}

# Create a .tar.gz archive, using `zopfli`, `pigz` or `gzip` for compression
function targz() {
	local tmpFile="${@%/}.tar";
	tar -cvf "${tmpFile}" --exclude=".DS_Store" "${@}" || return 1;

	size=$(
		stat -f"%z" "${tmpFile}" 2> /dev/null; # macOS `stat`
		stat -c"%s" "${tmpFile}" 2> /dev/null;  # GNU `stat`
	);

	local cmd="";
	if (( size < 52428800 )) && hash zopfli 2> /dev/null; then
		# the .tar file is smaller than 50 MB and Zopfli is available; use it
		cmd="zopfli";
	else
		if hash pigz 2> /dev/null; then
			cmd="pigz";
		else
			cmd="gzip";
		fi;
	fi;

	echo "Compressing .tar ($((size / 1000)) kB) using \`${cmd}\`…";
	"${cmd}" -v "${tmpFile}" || return 1;
	[ -f "${tmpFile}" ] && rm "${tmpFile}";

	zippedSize=$(
		stat -f"%z" "${tmpFile}.gz" 2> /dev/null; # macOS `stat`
		stat -c"%s" "${tmpFile}.gz" 2> /dev/null; # GNU `stat`
	);

	echo "${tmpFile}.gz ($((zippedSize / 1000)) kB) created successfully.";
}

# Determine size of a file or total size of a directory
function fs() {
	if du -b /dev/null > /dev/null 2>&1; then
		local arg=-sbh;
	else
		local arg=-sh;
	fi
	if [[ -n "$@" ]]; then
		du $arg -- "$@";
	else
		du $arg .[^.]* ./*;
	fi;
}

# Use Git’s colored diff when available
hash git &>/dev/null;
if [ $? -eq 0 ]; then
	function diff() {
		git diff --no-index --color-words "$@";
	}
fi;

# Create a data URL from a file
function dataurl() {
	local mimeType=$(file -b --mime-type "$1");
	if [[ $mimeType == text/* ]]; then
		mimeType="${mimeType};charset=utf-8";
	fi
	echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')";
}

# Start an HTTP server from a directory, optionally specifying the port
function server() {
	local port="${1:-8000}";
	sleep 1 && open "http://localhost:${port}/" &
	# Set the default Content-Type to `text/plain` instead of `application/octet-stream`
	# And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
	python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port";
}




# Run `dig` and display the most useful info
function digmore() {
	dig +nocmd "$1" any +multiline +noall +answer;
}

# Show all the names (CNs and SANs) listed in the SSL certificate
# for a given domain
function getcertnames() {
	if [ -z "${1}" ]; then
		echo "ERROR: No domain specified.";
		return 1;
	fi;

	local domain="${1}";
	echo "Testing ${domain}…";
	echo ""; # newline

	local tmp=$(echo -e "GET / HTTP/1.0\nEOT" \
		| openssl s_client -connect "${domain}:443" -servername "${domain}" 2>&1);

	if [[ "${tmp}" = *"-----BEGIN CERTIFICATE-----"* ]]; then
		local certText=$(echo "${tmp}" \
			| openssl x509 -text -certopt "no_aux, no_header, no_issuer, no_pubkey, \
			no_serial, no_sigdump, no_signame, no_validity, no_version");
		echo "Common Name:";
		echo ""; # newline
		echo "${certText}" | grep "Subject:" | sed -e "s/^.*CN=//" | sed -e "s/\/emailAddress=.*//";
		echo ""; # newline
		echo "Subject Alternative Name(s):";
		echo ""; # newline
		echo "${certText}" | grep -A 1 "Subject Alternative Name:" \
			| sed -e "2s/DNS://g" -e "s/ //g" | tr "," "\n" | tail -n +2;
		return 0;
	else
		echo "ERROR: Certificate not found.";
		return 1;
	fi;
}


# `tre` is a shorthand for `tree` with hidden files and color enabled, ignoring
# the `.git` directory, listing directories first. The output gets piped into
# `less` with options to preserve color and line numbers, unless the output is
# small enough for one screen.
function tre() {
	tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX;
}

extract () {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjvf $1    ;;
      *.tar.gz)    tar xzvf $1    ;;
      *.tar.xz)    tar xvf $1    ;;
      *.bz2)       bzip2 -d $1    ;;
      *.rar)       unrar2dir $1    ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1    ;;
      *.tgz)       tar xzf $1    ;;
      *.zip)       unzip2dir $1     ;;
      *.Z)         uncompress $1    ;;
      *.7z)        7z x $1    ;;
      *.ace)       unace x $1    ;;
      *)           echo "'$1' cannot be extracted via extract()"   ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Searches for text in all files in the current folder
ftext ()
{
	# -i case-insensitive
	# -I ignore binary files
	# -H causes filename to be printed
	# -r recursive search
	# -n causes line number to be printed
	# optional: -F treat search term as a literal, not a regular expression
	# optional: -l only print filenames and not the matching lines ex. grep -irl "$1" *
	grep -iIHrn --color=always "$1" . | less -r
}

# Copy file with a progress bar
cpp()
{
	set -e
	strace -q -ewrite cp -- "${1}" "${2}" 2>&1 \
	| awk '{
	count += $NF
	if (count % 10 == 0) {
		percent = count / total_size * 100
		printf "%3d%% [", percent
		for (i=0;i<=percent;i++)
			printf "="
			printf ">"
			for (i=percent;i<100;i++)
				printf " "
				printf "]\r"
			}
		}
	END { print "" }' total_size=$(stat -c '%s' "${1}") count=0
}

# Goes up a specified number of directories  (i.e. up 4)
up ()
{
	local d=""
	limit=$1
	for ((i=1 ; i <= limit ; i++))
		do
			d=$d/..
		done
	d=$(echo $d | sed 's/^\///')
	if [ -z "$d" ]; then
		d=..
	fi
	cd $d
}

# Show current network information
netinfo ()
{
	echo "--------------- Network Information ---------------"
	/sbin/ifconfig | awk /'inet addr/ {print $2}'
	echo ""
	/sbin/ifconfig | awk /'Bcast/ {print $3}'
	echo ""
	/sbin/ifconfig | awk /'inet addr/ {print $4}'

	/sbin/ifconfig | awk /'HWaddr/ {print $4,$5}'
	echo "---------------------------------------------------"
}

# IP address lookup
alias whatismyip="whatsmyip"
function whatsmyip ()
{
	# Dumps a list of all IP addresses for every device
	# /sbin/ifconfig |grep -B1 "inet addr" |awk '{ if ( $1 == "inet" ) { print $2 } else if ( $2 == "Link" ) { printf "%s:" ,$1 } }' |awk -F: '{ print $1 ": " $3 }';

	# Internal IP Lookup
	echo -n "Internal IP: " ; /sbin/ifconfig eth0 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'

	# External IP Lookup
	echo -n "External IP: " ; wget http://smart-ip.net/myip -O - -q
}

# For some reason, rot13 pops up everywhere
rot13 () {
	if [ $# -eq 0 ]; then
		tr '[a-m][n-z][A-M][N-Z]' '[n-z][a-m][N-Z][A-M]'
	else
		echo $* | tr '[a-m][n-z][A-M][N-Z]' '[n-z][a-m][N-Z][A-M]'
	fi
}

function jobs_count {
    cnt=$(jobs -l | wc -l)
    if [ $cnt -eq 0 ] ;then
        echo -ne ${cnt}
    fi

    if [ $cnt -gt 0 ]; then
        echo -ne "\e[93m${cnt}\e[m"
    fi
}

# grep history
hgrep () {
    history | egrep --color=auto "$@" | egrep --color=auto -v "hgrep $@"
}

function taskadd() { echo "- $1" >> "$TASKFILE"; } #Example: taskadd "Go grocery shopping"
function taskin() { sed -i "$1i- $2" "$TASKFILE"; } #Insert a task between items
function taskrm() { sed -i "$1d" "$TASKFILE"; } #Example: taskrm 2 --> Removes second item in list
function taskcl() { rm "$TASKFILE"; touch "$TASKFILE"; } #Delete and create a new taskfile

#Converting audio and video files
function 2ogg() { eyeD3 --remove-all-images "$1"; fname="${1%.*}"; sox "$1" "$fname.ogg"; }
function 2wav() { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" "$fname.wav"; }
function 2aif() { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" "$fname.aif"; }
function 2mp3() { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" "$fname.mp3"; }
function 2mov() { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" "$fname.mov"; }
function 2mp4() { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" "$fname.mp4"; }
function 2avi() { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" "$fname.avi"; }
function 2webm() { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" -c:v libvpx "$fname.webm"; }
function 2h265() { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" -c:v libx265 "$fname'_converted'.mp4"; }
function 2flv() { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" "$fname.flv"; }
function 2mpg() { fname="${1%.*}"; ffmpeg -threads 0 -i "$1" "$fname.mpg"; }

#Converting documents and images
function 2txt() { soffice --headless txt "$1"; }
function 2pdf() {
    if [ ${1: -4} == ".html" ]
    then
        fname="${1%.*}"
        soffice --headless --convert-to odt "$1"
        soffice --headless pdf "$fname.html"
    else
        soffice --headless pdf "$1"
    fi
}
function 2doc() { soffice --headless doc "$1"; }
function 2odt() { soffice --headless odt "$1"; }
function 2jpeg() { fname="${1%.*}"; convert "$1" "$fname.jpg"; }
function 2jpg() { fname="${1%.*}"; convert "$1" "$fname.jpg"; }
function 2png() { fname="${1%.*}"; convert "$1" "$fname.png"; }
function 2bmp() { fname="${1%.*}"; convert "$1" "$fname.bmp"; }
function 2tiff() { fname="${1%.*}"; convert "$1" "$fname.tiff"; }
function 2gif() {
    fname="${1%.*}"
    if [ ! -d "/tmp/gif" ]; then mkdir "/tmp/gif"; fi
    if [ ${1: -4} == ".mp4" ] || [ ${1: -4} == ".mov" ] || [ ${1: -4} == ".avi" ] || [ ${1: -4} == ".flv" ] || [ ${1: -4} == ".mpg" ] || [ ${1: -4} == ".webm" ]
    then
        ffmpeg -i "$1" -r 10 -vf 'scale=trunc(oh*a/2)*2:480' /tmp/gif/out%04d.png
        convert -delay 1x10 "/tmp/gif/*.png" -fuzz 2% +dither -coalesce -layers OptimizeTransparency +map "$fname.gif"
    else
        convert "$1" "$fname.gif"
    fi
    rm -r "/tmp/gif"
}

diskcopy(){ dd if=$1 of=$2; }

#List by file size in current directory
sbs() { du -b --max-depth 1 | sort -nr | perl -pe 's{([0-9]+)}{sprintf "%.1f%s", $1>=2**30? ($1/2**30, "G"):    $1>=2**20? ($1/2**20, "M"): $1>=2**10? ($1/2**10, "K"): ($1, "")}e';}

