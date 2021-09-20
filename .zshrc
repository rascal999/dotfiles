PROMPT='%{$fg[blue]%}%D{%y%m%f} %D{%H:%M:%S} '$PROMPT

alias a-r="export TIMESTAMP=`date +%Y%m%d_%H%M%S` && asciinema rec $HOME/asciinema/asciinema_$TIMESTAMP.log"
alias a-k="kubectl"
alias a-d="docker"
alias a-kga="kubectl get all"
alias a-dpa="docker ps -a"
alias a-st="wget http://ipv4.download.thinkbroadband.com/1GB.zip -O /dev/null"
alias a-pingg="ping 8.8.8.8 -c 1"
alias a-sitecopy='wget -k -K -E -r -l 10 -p -N -F -nH '
alias a-ytmp3='youtube-dl --extract-audio --audio-format mp3 '
alias ff='firefox '

###
### Misc
###
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

###
### Lazy boy
###
webscan() {
    d-sniper -c "sniper -t \"$@\""
    d-nikto "$@"
    d-feroxbuster-slow "$@"
    # arjun
    # spiderfoot
    # crawlab
    CONTENT="$@ completed"
    twmnc -t webscan -c $CONTENT
}

###
### Tools
###
d-astra() {
    docker run --rm -d --name astra-mongo mongo
    cd $HOME/git/pentest-tools/Astra
    docker build -t astra .
    docker run --rm -d -it --link astra-mongo:mongo -p 8094:8094 astra
    firefox http://localhost:8094
}

d-openvas() {
    docker run -p 443:443 --name openvas mikesplain/openvas
}

d-beef() {
    mkdir -p $HOME/.msf4
    docker run --rm -it --net=host -v $HOME/.msf4:/root/.msf4:Z -v /tmp/msf:/tmp/data:Z --name=beef phocean/beef
}

d-eyewitness() {
    TIMESTAMP=`date +%Y%m%d_%H%M%S`
    docker run --rm -it -v $PWD:/tmp/EyeWitness eyewitness -f /tmp/EyeWitness/$@ -d /tmp/EyeWitness/eyewitness_$TIMESTAMP
    CONTENT="$@ completed"
    twmnc -t EyeWitness -c $CONTENT
    firefox file:///$PWD/eyewitness_$TIMESTAMP/report.html
}

d-cyberchef() {
    docker run --rm -d -p 8000:8000 mpepping/cyberchef
    firefox http://localhost:8000
}

d-feroxbuster() {
    TIMESTAMP=`date +%Y%m%d_%H%M%S`
    WORK_DIR=$HOME/tool-output/feroxbuster/$TIMESTAMP
    LOOT_DIR="/mnt"
    LOOT_FILE="/mnt/feroxbuster.log"
    mkdir -p $WORK_DIR
    docker run --rm -v $WORK_DIR:$LOOT_DIR --net=host --init -it epi052/feroxbuster --auto-tune -k -r -u "$@" -x js,html -o $LOOT_FILE
    CONTENT="$@ completed"
    twmnc -t feroxbuster -c $CONTENT
}

d-feroxbuster-slow() {
    d-feroxbuster "$@" -L 2 -t 2
    CONTENT="$@ completed"
    twmnc -t feroxbuster-slow -c $CONTENT
}

d-hetty() {
    docker run --rm -v $HOME/.hetty:/root/.hetty -p 8080:8080 dstotijn/hetty
}

d-sniper() {
    TIMESTAMP=`date +%Y%m%d_%H%M%S`
    WORK_DIR=$HOME/tool-output/sn1per/$TIMESTAMP
    LOOT_DIR="/usr/share/sniper/loot/workspace"
    mkdir -p $WORK_DIR
    docker run --rm -v $WORK_DIR:$LOOT_DIR -it xerosecurity/sn1per /bin/bash "$@"
    CONTENT="$@ completed"
    twmnc -t sniper -c $CONTENT
}

d-impacket() {
    mkdir -p $HOME/tool-output/impacket
    TIMESTAMP=`date +%Y%m%d_%H%M%S`
    SCRIPT_LOG=$HOME/tool-output/impacket/$TIMESTAMP.log
    script $SCRIPT_LOG -c "docker run --rm -it rflathers/impacket \"$@\""
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
    mkdir -p $HOME/.msf4
    docker run --rm -it -v "${HOME}/.msf4:/home/msf/.msf4" metasploitframework/metasploit-framework ./msfconsole "$@"
}

d-metasploitports() {
    mkdir -p $HOME/.msf4
    docker run --rm -it -v "${HOME}/.msf4:/home/msf/.msf4" -p 8443-8500:8443-8500 metasploitframework/metasploit-framework ./msfconsole "$@"
}

d-msfvenomhere() {
    mkdir -p $HOME/.msf4
    docker run --rm -it -v "${HOME}/.msf4:/home/msf/.msf4" -v "${PWD}:/data" metasploitframework/metasploit-framework ./msfvenom "$@"
}

d-reqdump() {
    docker run --rm -it -p 80:3000 rflathers/reqdump
}

d-postfiledumphere() {
    docker run --rm -it -p80:3000 -v "${PWD}:/data" rflathers/postfiledump
}

d-kali() {
    docker run -it --rm booyaabes/kali-linux-full /bin/bash
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
    TIMESTAMP=`date +%Y%m%d_%H%M%S`
    WORK_DIR=$HOME/tool-output/nikto/$TIMESTAMP
    LOOT_DIR="/data"
    mkdir -p $WORK_DIR
    docker run -it --rm --net=host -w $LOOT_DIR -v $WORK_DIR:$LOOT_DIR booyaabes/kali-linux-full nikto -h "$@" -o $LOOT_DIR/nikto.txt
    CONTENT="$@ completed"
    twmnc -t nikto -c $CONTENT
}

d-nmap() {
    TIMESTAMP=`date +%Y%m%d_%H%M%S`
    WORK_DIR=$HOME/tool-output/nmap/$TIMESTAMP
    LOOT_DIR="/mnt"
    mkdir -p $WORK_DIR
    docker run --rm -v $WORK_DIR:/mnt --net=host --privileged booyaabes/kali-linux-full nmap -oA /mnt/$TIMESTAMP "$@"
    CONTENT="$@ completed"
    twmnc -t nmap -c $CONTENT
}

d-searchsploit() {
    docker run --rm booyaabes/kali-linux-full searchsploit
}

###
### Educational docker images
###
d-lab-start() {
    d-altoro
    d-dvwa
    d-vulnerablewordpress
    d-vaas-cve-2014-6271
    d-vaas-cve-2014-0160
    d-webgoat
    d-nowasp
    d-juice-shop
    d-hackazon
    d-tiredful
    d-xvwa
    d-security-ninjas
}

d-lab-kill() {
   docker stop vulnerablewordpress \
               nowasp \
               juice-shop \
               webgoat \
               vaas-cve-2014-6271 \
               vaas-cve-2014-0160 \
               altoro \
               dvwa \
               hackazon \
               tiredful
               xvwa
               security-ninjas
}

d-altoro() {
    echo "screen -r altoro"
    screen -S altoro -adm docker run --rm --name altoro -p 127.10.0.1:80:8080 eystsen/altoro
}

d-securityshepherd(){
    docker run -i -p 80:80 -p 443:443 ismisepaul/securityshepherd /bin/bash
}

d-dvwa() {
    echo "screen -r dvwa"
    screen -S dvwa -adm docker run --rm --name dvwa -p 127.10.0.2:80:80 citizenstig/dvwa
}

d-vulnerablewordpress() {
    echo "screen -r vulnerablewordpress"
    screen -S vulnerablewordpress -adm docker run --rm --name vulnerablewordpress -p 127.10.0.3:80:80 -p 3306:3306 l505/vulnerablewordpress
}

d-vaas-cve-2014-6271() {
    echo "screen -r vaas-cve-2014-6271"
    screen -S vaas-cve-2014-6271 -adm docker run --rm --name vaas-cve-2014-6271 -p 127.10.0.4:8080:80 hmlio/vaas-cve-2014-6271
}

d-vaas-cve-2014-0160() {
    echo "screen -r vaas-cve-2014-0160"
    screen -S vaas-cve-2014-0160 -adm docker run --rm --name vaas-cve-2014-0160 -p 127.10.0.5:8443:443 hmlio/vaas-cve-2014-0160
}

d-webgoat() {
    echo "screen -r webgoat"
    screen -S webgoat -adm docker run --rm --name webgoat -p 127.10.0.6:8080:8080 --name webgoat -it danmx/docker-owasp-webgoat
}

d-nowasp() {
    echo "screen -r nowasp"
    screen -S nowasp -adm docker run --rm --name nowasp -p 127.10.0.7:80:80 citizenstig/nowasp
}

d-juice-shop() {
    echo "screen -r juice-shop"
    screen -S juice-shop -adm docker run --rm --name juice-shop -p 127.10.0.8:3000:3000 bkimminich/juice-shop
}

d-hackazon() {
    echo "screen -r hackazon"
    screen -S hackazon -adm docker run --rm --name hackazon -p 127.10.0.9:80:80 mutzel/all-in-one-hackazon:postinstall supervisord -n
}

d-tiredful() {
    echo "screen -r tiredful"
    screen -S tiredful -adm docker run --rm --name tiredful -p 127.10.0.10:80:8000 tuxotron/tiredful-api
}

d-xvwa() {
    echo "screen -r xvwa"
    screen -S xvwa -adm docker run --rm --name xvwa -p 127.10.0.11:80:80 tuxotron/xvwa
}

d-security-ninjas() {
    echo "screen -r security-ninjas"
    screen -S security-ninjas -adm docker run --rm --name security-ninjas -p 127.10.0.12:80:80 opendns/security-ninjas
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
