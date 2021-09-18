PROMPT='%{$fg[blue]%}%D{%y%m%f} %D{%H:%M:%S} '$PROMPT
TIMESTAMP=`date +%Y%m%d_%H%M%S`

alias a-ac="asciinema rec $HOME/asciinema/asciinema_$TIMESTAMP.log"
alias a-k="kubectl"
alias a-d="docker"
alias a-kga="kubectl get all"
alias a-dpa="docker ps -a"
alias a-st="wget http://ipv4.download.thinkbroadband.com/1GB.zip -O /dev/null"
alias a-pingg="ping 8.8.8.8 -c 1"
alias a-sitecopy='wget -k -K -E -r -l 10 -p -N -F -nH '
alias a-ytmp3='youtube-dl --extract-audio --audio-format mp3 '

a-gg() {
    googler --np "$@"
}

d-shell() {
    docker run --rm -i -t --entrypoint=/bin/bash "$@"
}

d-shellsh() {
    docker run --rm -i -t --entrypoint=/bin/sh "$@"
}

d-shellhere() {
    dirname=${PWD##*/}
    docker run --rm -it --entrypoint=/bin/bash -v `pwd`:/${dirname} -w /${dirname} "$@"
}

d-windowshellhere() {
    dirname=${PWD##*/}
    docker -c 2019-box run --rm -it -v "C:${PWD}:C:/source" -w "C:/source" "$@"
}

# Tools
d-hetty() {
    docker run -v $HOME/.hetty:/root/.hetty -p 8080:8080 dstotijn/hetty
}

d-sn1per() {
    docker run -it xerosecurity/sn1per /bin/bash
}

d-impacket() {
    docker run --rm -it rflathers/impacket "$@"
}

d-smbservehere() {
    local sharename
    [[ -z $1 ]] && sharename="SHARE" || sharename=$1
    docker run --rm -it -p 445:445 -v "${PWD}:/tmp/serve" rflathers/impacket smbserver.py -smb2support $sharename /tmp/serve
}

d-nginxhere() {
    docker run --rm -it -p 80:80 -p 443:443 -v "${PWD}:/srv/data" rflathers/nginxserve
}

d-webdavhere() {
    docker run --rm -it -p 80:80 -v "${PWD}:/srv/data/share" rflathers/webdav
}

d-metasploit() {
    docker run --rm -it -v "${HOME}/.msf4:/home/msf/.msf4" metasploitframework/metasploit-framework ./msfconsole "$@"
}

d-metasploitports() {
    docker run --rm -it -v "${HOME}/.msf4:/home/msf/.msf4" -p 8443-8500:8443-8500 metasploitframework/metasploit-framework ./msfconsole "$@"
}

d-msfvenomhere() {
    docker run --rm -it -v "${HOME}/.msf4:/home/msf/.msf4" -v "${PWD}:/data" metasploitframework/metasploit-framework ./msfvenom "$@"
}

d-reqdump() {
    docker run --rm -it -p 80:3000 rflathers/reqdump
}

d-postfiledumphere() {
    docker run --rm -it -p80:3000 -v "${PWD}:/data" rflathers/postfiledump
}

d-kali() {
    docker run -t -i kalilinux/kali-linux-docker /bin/bash
}

d-dirb() {
    docker run -it --rm -w /data -v $(pwd):/data booyaabes/kali-linux-full dirb
}

d-dnschef() {
    docker run -it --rm -w /data -v $(pwd):/data --net=host booyaabes/kali-linux-full dnschef
}

d-hping3() {
    docker run -it --rm -w /data -v $(pwd):/data booyaabes/kali-linux-full hping3
}

d-responder() {
    docker run -it --rm --net=host booyaabes/kali-linux-full responder
}

d-nikto() {
    docker run -it --rm --net=host -w /data -v $(pwd):/data booyaabes/kali-linux-full nikto
}

d-nmap() {
    docker run --rm --net=host --privileged booyaabes/kali-linux-full nmap
}

d-searchsploit() {
    docker run --rm booyaabes/kali-linux-full searchsploit
}

d-securityshepherd(){
    docker run -i -p 80:80 -p 443:443 ismisepaul/securityshepherd /bin/bash
}

# Educational docker images
d-dvwa() {
    docker run --rm -p 80:80 citizenstig/dvwa
}

d-vulnerablewordpress() {
    docker run --rm --name vulnerablewordpress -p 80:80 -p 3306:3306 l505/vulnerablewordpress
}

d-vaas-cve-2014-6271() {
    docker run --rm -p 8080:80 hmlio/vaas-cve-2014-6271
}

d-vaas-cve-2014-0160() {
    docker run -p 8443:443 hmlio/vaas-cve-2014-0160
}

d-webgoat() {
    docker run --rm -p 8080:8080 --name webgoat -it danmx/docker-owasp-webgoat
}

d-nowasp() {
    docker run -p 80:80 citizenstig/nowasp
}

d-juice-shop() {
    docker run --rm -p 3000:3000 bkimminich/juice-shop
}

d-openvas() {
    docker run -p 443:443 --name openvas mikesplain/openvas:9
}

d-beef() {
    docker run --rm -it --net=host -v $HOME/.msf4:/root/.msf4:Z -v /tmp/msf:/tmp/data:Z --name=beef phocean/beef
}

# extract
function a-extract {
 if [ -z "$1" ]; then
    # display usage if no parameters given
    echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
 else
    if [ -f $1 ] ; then
        # NAME=${1%.*}
        # mkdir $NAME && cd $NAME
        case $1 in
          *.tar.bz2)   tar xvjf ./$1    ;;
          *.tar.gz)    tar xvzf ./$1    ;;
          *.tar.xz)    tar xvJf ./$1    ;;
          *.lzma)      unlzma ./$1      ;;
          *.bz2)       bunzip2 ./$1     ;;
          *.rar)       unrar x -ad ./$1 ;;
          *.gz)        gunzip ./$1      ;;
          *.tar)       tar xvf ./$1     ;;
          *.tbz2)      tar xvjf ./$1    ;;
          *.tgz)       tar xvzf ./$1    ;;
          *.zip)       unzip ./$1       ;;
          *.Z)         uncompress ./$1  ;;
          *.7z)        7z x ./$1        ;;
          *.xz)        unxz ./$1        ;;
          *.exe)       cabextract ./$1  ;;
          *)           echo "extract: '$1' - unknown archive method" ;;
        esac
    else
        echo "$1 - file does not exist"
    fi
fi
}
