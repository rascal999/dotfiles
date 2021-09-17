alias k="kubectl"
alias d="docker"
alias kga="kubectl get all"
alias dpa="docker ps -a"
alias st="wget http://ipv4.download.thinkbroadband.com/1GB.zip && rm 1GB.zip"

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
    docker run --rm -d -p 80:80 citizenstig/dvwa
}

d-vulnerablewordpress() {
    docker run --rm --name vulnerablewordpress -d -p 80:80 -p 3306:3306 wpscan/vulnerablewordpress
}

d-vaas-cve-2014-6271() {
    docker run --rm -d -p 8080:80 hmlio/vaas-cve-2014-6271
}

d-vaas-cve-2014-0160() {
    docker run -d -p 8443:443 hmlio/vaas-cve-2014-0160
}

d-webgoat() {
    docker run --rm -p 8080:8080 --name webgoat -it danmx/docker-owasp-webgoat
}

d-nowasp() {
    docker run -d -p 80:80 citizenstig/nowasp
}

d-juice-shop() {
    docker run --rm -p 3000:3000 bkimminich/juice-shop
}

d-openvas() {
    docker run -d -p 443:443 --name openvas mikesplain/openvas:9
}

d-beef() {
    docker run --rm -it --net=host -v $HOME/.msf4:/root/.msf4:Z -v /tmp/msf:/tmp/data:Z --name=beef phocean/beef
}
