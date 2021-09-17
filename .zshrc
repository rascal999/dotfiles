# Created by newuser for 5.8
function dockershell() {
    docker run --rm -i -t --entrypoint=/bin/bash "$@"
}

function dockershellsh() {
    docker run --rm -i -t --entrypoint=/bin/sh "$@"
}

function dockershellhere() {
    dirname=${PWD##*/}
    docker run --rm -it --entrypoint=/bin/bash -v `pwd`:/${dirname} -w /${dirname} "$@"
}

function dockershellshhere() {
    docker run --rm -it --entrypoint=/bin/sh -v `pwd`:/${dirname} -w /${dirname} "$@"
}

function dockerwindowshellhere() {
    dirname=${PWD##*/}
    docker -c 2019-box run --rm -it -v "C:${PWD}:C:/source" -w "C:/source" "$@"
}

impacket() {
    docker run --rm -it rflathers/impacket "$@"
}

smbservehere() {
    local sharename
    [[ -z $1 ]] && sharename="SHARE" || sharename=$1
    docker run --rm -it -p 445:445 -v "${PWD}:/tmp/serve" rflathers/impacket smbserver.py -smb2support $sharename /tmp/serve
}

nginxhere() {
    docker run --rm -it -p 80:80 -p 443:443 -v "${PWD}:/srv/data" rflathers/nginxserve
}

webdavhere() {
    docker run --rm -it -p 80:80 -v "${PWD}:/srv/data/share" rflathers/webdav
}

metasploit() {
    docker run --rm -it -v "${HOME}/.msf4:/home/msf/.msf4" metasploitframework/metasploit-framework ./msfconsole "$@"
}

metasploitports() {
    docker run --rm -it -v "${HOME}/.msf4:/home/msf/.msf4" -p 8443-8500:8443-8500 metasploitframework/metasploit-framework ./msfconsole "$@"
}

msfvenomhere() {
    docker run --rm -it -v "${HOME}/.msf4:/home/msf/.msf4" -v "${PWD}:/data" metasploitframework/metasploit-framework ./msfvenom "$@"
}

reqdump() {
    docker run --rm -it -p 80:3000 rflathers/reqdump
}

postfiledumphere() {
    docker run --rm -it -p80:3000 -v "${PWD}:/data" rflathers/postfiledump
}

kali() {
    docker run -t -i kalilinux/kali-linux-docker /bin/bash
}

d4r-dirb() {
    docker run -it --rm -w /data -v $(pwd):/data booyaabes/kali-linux-full dirb
}

d4r-dnschef() {
    docker run -it --rm -w /data -v $(pwd):/data --net=host booyaabes/kali-linux-full dnschef
}

d4r-hping3() {
    docker run -it --rm -w /data -v $(pwd):/data booyaabes/kali-linux-full hping3
}

d4r-responder() {
    docker run -it --rm --net=host booyaabes/kali-linux-full responder
}

d4r-nikto() {
    docker run -it --rm --net=host -w /data -v $(pwd):/data booyaabes/kali-linux-full nikto
}

d4r-nmap() {
    docker run --rm --net=host --privileged booyaabes/kali-linux-full nmap
}

d4r-searchsploit() {
    docker run --rm booyaabes/kali-linux-full searchsploit
}
