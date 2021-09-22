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
a-ngrok() {
    d-filebrowserhere
    ngrok http 1080
}

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
    docker -c 2019-box run --rm -it -v "C:${PWD}:C:/source" -w "C:/source" "$@"
}

d-filebrowserhere() {
    screen -S filebrowser -adm docker run --rm --name filebrowser -v ${PWD}:/srv -p 1080:80 filebrowser/filebrowser
    firefox http://127.0.0.1:1080/ &
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
d-stego-toolkit() {
    docker run --rm -it --name stego-toolkit -v ${PWD}:/data dominicbreuker/stego-toolkit /bin/bash "$@"
}

d-bettercap() {
    docker run --rm -it --name bettercap --net=host bettercap/bettercap
}

d-ciphey() {
    docker run -it --rm --name ciphey -v ${PWD}:/home/nonroot/workdir remnux/ciphey "$@"
}

d-astra() {
    docker run --rm -d --name astra-mongo mongo
    cd $HOME/git/pentest-tools/Astra
    docker build -t astra .
    docker run --rm -d -it --link astra-mongo:mongo -p 8094:8094 astra
    firefox http://localhost:8094 &
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
    firefox file:///$PWD/eyewitness_$TIMESTAMP/report.html &
}

d-cyberchef() {
    docker run --rm -d -p 8000:8000 mpepping/cyberchef
    firefox http://localhost:8000 &
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
    screen -S nginxhere -adm docker run --rm -it -p 1080:80 -p 443:443 -v "${PWD}:/srv/data" rflathers/nginxserve
    firefox http://127.0.0.1 &
}

d-webdavhere() {
    docker run --rm -it -p 1080:80 -v "${PWD}:/srv/data/share" rflathers/webdav
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
    docker run --rm -it -p 1080:3000 rflathers/reqdump
}

d-postfiledumphere() {
    docker run --rm -it -p 1080:3000 -v "${PWD}:/data" rflathers/postfiledump
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
               tiredful \
               xvwa \
               security-ninjas
}

d-altoro() {
    echo "screen -r altoro"
    screen -S altoro -adm docker run --rm --name altoro -p 127.10.0.1:80:8080 eystsen/altoro
}

d-securityshepherd(){
    docker run -i -p 1080:80 -p 8443:443 ismisepaul/securityshepherd /bin/bash
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

###
###
### awesome-stacks
###
###
ds-net-traefik() {
    docker network create --driver=overlay traefik-net
    docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/traefik.yml traefik
}

# appwrite
ds-appwrite() {
    ds-net-traefik
    DOMAIN=appwrite.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/appwrite.yml appwrite
    firefox https://appwrite.ds &
    watch docker stack ps appwrite
}

ds-appwrite-kill() {
    docker stack rm appwrite
    sleep 6
    docker volume prune
}

# bibliogram
ds-bibliogram() {
    ds-net-traefik
    DOMAIN=bibliogram.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/bibliogram.yml bibliogram
    firefox https://bibliogram.ds &
    watch docker stack ps bibliogram
}

ds-bibliogram-kill() {
    docker stack rm bibliogram
    sleep 6
    docker volume prune
}

# bookstack
ds-bookstack() {
    ds-net-traefik
    DOMAIN=bookstack.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/bookstack.yml bookstack
    firefox https://bookstack.ds &
    watch docker stack ps bookstack
}

ds-bookstack-kill() {
    docker stack rm bookstack
    sleep 6
    docker volume prune
}

# botpress
ds-botpress() {
    ds-net-traefik
    DOMAIN=botpress.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/botpress.yml botpress
    firefox https://botpress.ds &
    watch docker stack ps botpress
}

ds-botpress-kill() {
    docker stack rm botpress
    sleep 6
    docker volume prune
}

# calibre
ds-calibre() {
    ds-net-traefik
    DOMAIN=calibre.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/calibre.yml calibre
    firefox https://calibre.ds &
    watch docker stack ps calibre
}

ds-calibre-kill() {
    docker stack rm calibre
    sleep 6
    docker volume prune
}

# chatwoot
ds-chatwoot() {
    ds-net-traefik
    DOMAIN=chatwoot.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/chatwoot.yml chatwoot
    firefox https://chatwoot.ds &
    watch docker stack ps chatwoot
}

ds-chatwoot-kill() {
    docker stack rm chatwoot
    sleep 6
    docker volume prune
}

# commento
ds-commento() {
    ds-net-traefik
    DOMAIN=commento.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/commento.yml commento
    firefox https://commento.ds &
    watch docker stack ps commento
}

ds-commento-kill() {
    docker stack rm commento
    sleep 6
    docker volume prune
}

# crater
ds-crater() {
    ds-net-traefik
    DOMAIN=crater.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/crater.yml crater
    firefox https://crater.ds &
    watch docker stack ps crater
}

ds-crater-kill() {
    docker stack rm crater
    sleep 6
    docker volume prune
}

# cryptpad
ds-cryptpad() {
    ds-net-traefik
    DOMAIN=cryptpad.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/cryptpad.yml cryptpad
    firefox https://cryptpad.ds &
    watch docker stack ps cryptpad
}

ds-cryptpad-kill() {
    docker stack rm cryptpad
    sleep 6
    docker volume prune
}

# directus
ds-directus() {
    ds-net-traefik
    DOMAIN=directus.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/directus.yml directus
    firefox https://directus.ds &
    watch docker stack ps directus
}

ds-directus-kill() {
    docker stack rm directus
    sleep 6
    docker volume prune
}

# discourse
ds-discourse() {
    ds-net-traefik
    DOMAIN=discourse.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/discourse.yml discourse
    firefox https://discourse.ds &
    watch docker stack ps discourse
}

ds-discourse-kill() {
    docker stack rm discourse
    sleep 6
    docker volume prune
}

# dolibarr
ds-dolibarr() {
    ds-net-traefik
    DOMAIN=dolibarr.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/dolibarr.yml dolibarr
    firefox https://dolibarr.ds &
    watch docker stack ps dolibarr
}

ds-dolibarr-kill() {
    docker stack rm dolibarr
    sleep 6
    docker volume prune
}

# drawio
ds-drawio() {
    ds-net-traefik
    DOMAIN=drawio.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/drawio.yml drawio
    firefox https://drawio.ds &
    watch docker stack ps drawio
}

ds-drawio-kill() {
    docker stack rm drawio
    sleep 6
    docker volume prune
}

# element
ds-element() {
    ds-net-traefik
    DOMAIN=element.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/element.yml element
    firefox https://element.ds &
    watch docker stack ps element
}

ds-element-kill() {
    docker stack rm element
    sleep 6
    docker volume prune
}

# ethercalc
ds-ethercalc() {
    ds-net-traefik
    DOMAIN=ethercalc.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/ethercalc.yml ethercalc
    firefox https://ethercalc.ds &
    watch docker stack ps ethercalc
}

ds-ethercalc-kill() {
    docker stack rm ethercalc
    sleep 6
    docker volume prune
}

# etherpad
ds-etherpad() {
    ds-net-traefik
    DOMAIN=etherpad.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/etherpad.yml etherpad
    firefox https://etherpad.ds &
    watch docker stack ps etherpad
}

ds-etherpad-kill() {
    docker stack rm etherpad
    sleep 6
    docker volume prune
}

# ethibox
ds-ethibox() {
    ds-net-traefik
    DOMAIN=ethibox.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/ethibox.yml ethibox
    firefox https://ethibox.ds &
    watch docker stack ps ethibox
}

ds-ethibox-kill() {
    docker stack rm ethibox
    sleep 6
    docker volume prune
}

# fathom
ds-fathom() {
    ds-net-traefik
    DOMAIN=fathom.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/fathom.yml fathom
    firefox https://fathom.ds &
    watch docker stack ps fathom
}

ds-fathom-kill() {
    docker stack rm fathom
    sleep 6
    docker volume prune
}

# firefly
ds-firefly() {
    ds-net-traefik
    DOMAIN=firefly.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/firefly.yml firefly
    firefox https://firefly.ds &
    watch docker stack ps firefly
}

ds-firefly-kill() {
    docker stack rm firefly
    sleep 6
    docker volume prune
}

# flarum
ds-flarum() {
    ds-net-traefik
    DOMAIN=flarum.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/flarum.yml flarum
    firefox https://flarum.ds &
    watch docker stack ps flarum
}

ds-flarum-kill() {
    docker stack rm flarum
    sleep 6
    docker volume prune
}

# framadate
ds-framadate() {
    ds-net-traefik
    DOMAIN=framadate.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/framadate.yml framadate
    firefox https://framadate.ds &
    watch docker stack ps framadate
}

ds-framadate-kill() {
    docker stack rm framadate
    sleep 6
    docker volume prune
}

# freshrss
ds-freshrss() {
    ds-net-traefik
    DOMAIN=freshrss.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/freshrss.yml freshrss
    firefox https://freshrss.ds &
    watch docker stack ps freshrss
}

ds-freshrss-kill() {
    docker stack rm freshrss
    sleep 6
    docker volume prune
}

# ghost
ds-ghost() {
    ds-net-traefik
    DOMAIN=ghost.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/ghost.yml ghost
    firefox https://ghost.ds &
    watch docker stack ps ghost
}

ds-ghost-kill() {
    docker stack rm ghost
    sleep 6
    docker volume prune
}

# gitlab
ds-gitlab() {
    ds-net-traefik
    DOMAIN=gitlab.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/gitlab.yml gitlab
    firefox https://gitlab.ds &
    watch docker stack ps gitlab
}

ds-gitlab-kill() {
    docker stack rm gitlab
    sleep 6
    docker volume prune
}

# gogs
ds-gogs() {
    ds-net-traefik
    DOMAIN=gogs.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/gogs.yml gogs
    firefox https://gogs.ds &
    watch docker stack ps gogs
}

ds-gogs-kill() {
    docker stack rm gogs
    sleep 6
    docker volume prune
}

# grafana
ds-grafana() {
    ds-net-traefik
    DOMAIN=grafana.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/grafana.yml grafana
    firefox https://grafana.ds &
    watch docker stack ps grafana
}

ds-grafana-kill() {
    docker stack rm grafana
    sleep 6
    docker volume prune
}

# grav
ds-grav() {
    ds-net-traefik
    DOMAIN=grav.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/grav.yml grav
    firefox https://grav.ds &
    watch docker stack ps grav
}

ds-grav-kill() {
    docker stack rm grav
    sleep 6
    docker volume prune
}

# habitica
ds-habitica() {
    ds-net-traefik
    DOMAIN=habitica.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/habitica.yml habitica
    firefox https://habitica.ds &
    watch docker stack ps habitica
}

ds-habitica-kill() {
    docker stack rm habitica
    sleep 6
    docker volume prune
}

# hasura
ds-hasura() {
    ds-net-traefik
    DOMAIN=hasura.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/hasura.yml hasura
    firefox https://hasura.ds &
    watch docker stack ps hasura
}

ds-hasura-kill() {
    docker stack rm hasura
    sleep 6
    docker volume prune
}

# hedgedoc
ds-hedgedoc() {
    ds-net-traefik
    DOMAIN=hedgedoc.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/hedgedoc.yml hedgedoc
    firefox https://hedgedoc.ds &
    watch docker stack ps hedgedoc
}

ds-hedgedoc-kill() {
    docker stack rm hedgedoc
    sleep 6
    docker volume prune
}

# huginn
ds-huginn() {
    ds-net-traefik
    DOMAIN=huginn.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/huginn.yml huginn
    firefox https://huginn.ds &
    watch docker stack ps huginn
}

ds-huginn-kill() {
    docker stack rm huginn
    sleep 6
    docker volume prune
}

# invoiceninja
ds-invoiceninja() {
    ds-net-traefik
    DOMAIN=invoiceninja.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/invoiceninja.yml invoiceninja
    firefox https://invoiceninja.ds &
    watch docker stack ps invoiceninja
}

ds-invoiceninja-kill() {
    docker stack rm invoiceninja
    sleep 6
    docker volume prune
}

# jenkins
ds-jenkins() {
    ds-net-traefik
    DOMAIN=jenkins.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/jenkins.yml jenkins
    firefox https://jenkins.ds &
    watch docker stack ps jenkins
}

ds-jenkins-kill() {
    docker stack rm jenkins
    sleep 6
    docker volume prune
}

# jitsi
ds-jitsi() {
    ds-net-traefik
    DOMAIN=jitsi.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/jitsi.yml jitsi
    firefox https://jitsi.ds &
    watch docker stack ps jitsi
}

ds-jitsi-kill() {
    docker stack rm jitsi
    sleep 6
    docker volume prune
}

# kanboard
ds-kanboard() {
    ds-net-traefik
    DOMAIN=kanboard.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/kanboard.yml kanboard
    firefox https://kanboard.ds &
    watch docker stack ps kanboard
}

ds-kanboard-kill() {
    docker stack rm kanboard
    sleep 6
    docker volume prune
}

# listmonk
ds-listmonk() {
    ds-net-traefik
    DOMAIN=listmonk.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/listmonk.yml listmonk
    firefox https://listmonk.ds &
    watch docker stack ps listmonk
}

ds-listmonk-kill() {
    docker stack rm listmonk
    sleep 6
    docker volume prune
}

# magento
ds-magento() {
    ds-net-traefik
    DOMAIN=magento.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/magento.yml magento
    firefox https://magento.ds &
    watch docker stack ps magento
}

ds-magento-kill() {
    docker stack rm magento
    sleep 6
    docker volume prune
}

# mailserver
ds-mailserver() {
    ds-net-traefik
    DOMAIN=mailserver.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/mailserver.yml mailserver
    firefox https://mailserver.ds &
    watch docker stack ps mailserver
}

ds-mailserver-kill() {
    docker stack rm mailserver
    sleep 6
    docker volume prune
}

# mailtrain
ds-mailtrain() {
    ds-net-traefik
    DOMAIN=mailtrain.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/mailtrain.yml mailtrain
    firefox https://mailtrain.ds &
    watch docker stack ps mailtrain
}

ds-mailtrain-kill() {
    docker stack rm mailtrain
    sleep 6
    docker volume prune
}

# mastodon
ds-mastodon() {
    ds-net-traefik
    DOMAIN=mastodon.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/mastodon.yml mastodon
    firefox https://mastodon.ds &
    watch docker stack ps mastodon
}

ds-mastodon-kill() {
    docker stack rm mastodon
    sleep 6
    docker volume prune
}

# matomo
ds-matomo() {
    ds-net-traefik
    DOMAIN=matomo.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/matomo.yml matomo
    firefox https://matomo.ds &
    watch docker stack ps matomo
}

ds-matomo-kill() {
    docker stack rm matomo
    sleep 6
    docker volume prune
}

# mattermost
ds-mattermost() {
    ds-net-traefik
    DOMAIN=mattermost.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/mattermost.yml mattermost
    firefox https://mattermost.ds &
    watch docker stack ps mattermost
}

ds-mattermost-kill() {
    docker stack rm mattermost
    sleep 6
    docker volume prune
}

# matterwiki
ds-matterwiki() {
    ds-net-traefik
    DOMAIN=matterwiki.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/matterwiki.yml matterwiki
    firefox https://matterwiki.ds &
    watch docker stack ps matterwiki
}

ds-matterwiki-kill() {
    docker stack rm matterwiki
    sleep 6
    docker volume prune
}

# mautic
ds-mautic() {
    ds-net-traefik
    DOMAIN=mautic.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/mautic.yml mautic
    firefox https://mautic.ds &
    watch docker stack ps mautic
}

ds-mautic-kill() {
    docker stack rm mautic
    sleep 6
    docker volume prune
}

# mediawiki
ds-mediawiki() {
    ds-net-traefik
    DOMAIN=mediawiki.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/mediawiki.yml mediawiki
    firefox https://mediawiki.ds &
    watch docker stack ps mediawiki
}

ds-mediawiki-kill() {
    docker stack rm mediawiki
    sleep 6
    docker volume prune
}

# metabase
ds-metabase() {
    ds-net-traefik
    DOMAIN=metabase.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/metabase.yml metabase
    firefox https://metabase.ds &
    watch docker stack ps metabase
}

ds-metabase-kill() {
    docker stack rm metabase
    sleep 6
    docker volume prune
}

# minio
ds-minio() {
    ds-net-traefik
    DOMAIN=minio.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/minio.yml minio
    firefox https://minio.ds &
    watch docker stack ps minio
}

ds-minio-kill() {
    docker stack rm minio
    sleep 6
    docker volume prune
}

# mobilizon
ds-mobilizon() {
    ds-net-traefik
    DOMAIN=mobilizon.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/mobilizon.yml mobilizon
    firefox https://mobilizon.ds &
    watch docker stack ps mobilizon
}

ds-mobilizon-kill() {
    docker stack rm mobilizon
    sleep 6
    docker volume prune
}

# monitoring
ds-monitoring() {
    ds-net-traefik
    DOMAIN=monitoring.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/monitoring.yml monitoring
    firefox https://monitoring.ds &
    watch docker stack ps monitoring
}

ds-monitoring-kill() {
    docker stack rm monitoring
    sleep 6
    docker volume prune
}

# n8n
ds-n8n() {
    ds-net-traefik
    DOMAIN=n8n.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/n8n.yml n8n
    firefox https://n8n.ds &
    watch docker stack ps n8n
}

ds-n8n-kill() {
    docker stack rm n8n
    sleep 6
    docker volume prune
}

# nextcloud
ds-nextcloud() {
    ds-net-traefik
    DOMAIN=nextcloud.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/nextcloud.yml nextcloud
    firefox https://nextcloud.ds &
    watch docker stack ps nextcloud
}

ds-nextcloud-kill() {
    docker stack rm nextcloud
    sleep 6
    docker volume prune
}

# nitter
ds-nitter() {
    ds-net-traefik
    DOMAIN=nitter.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/nitter.yml nitter
    firefox https://nitter.ds &
    watch docker stack ps nitter
}

ds-nitter-kill() {
    docker stack rm nitter
    sleep 6
    docker volume prune
}

# nocodb
ds-nocodb() {
    ds-net-traefik
    DOMAIN=nocodb.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/nocodb.yml nocodb
    firefox https://nocodb.ds &
    watch docker stack ps nocodb
}

ds-nocodb-kill() {
    docker stack rm nocodb
    sleep 6
    docker volume prune
}

# odoo
ds-odoo() {
    ds-net-traefik
    DOMAIN=odoo.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/odoo.yml odoo
    firefox https://odoo.ds &
    watch docker stack ps odoo
}

ds-odoo-kill() {
    docker stack rm odoo
    sleep 6
    docker volume prune
}

# passbolt
ds-passbolt() {
    ds-net-traefik
    DOMAIN=passbolt.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/passbolt.yml passbolt
    firefox https://passbolt.ds &
    watch docker stack ps passbolt
}

ds-passbolt-kill() {
    docker stack rm passbolt
    sleep 6
    docker volume prune
}

# peertube
ds-peertube() {
    ds-net-traefik
    DOMAIN=peertube.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/peertube.yml peertube
    firefox https://peertube.ds &
    watch docker stack ps peertube
}

ds-peertube-kill() {
    docker stack rm peertube
    sleep 6
    docker volume prune
}

# phpbb
ds-phpbb() {
    ds-net-traefik
    DOMAIN=phpbb.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/phpbb.yml phpbb
    firefox https://phpbb.ds &
    watch docker stack ps phpbb
}

ds-phpbb-kill() {
    docker stack rm phpbb
    sleep 6
    docker volume prune
}

# pinafore
ds-pinafore() {
    ds-net-traefik
    DOMAIN=pinafore.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/pinafore.yml pinafore
    firefox https://pinafore.ds &
    watch docker stack ps pinafore
}

ds-pinafore-kill() {
    docker stack rm pinafore
    sleep 6
    docker volume prune
}

# pixelfed
ds-pixelfed() {
    ds-net-traefik
    DOMAIN=pixelfed.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/pixelfed.yml pixelfed
    firefox https://pixelfed.ds &
    watch docker stack ps pixelfed
}

ds-pixelfed-kill() {
    docker stack rm pixelfed
    sleep 6
    docker volume prune
}

# plume
ds-plume() {
    ds-net-traefik
    DOMAIN=plume.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/plume.yml plume
    firefox https://plume.ds &
    watch docker stack ps plume
}

ds-plume-kill() {
    docker stack rm plume
    sleep 6
    docker volume prune
}

# polr
ds-polr() {
    ds-net-traefik
    DOMAIN=polr.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/polr.yml polr
    firefox https://polr.ds &
    watch docker stack ps polr
}

ds-polr-kill() {
    docker stack rm polr
    sleep 6
    docker volume prune
}

# portainer
ds-portainer() {
    ds-net-traefik
    DOMAIN=portainer.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/portainer.yml portainer
    firefox https://portainer.ds &
    watch docker stack ps portainer
}

ds-portainer-kill() {
    docker stack rm portainer
    sleep 6
    docker volume prune
}

# posthog
ds-posthog() {
    ds-net-traefik
    DOMAIN=posthog.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/posthog.yml posthog
    firefox https://posthog.ds &
    watch docker stack ps posthog
}

ds-posthog-kill() {
    docker stack rm posthog
    sleep 6
    docker volume prune
}

# prestashop
ds-prestashop() {
    ds-net-traefik
    DOMAIN=prestashop.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/prestashop.yml prestashop
    firefox https://prestashop.ds &
    watch docker stack ps prestashop
}

ds-prestashop-kill() {
    docker stack rm prestashop
    sleep 6
    docker volume prune
}

# pydio
ds-pydio() {
    ds-net-traefik
    DOMAIN=pydio.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/pydio.yml pydio
    firefox https://pydio.ds &
    watch docker stack ps pydio
}

ds-pydio-kill() {
    docker stack rm pydio
    sleep 6
    docker volume prune
}

# pytition
ds-pytition() {
    ds-net-traefik
    DOMAIN=pytition.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/pytition.yml pytition
    firefox https://pytition.ds &
    watch docker stack ps pytition
}

ds-pytition-kill() {
    docker stack rm pytition
    sleep 6
    docker volume prune
}

# rainloop
ds-rainloop() {
    ds-net-traefik
    DOMAIN=rainloop.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/rainloop.yml rainloop
    firefox https://rainloop.ds &
    watch docker stack ps rainloop
}

ds-rainloop-kill() {
    docker stack rm rainloop
    sleep 6
    docker volume prune
}

# redmine
ds-redmine() {
    ds-net-traefik
    DOMAIN=redmine.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/redmine.yml redmine
    firefox https://redmine.ds &
    watch docker stack ps redmine
}

ds-redmine-kill() {
    docker stack rm redmine
    sleep 6
    docker volume prune
}

# registry
ds-registry() {
    ds-net-traefik
    DOMAIN=registry.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/registry.yml registry
    firefox https://registry.ds &
    watch docker stack ps registry
}

ds-registry-kill() {
    docker stack rm registry
    sleep 6
    docker volume prune
}

# rocketchat
ds-rocketchat() {
    ds-net-traefik
    DOMAIN=rocketchat.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/rocketchat.yml rocketchat
    firefox https://rocketchat.ds &
    watch docker stack ps rocketchat
}

ds-rocketchat-kill() {
    docker stack rm rocketchat
    sleep 6
    docker volume prune
}

# rsshub
ds-rsshub() {
    ds-net-traefik
    DOMAIN=rsshub.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/rsshub.yml rsshub
    firefox https://rsshub.ds &
    watch docker stack ps rsshub
}

ds-rsshub-kill() {
    docker stack rm rsshub
    sleep 6
    docker volume prune
}

# scrumblr
ds-scrumblr() {
    ds-net-traefik
    DOMAIN=scrumblr.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/scrumblr.yml scrumblr
    firefox https://scrumblr.ds &
    watch docker stack ps scrumblr
}

ds-scrumblr-kill() {
    docker stack rm scrumblr
    sleep 6
    docker volume prune
}

# searx
ds-searx() {
    ds-net-traefik
    DOMAIN=searx.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/searx.yml searx
    firefox https://searx.ds &
    watch docker stack ps searx
}

ds-searx-kill() {
    docker stack rm searx
    sleep 6
    docker volume prune
}

# suitecrm
ds-suitecrm() {
    ds-net-traefik
    DOMAIN=suitecrm.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/suitecrm.yml suitecrm
    firefox https://suitecrm.ds &
    watch docker stack ps suitecrm
}

ds-suitecrm-kill() {
    docker stack rm suitecrm
    sleep 6
    docker volume prune
}

# taiga
ds-taiga() {
    ds-net-traefik
    DOMAIN=taiga.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/taiga.yml taiga
    firefox https://taiga.ds &
    watch docker stack ps taiga
}

ds-taiga-kill() {
    docker stack rm taiga
    sleep 6
    docker volume prune
}

# talk
ds-talk() {
    ds-net-traefik
    DOMAIN=talk.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/talk.yml talk
    firefox https://talk.ds &
    watch docker stack ps talk
}

ds-talk-kill() {
    docker stack rm talk
    sleep 6
    docker volume prune
}

# traefik
ds-traefik() {
    ds-net-traefik
    DOMAIN=traefik.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/traefik.yml traefik
    firefox https://traefik.ds &
    watch docker stack ps traefik
}

ds-traefik-kill() {
    docker stack rm traefik
    sleep 6
    docker volume prune
}

# umami
ds-umami() {
    ds-net-traefik
    DOMAIN=umami.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/umami.yml umami
    firefox https://umami.ds &
    watch docker stack ps umami
}

ds-umami-kill() {
    docker stack rm umami
    sleep 6
    docker volume prune
}

# uptime-kuma
ds-uptime-kuma() {
    ds-net-traefik
    DOMAIN=uptime-kuma.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/uptime-kuma.yml uptime-kuma
    firefox https://uptime-kuma.ds &
    watch docker stack ps uptime-kuma
}

ds-uptime-kuma-kill() {
    docker stack rm uptime-kuma
    sleep 6
    docker volume prune
}

# waiting
ds-waiting() {
    ds-net-traefik
    DOMAIN=waiting.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/waiting.yml waiting
    firefox https://waiting.ds &
    watch docker stack ps waiting
}

ds-waiting-kill() {
    docker stack rm waiting
    sleep 6
    docker volume prune
}

# wallabag
ds-wallabag() {
    ds-net-traefik
    DOMAIN=wallabag.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/wallabag.yml wallabag
    firefox https://wallabag.ds &
    watch docker stack ps wallabag
}

ds-wallabag-kill() {
    docker stack rm wallabag
    sleep 6
    docker volume prune
}

# wekan
ds-wekan() {
    ds-net-traefik
    DOMAIN=wekan.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/wekan.yml wekan
    firefox https://wekan.ds &
    watch docker stack ps wekan
}

ds-wekan-kill() {
    docker stack rm wekan
    sleep 6
    docker volume prune
}

# whoogle-search
ds-whoogle-search() {
    ds-net-traefik
    DOMAIN=whoogle-search.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/whoogle-search.yml whoogle-search
    firefox https://whoogle-search.ds &
    watch docker stack ps whoogle-search
}

ds-whoogle-search-kill() {
    docker stack rm whoogle-search
    sleep 6
    docker volume prune
}

# wikijs
ds-wikijs() {
    ds-net-traefik
    DOMAIN=wikijs.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/wikijs.yml wikijs
    firefox https://wikijs.ds &
    watch docker stack ps wikijs
}

ds-wikijs-kill() {
    docker stack rm wikijs
    sleep 6
    docker volume prune
}

# wordpress
ds-wordpress() {
    ds-net-traefik
    DOMAIN=wordpress.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/wordpress.yml wordpress
    firefox https://wordpress.ds &
    watch docker stack ps wordpress
}

ds-wordpress-kill() {
    docker stack rm wordpress
    sleep 6
    docker volume prune
}

# writefreely
ds-writefreely() {
    ds-net-traefik
    DOMAIN=writefreely.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/writefreely.yml writefreely
    firefox https://writefreely.ds &
    watch docker stack ps writefreely
}

ds-writefreely-kill() {
    docker stack rm writefreely
    sleep 6
    docker volume prune
}

# zammad
ds-zammad() {
    ds-net-traefik
    DOMAIN=zammad.ds docker stack deploy -c /home/user/git/misc/awesome-stacks/stacks/zammad.yml zammad
    firefox https://zammad.ds &
    watch docker stack ps zammad
}

ds-zammad-kill() {
    docker stack rm zammad
    sleep 6
    docker volume prune
}
