# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[[ -s "$HOME/.grc.zsh" ]] && source $HOME/.grc.zsh

xmodmap -e "keycode 81=Prior KP_9"
xmodmap -e "keycode 89=Next KP_3"

alias dig="grc dig"
alias id="grc id"
alias ps="grc ps"
alias a-r="export TIMESTAMP=`date +%Y%m%d_%H%M%S` && asciinema rec $HOME/asciinema/asciinema_$TIMESTAMP.log"
alias a-k="grc kubectl"
alias a-d="grc docker"
alias a-kga="grc kubectl get all"
alias a-dpa="grc docker ps -a"
alias a-st="wget http://ipv4.download.thinkbroadband.com/1GB.zip -O /dev/null"
alias a-pingg="grc ping 8.8.8.8 -c 1"
alias a-pip="curl ifconfig.me"
alias a-sitecopy='wget -k -K -E -r -l 10 -p -N -F -nH '
alias a-ytmp3='youtube-dl --extract-audio --audio-format mp3 '
alias ff='firefox '

###
### Dunst
###
dunst-handle() {
    if [[ "$#" -eq "2" ]]; then
        ACTION=$(dunstify --action="default,Open" "$1")
        case "$ACTION" in
        "default")
            firefox "$2"
            ;;
        esac
    else
        dunstify "$1"
    fi
}

###
### Misc
###
a-gg() {
    googler --np "$@"
}

d-shell() {
    docker run --rm -it --entrypoint=/bin/bash "$@"
}

d-shellsh() {
    docker run --rm -it --entrypoint=/bin/sh "$@"
}

d-shellhere() {
    dirname=${PWD##*/}
    docker run --rm -it --entrypoint=/bin/bash -v $(pwd):/${dirname} -w /${dirname} "$@"
}

d-shellhereport() {
    if [[ "$#" -ne "2" ]]; then
        echo "d-shellhereport <image> <port>"
        return 1 
    fi
    dirname=${PWD##*/}
    docker run --rm -it -v $(pwd):/${dirname} -p $2:$2 --entrypoint=/bin/bash "$1"
}

d-shellnamed() {
    echo -n "Instance name? "
    read INSTANCE
    docker run --network host --name $INSTANCE -i -t --entrypoint=/bin/bash "$@"
}

d-shellnamedhere() {
    dirname=${PWD##*/}
    echo -n "Instance name? "
    read INSTANCE
    docker run --network host --name $INSTANCE -it --entrypoint=/bin/bash -v $(pwd):/${dirname} -w /${dirname} "$@"
}

d-shellresume() {
    docker start "$@"
    docker exec -it "$@" /bin/bash
}

d-windowshellhere() {
    docker -c 2019-box run --rm -it -v "C:$(pwd):C:/source" -w "C:/source" "$@"
}

d-filebrowserhere() {
    screen -S filebrowser -adm docker run --rm --name filebrowser -p 1080:80 -v $(pwd):/srv filebrowser/filebrowser
    firefox http://127.0.0.1:1080/ &; disown
}

a-localhostrun-nginx() {
    docker run --rm --name localhostrun-nginx -d -p 1080:80 -p 8443:443 -v "$(pwd):/srv/data" rflathers/nginxserve
    ssh -R 80:localhost:1080 nokey@localhost.run
    echo "Stopping nginx docker instance.."
    docker stop localhostrun-nginx
}

a-localhostrun-filebrowser() {
    docker run --rm --name localhostrun-filebrowser -d -p 1080:80 -v $(pwd):/srv filebrowser/filebrowser
    ssh -R 80:localhost:1080 nokey@localhost.run
    echo "Stopping filebrowser docker instance.."
    docker stop localhostrun-filebrowser
}

a-cloudmapper-gather() {
    if [[ "$#" -ne "3" ]]; then
        echo "a-cloudmapper-gather <DOCKER_VOLUME> <ACCESS_KEY_ID> <SECRET_ACCESS_KEY>"
        return 1
    fi

    docker run --rm -v ${1}-cloudmapper-account-data:/opt/cloudmapper/account-data \
        -v ${1}-cloudmapper-web:/opt/cloudmapper/web \
        -e AWS_ACCESS_KEY_ID=$2 -e AWS_SECRET_ACCESS_KEY=$3 \
        -p 8000:8000 -it cloudmapper /bin/bash -c \
            "ACCOUNT_ID=\`/usr/bin/aws sts get-caller-identity | jq -r '.Account'\`;  \
            python cloudmapper.py configure add-account --config-file config.json --name client --id \$ACCOUNT_ID ; \
            python cloudmapper.py collect --account client ; \
            python cloudmapper.py report --account client ; \
            python cloudmapper.py prepare --account client ;"
}

a-cloudmapper-serve() {
    if [[ "$#" -ne "3" ]]; then
        echo "a-cloudmapper-serve <DOCKER_VOLUME> <ACCESS_KEY_ID> <SECRET_ACCESS_KEY>"
        return 1
    fi

    # Serve results
    if docker run --rm -v "${1}-cloudmapper-web:/var/lib/nginx/html" -d \
        -p 8101:80 dceoy/nginx-autoindex; then
        dunst-handle "CloudMapper report ready" "http://localhost:8101/account-data/report.html?t=`date +%s`" &; disown
        dunst-handle "CloudMapper prepare ready" "http://localhost:8101/?t=`date +%s`" &; disown
    else
        dunst-handle "Error launching CloudMapper reports"
    fi
}

a-cloudmapper() {
    if [[ "$#" -ne "3" ]]; then
        echo "a-cloudmapper <DOCKER_VOLUME> <ACCESS_KEY_ID> <SECRET_ACCESS_KEY>"
        return 1
    fi

    if docker volume inspect ${1}-cloudmapper-account-data; then
        while true; do
            echo -n "${1}-cloudmapper-account-data docker volume exists, just serve? [Yn] "
            read yn
            case $yn in
                [Yy]* ) a-cloudmapper-serve $@; break;;
                [Nn]* ) a-cloudmapper-gather $@; a-cloudmapper-serve $@; break;;
                * ) a-cloudmapper-serve $@; break;;
            esac
        done
    else
        a-cloudmapper-gather $@
        a-cloudmapper-serve $@
    fi
}

a-scout-gather() {
    if [[ "$#" -ne "3" ]]; then
        echo "a-scout-gather <DOCKER_VOLUME> <ACCESS_KEY_ID> <SECRET_ACCESS_KEY>"
        return 1
    fi

    docker run --rm -v "${1}-scout:/scoutsuite-report" \
        -e AWS_ACCESS_KEY_ID=$2 -e AWS_SECRET_ACCESS_KEY=$3 \
        -it rossja/ncc-scoutsuite /bin/bash -c \
            "/root/scoutsuite/bin/scout aws --access-keys --access-key-id $2 \
            --secret-access-key $3"
}

a-scout-serve() {
    if [[ "$#" -ne "3" ]]; then
        echo "a-scout-serve <DOCKER_VOLUME> <ACCESS_KEY_ID> <SECRET_ACCESS_KEY>"
        return 1
    fi

    if docker run --rm -v "${1}-scout:/var/lib/nginx/html" -d -p 8100:80 \
        dceoy/nginx-autoindex; then
        dunst-handle "Scout report ready" "http://localhost:8100/?t=`date +%s`" &; disown
    else
        dunst-handle "Error launching scout reports"
    fi
}

a-scout() {
    if [[ "$#" -ne "3" ]]; then
        echo "a-scout <DOCKER_VOLUME> <ACCESS_KEY_ID> <SECRET_ACCESS_KEY>"
        return 1
    fi

    if docker volume inspect ${1}-scout; then
        while true; do
            echo -n "${1}-scout docker volume exists, just serve? [Yn] "
            read yn
            case $yn in
                [Yy]* ) a-scout-serve $@; break;;
                [Nn]* ) a-scout-gather $@; a-scout-serve $@; break;;
                * ) a-scout-serve $@; break;;
            esac
        done
    else
        a-scout-gather $@
        a-scout-serve $@
    fi
}

a-aws-security-viz(){
    if [[ "$#" -ne "3" ]]; then
        echo "a-aws-security-viz <DOCKER_VOLUME> <ACCESS_KEY_ID> <SECRET_ACCESS_KEY>"
        return 1
    fi

    if docker run -d --rm -p 8102:8102 -v ${1}-aws-viz:/aws-security-viz \
        --name sec-viz sec-viz /usr/local/bundle/bin/aws_security_viz \
        -a $2 -s $3 --renderer navigator --serve 8102; then
        dunst-handle "aws-security-viz report ready" "http://localhost:8102/navigator.html#aws-security-viz.png" &; disown
    else
        dunst-handle "Error launching aws-security-viz reports"
    fi
}

a-cartography(){
    while true; do
        echo -n "Launch cartography? [yN] "
        read yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) return 1; break;;
            * ) return 1; break;;
        esac
    done

    echo "Cartography uses ~/.aws, make sure this is set correctly."
    echo "Press enter to continue."
    read

    cd $HOME/git/nixos-bootstrap/resources/docker/cartography
    docker-compose up -d neo4j
    sleep 3
    docker-compose up -d cartography
    sleep 3
    dunst-handle "Cartography started" "http://localhost:7474" &; disown
    cd -
}

a-prowler-gather() {
    if [[ "$#" -ne "3" ]]; then
        echo "a-prowler-gather <DOCKER_VOLUME> <ACCESS_KEY_ID> <SECRET_ACCESS_KEY>"
        return 1
    fi

    # Permissions fix
    docker volume create ${1}-prowler
    VOL_PATH=`docker inspect ${1}-prowler | jq -r '.[].Mountpoint'`
    if [[ "${VOL_PATH: -6}" == "/_data" ]]; then
        echo "chmod 777 $VOL_PATH"
        sudo chmod 777 $VOL_PATH
    else
        echo "Error with prowler volume"
        read
    fi

    docker run -it --rm --name prowler -v ${1}-prowler:/prowler/output \
        --env AWS_ACCESS_KEY_ID="${2}" --env AWS_SECRET_ACCESS_KEY="${3}" \
        toniblyx/prowler:latest -M csv,json,json-asff,html
}

a-prowler-serve() {
    if [[ "$#" -ne "3" ]]; then
        echo "a-prowler-serve <DOCKER_VOLUME> <ACCESS_KEY_ID> <SECRET_ACCESS_KEY>"
        return 1
    fi

    if docker run --rm -v "${1}-prowler:/var/lib/nginx/html/prowler" -d -p 8104:80 \
        dceoy/nginx-autoindex; then
        dunst-handle "prowler report ready" "http://localhost:8104/prowler/?t=`date +%s`" &; disown
    else
        dunst-handle "Error launching prowler reports"
    fi
}

a-prowler() {
    if [[ "$#" -ne "3" ]]; then
        echo "a-prowler <DOCKER_VOLUME> <ACCESS_KEY_ID> <SECRET_ACCESS_KEY>"
        return 1
    fi

    if docker volume inspect ${1}-prowler; then
        while true; do
            echo -n "${1}-prowler docker volume exists, just serve? [Yn] "
            read yn
            case $yn in
                [Yy]* ) a-prowler-serve $@; break;;
                [Nn]* ) a-prowler-gather $@; a-prowler-serve $@; break;;
                * ) a-prowler-serve $@; break;;
            esac
        done
    else
        a-prowler-gather $@
        a-prowler-serve $@
    fi
}

a-aws-public-ips() {
    if [[ "$#" -ne "4" ]]; then
        echo "a-aws-public-ips <REGION> <CLIENT> <ACCESS_KEY_ID> <SECRET_ACCESS_KEY>"
        return 1
    fi

    TIMESTAMP=`date +%Y%m%d_%H%M%S`
    WORK_DIR=$HOME/tool-output/aws-public-ips/${TIMESTAMP}_${2}
    mkdir -p $WORK_DIR 2>/dev/null

    RESULTS="`date "+%Y%m%d_%H%M%S"`_${1}_aws_public_ips.txt"
    if docker run --rm \
        -e AWS_REGION="$1" -e AWS_ACCESS_KEY_ID="$3" \
        -e AWS_SECRET_ACCESS_KEY="$4" arkadiyt/aws_public_ips \
        > "$WORK_DIR/$RESULTS"; then
        dunst-handle "aws-public-ips report ready" "file:///$WORK_DIR/$RESULTS" &; disown
    else
        dunst-handle "Error launching aws-public-ips report"
    fi

    while true; do
        echo -n "nmap scan aws-public-ips? [Yn] "
        read yn
        case $yn in
            [Yy]* ) d-nmap -p - `cat $WORK_DIR/$RESULTS`; break;;
            [Nn]* ) break;;
            * ) d-nmap -p - `cat $WORK_DIR/$RESULTS`; break;;
        esac
    done
}

a-cloudsploit() {
    if [[ "$#" -ne "4" ]]; then
        echo "a-cloudsploit <COMPLIANCE_TYPE> <CLIENT> <ACCESS_KEY_ID> <SECRET_ACCESS_KEY>"
        return 1
    fi

    TIMESTAMP=`date +%Y%m%d_%H%M%S`
    WORK_DIR=$HOME/tool-output/cloudsploit/${TIMESTAMP}_${2}
    mkdir -p $WORK_DIR 2>/dev/null

    RESULTS="`date "+%Y%m%d_%H%M%S"`_${1}_cloudsploit.txt"
    if docker run --rm -e AWS_ACCESS_KEY_ID=$3 -e AWS_SECRET_ACCESS_KEY=$4 \
        --entrypoint="/var/scan/node_modules/.bin/cloudsploitscan" cloudsploit:0.0.1 \
        --compliance=$1 > "$WORK_DIR/$RESULTS"; then
        dunst-handle "cloudsploit (${1}) report ready" "file:///$WORK_DIR/$RESULTS" &; disown
    else
        dunst-handle "Error launching cloudsploit report"
    fi
}

###
### Lazy boy
###
awsscan() {
    if [[ "$#" -ne "4" ]]; then
        echo "awsscan <REGION> <DOCKER_VOLUME> <ACCESS_KEY_ID> <SECRET_ACCESS_KEY>"
        return 1
    fi

    echo "Starting scans.."
    echo "###"
    echo "### Cartography"
    echo "###"
    a-cartography
    echo "###"
    echo "### cloudsploit"
    echo "###"
    a-cloudsploit cis $2 $3 $4
    a-cloudsploit pci $2 $3 $4
    echo "###"
    echo "### aws-security-viz"
    echo "###"
    a-aws-security-viz $2 $3 $4
    echo "###"
    echo "### Scout"
    echo "###"
    a-scout $2 $3 $4
    echo "###"
    echo "### CloudMapper"
    echo "###"
    a-cloudmapper $2 $3 $4
    echo "###"
    echo "### Prowler"
    echo "###"
    a-prowler $2 $3 $4
    echo "###"
    echo "### aws-public-ips" 
    echo "###"
    a-aws-public-ips $1 $2 $3 $4
}

awsscan-collate() {
    if [[ "$#" -ne "1" ]]; then
        echo "awsscan-collate <CLIENT>"
        return 1
    fi

    PATH_AWS_VIZ=`docker inspect ${1}-aws-viz | jq -r '.[].Mountpoint'`
    PATH_CLOUDMAPPER_ACCOUNT_DATA=`docker inspect ${1}-cloudmapper-account-data | jq -r '.[].Mountpoint'`
    PATH_CLOUDMAPPER_WEB=`docker inspect ${1}-cloudmapper-web | jq -r '.[].Mountpoint'`
    PATH_PROWLER=`docker inspect ${1}-prowler | jq -r '.[].Mountpoint'`
    PATH_SCOUT=`docker inspect ${1}-scout | jq -r '.[].Mountpoint'`

    if [[ ${PATH_AWS_VIZ: -6} != "/_data" || \
          ${PATH_CLOUDMAPPER_ACCOUNT_DATA: -6} != "/_data" || \
          ${PATH_CLOUDMAPPER_WEB: -6} != "/_data" || \
          ${PATH_PROWLER: -6} != "/_data" || \
          ${PATH_SCOUT: -6} != "/_data" ]]; then
        echo "Issue assigning docker volume mountpoint variables, check them"
        return 1
    fi

    TIMESTAMP=`date +%Y%m%d_%H%M%S`
    mkdir ${TIMESTAMP}_${1}_data
    mkdir ${TIMESTAMP}_${1}_data/aws_viz
    mkdir ${TIMESTAMP}_${1}_data/cloudmapper-account-data
    mkdir ${TIMESTAMP}_${1}_data/cloudmapper-web
    mkdir ${TIMESTAMP}_${1}_data/prowler
    mkdir ${TIMESTAMP}_${1}_data/scout
    mkdir ${TIMESTAMP}_${1}_data/cloudsploit
    mkdir ${TIMESTAMP}_${1}_data/aws-pbulic-ips

    sudo cp -rf $PATH_AWS_VIZ ${TIMESTAMP}_${1}_data/aws_viz
    sudo cp -rf $PATH_CLOUDMAPPER_ACCOUNT_DATA ${TIMESTAMP}_${1}_data/cloudmapper-account-data
    sudo cp -rf $PATH_CLOUDMAPPER_WEB ${TIMESTAMP}_${1}_data/cloudmapper-web
    # So people can find account-data
    sudo mv ${TIMESTAMP}_${1}_data/cloudmapper-web/_data/index.html ${TIMESTAMP}_${1}_data/cloudmapper-web/_data/viz.html
    sudo cp -rf $PATH_PROWLER ${TIMESTAMP}_${1}_data/prowler
    sudo cp -rf $PATH_SCOUT ${TIMESTAMP}_${1}_data/scout
    sudo cp -rf ${HOME}/tool-output/aws-public-ips/*${1} ${TIMESTAMP}_${1}_data/aws-pbulic-ips
    sudo cp -rf ${HOME}/tool-output/cloudsploit/*${1} ${TIMESTAMP}_${1}_data/cloudsploit

    AWS_COLLATE_PASSWORD=`pwgen 20`
    sudo zip -q -r -P $AWS_COLLATE_PASSWORD ${TIMESTAMP}-${1}.zip ${TIMESTAMP}_${1}_data
    echo "Password for ${TIMESTAMP}-${1}.zip is $AWS_COLLATE_PASSWORD"

    sudo rm -rf ./${TIMESTAMP}_${1}_data

    #echo $PATH_AWS_VIZ
    #echo $PATH_CLOUDMAPPER_ACCOUNT_DATA
    #echo $PATH_CLOUDMAPPER_WEB
    #echo $PATH_PROWLER
    #echo $PATH_SCOUT
}

webscan() {
    d-sniper -c "sniper -t \"$@\""
    d-nikto "$@"
    d-feroxbuster-slow "$@"
    d-arjun "$@"
    d-spiderfoot
    d-testssl
    # nuclei
    CONTENT="$@ completed"
    notify-desktop "webscan - $CONTENT"
}

###
### Tools
###
d-vpn() {
    docker run -d --rm --cap-add=NET_ADMIN \
        --volume /home/user/vpn:/etc/wireguard/:ro \
        -p 127.0.0.1:1080:1080 \
        kizzx2/wireguard-socks-proxy
}

d-vpn-array() {
    if [[ "$#" -ne "1" ]]; then
        echo "d-vpn-array <instance-count>"
        return 1
    fi
    rm -rf /home/user/vpn/tmp_*

    for i in {1..$1}
    do
        mkdir /home/user/vpn/tmp_${i}
        RAND_CONF=`ls /home/user/vpn/*.conf |sort -R |tail -1`
        cp ${RAND_CONF} /home/user/vpn/tmp_${i}
        PORT_1080=$(expr 1080 + $i)

        docker run -d --rm --cap-add=NET_ADMIN \
            --volume /home/user/vpn/tmp_${i}:/etc/wireguard/:ro \
            -p 127.0.0.1:${PORT_1080}:1080 \
            kizzx2/wireguard-socks-proxy
    done

    PORT_1080_FIRST=$(expr 1080 + 1)
    PORT_1080_LAST=$(expr 1080 + $1)

    echo "VPN ports"
    echo "#########"
    echo "First instance"
    echo "1080 == ${PORT_1080_FIRST}"
    echo "Last instance"
    echo "1080 == ${PORT_1080_LAST}"
}

d-vpn-array-kill() {
    INSTANCES=$(docker ps -q -f "ancestor=kizzx2/wireguard-socks-proxy")
    if [[ "$INSTANCES" == "" ]]; then
        echo "No VPN instances to stop"
    else
        docker ps -q -f "ancestor=kizzx2/wireguard-socks-proxy" | xargs docker stop
    fi
}

d-tor() {
    docker run --rm -it -p 127.0.0.1:8118:8118 \
        -p 127.0.0.1:9050:9050 \
        -p 127.0.0.1:9051:9051 \
        -d dperson/torproxy
}

d-tor-array() {
    if [[ "$#" -ne "1" ]]; then
        echo "d-tor-array <instance-count>"
        return 1
    fi

    for i in {1..$1}
    do
        PORT_8118=$(expr 8118 + $i)
        PORT_9050=$(expr 9050 + $i)
        PORT_10051=$(expr 10051 + $i)
        docker run --rm -it -e TOR_ControlPort=0.0.0.0:9051 \
            -p 127.0.0.1:$PORT_8118:8118 \
            -p 127.0.0.1:$PORT_9050:9050 \
            -p 127.0.0.1:$PORT_10051:9051 \
            -d dperson/torproxy -p password
    done

    PORT_8118_FIRST=$(expr 8118 + 1)
    PORT_9050_FIRST=$(expr 9050 + 1)
    PORT_10051_FIRST=$(expr 10051 + 1)

    PORT_8118_LAST=$(expr 8118 + $1)
    PORT_9050_LAST=$(expr 9050 + $1)
    PORT_10051_LAST=$(expr 10051 + $1)

    echo "Tor ports"
    echo "#########"
    echo "First instance"
    echo "8118 == ${PORT_8118_FIRST}\t9050 == ${PORT_9050_FIRST}\t9051 == ${PORT_10051_FIRST}"
    echo "Last instance"
    echo "8118 == ${PORT_8118_LAST}\t9050 == ${PORT_9050_LAST}\t9051 == ${PORT_10051_LAST}"
}

d-tor-array-kill() {
    INSTANCES=$(docker ps -q -f "ancestor=dperson/torproxy")
    if [[ "$INSTANCES" == "" ]]; then
        echo "No tor instances to stop"
    else
        docker ps -q -f "ancestor=dperson/torproxy" | xargs docker stop
    fi
}

d-pcf() {
    docker-compose -f $HOME/git/pentest-tools/pcf/docker-compose.yml up
}

d-testssl() {
    if [[ "$#" -ne "1" ]]; then
        echo "d-testssl <url>"
        return 1
    fi

    TIMESTAMP=`date +%Y%m%d_%H%M%S`
    WORK_DIR=$HOME/tool-output/testssl/$TIMESTAMP
    mkdir -p $WORK_DIR 2>/dev/null
    screen -S ${TIMESTAMP}_testssl -adm testssl.sh \
        -oL ${WORK_DIR}/${TIMESTAMP}_testssl.txt \
        -oj ${WORK_DIR}/${TIMESTAMP}_testssl.json \
        -oH ${WORK_DIR}/${TIMESTAMP}_testssl.html "$1"
    #CONTENT="$@ completed"
    #notify-desktop "testssl - $CONTENT"
}

d-tlsmate() {
    if [[ "$#" -ne "1" ]]; then
        echo "d-tlsmate <url>"
        return 1
    fi

    docker run --rm -it guballa/tlsmate tlsmate scan \
        --progress $1
}

d-nuclei() {
    docker run --rm -v $(pwd):/mnt projectdiscovery/nuclei $@
}

d-eth-security-toolbox() {
    docker run -it --rm -v $(pwd):/share trailofbits/eth-security-toolbox
}

d-myth() {
    if [[ "$#" -ne "2" ]]; then
        echo "d-myth <file> <solv>"
        return 1
    fi

    TIMESTAMP=`date +%Y%m%d_%H%M%S`
    WORK_DIR=$HOME/tool-output/myth/$TIMESTAMP
    mkdir -p $WORK_DIR 2>/dev/null
    docker run -it --rm -v $(pwd):/home/mythril/sol mythril/myth a sol/$1 --solv $2 > $WORK_DIR/${TIMESTAMP}_myth 
    CONTENT="$@ completed"
    notify-dekstop "myth - $CONTENT"
}

d-thelounge() {
    screen -S thelounge -adm docker run --rm -it --name thelounge -e PUID=1000 -e PGID=1000 -e TZ=Europe/London -p 127.11.0.1:9000:9000 -v $HOME/.config/thelounge:/config ghcr.io/linuxserver/thelounge
    firefox http://127.11.0.1:9000 &; disown
}

d-stego-toolkit() {
    docker run --rm -it --name stego-toolkit -v $(pwd):/data dominicbreuker/stego-toolkit /bin/bash "$@"
}

d-bettercap() {
    docker run --rm -it --name bettercap --net=host bettercap/bettercap
}

d-ciphey() {
    docker run -it --rm --name ciphey -v $(pwd):/home/nonroot/workdir remnux/ciphey "$@"
}

d-astra() {
    docker run --rm -d --name astra-mongo mongo
    cd $HOME/git/pentest-tools/Astra
    docker build -t astra .
    docker run --rm -d -it --link astra-mongo:mongo -p 8094:8094 astra
    firefox http://localhost:8094 &; disown
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
    dunst-handle "EyeWitness - $CONTENT" "file:///$PWD/eyewitness_$TIMESTAMP/report.html" &; disown
}

d-cyberchef() {
    docker run --rm -d -p 8000:8000 mpepping/cyberchef
    firefox http://localhost:8000 &; disown
}

d-feroxbuster() {
    TIMESTAMP=`date +%Y%m%d_%H%M%S`
    WORK_DIR=$HOME/tool-output/feroxbuster/$TIMESTAMP
    LOOT_DIR="/mnt"
    LOOT_FILE="/mnt/feroxbuster.log"
    mkdir -p $WORK_DIR 2>/dev/null
    docker run --rm -v $WORK_DIR:$LOOT_DIR --net=host --init -it epi052/feroxbuster --auto-tune -k -r -u "$@" -x js,html -o $LOOT_FILE
    CONTENT="$@ completed"
    notify-desktop "feroxbuster - $CONTENT"
}

d-feroxbuster-slow() {
    d-feroxbuster "$@" -L 2 -t 2
    CONTENT="$@ completed"
    notify-desktop "feroxbuster-slow - $CONTENT"
}

d-hetty() {
    docker run --rm -v $HOME/.hetty:/root/.hetty -p 8080:8080 dstotijn/hetty
}

d-spiderfoot(){
    docker run --rm -p 5001:5001 spiderfoot
    firefox http://127.0.0.1:5001 &; disown
}

d-arjun(){
    if [[ "$#" -lt "1" ]]; then
        echo "d-arjun <URL>"
        return 1 
    fi

    TIMESTAMP=`date +%Y%m%d_%H%M%S`
    WORK_DIR=$HOME/tool-output/arjun/$TIMESTAMP
    LOOT_DIR="/mnt"
    mkdir -p $WORK_DIR 2>/dev/null
    docker run --rm -v $WORK_DIR:$LOOT_DIR arjun -u "$@" -oT $LOOT_DIR/arjun.txt -oJ $LOOT_DIR/arjun.json
    CONTENT="$@ completed"
    notify-desktop "arjun - $CONTENT"
}

d-sniper() {
    TIMESTAMP=`date +%Y%m%d_%H%M%S`
    WORK_DIR=$HOME/tool-output/sn1per/$TIMESTAMP
    LOOT_DIR="/usr/share/sniper/loot/workspace"
    mkdir -p $WORK_DIR 2>/dev/null
    docker run --rm -v $WORK_DIR:$LOOT_DIR -it xerosecurity/sn1per /bin/bash "$@"
    CONTENT="$@ completed"
    notify-desktop "sniper - $CONTENT"
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
    docker run --rm -it -p 445:445 -v "$(pwd):/tmp/serve" rflathers/impacket smbserver.py -smb2support $sharename /tmp/serve
}

d-nginxhere() {
    screen -S nginxhere -adm docker run --rm -it -p 1080:80 -p 443:443 -v "$(pwd):/srv/data" rflathers/nginxserve
    firefox http://127.0.0.1 &; disown
}

d-webdavhere() {
    docker run --rm -it -p 1080:80 -v "$(pwd):/srv/data/share" rflathers/webdav
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
    docker run --rm -it -v "${HOME}/.msf4:/home/msf/.msf4" -v "$(pwd):/data" metasploitframework/metasploit-framework ./msfvenom "$@"
}

d-reqdump() {
    docker run --rm -it -p 1080:3000 rflathers/reqdump
}

d-postfiledumphere() {
    docker run --rm -it -p 1080:3000 -v "$(pwd):/data" rflathers/postfiledump
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
    mkdir -p $WORK_DIR 2>/dev/null
    docker run -it --rm --net=host -w $LOOT_DIR -v $WORK_DIR:$LOOT_DIR booyaabes/kali-linux-full nikto -h "$@" -o $LOOT_DIR/nikto.txt
    CONTENT="$@ completed"
    notify-desktop "nikto - $CONTENT"
}

d-nmap() {
    TIMESTAMP=`date +%Y%m%d_%H%M%S`
    WORK_DIR=$HOME/tool-output/nmap/$TIMESTAMP
    LOOT_DIR="/mnt"
    mkdir -p $WORK_DIR 2>/dev/null
    if docker run --rm -v $WORK_DIR:/mnt --net=host --privileged booyaabes/kali-linux-full nmap -oA /mnt/$TIMESTAMP "$@"; then
        dunst-handle "nmap report ready" "file:///$WORK_DIR" &; disown
    else
        dunst-handle "Error launching nmap reports"
    fi
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
    screen -S altoro -adm docker run --rm --name altoro -p 127.10.0.1:1080:8080 eystsen/altoro
}

d-securityshepherd(){
    docker run -i -p 1080:80 -p 8443:443 ismisepaul/securityshepherd /bin/bash
}

d-dvwa() {
    echo "screen -r dvwa"
    screen -S dvwa -adm docker run --rm --name dvwa -p 127.10.0.2:1080:80 citizenstig/dvwa
}

d-vulnerablewordpress() {
    echo "screen -r vulnerablewordpress"
    screen -S vulnerablewordpress -adm docker run --rm --name vulnerablewordpress -p 127.10.0.3:1080:80 -p 3306:3306 l505/vulnerablewordpress
}

d-vaas-cve-2014-6271() {
    echo "screen -r vaas-cve-2014-6271"
    screen -S vaas-cve-2014-6271 -adm docker run --rm --name vaas-cve-2014-6271 -p 127.10.0.4:1080:80 hmlio/vaas-cve-2014-6271
}

d-vaas-cve-2014-0160() {
    echo "screen -r vaas-cve-2014-0160"
    screen -S vaas-cve-2014-0160 -adm docker run --rm --name vaas-cve-2014-0160 -p 127.10.0.5:8443:443 hmlio/vaas-cve-2014-0160
}

d-webgoat() {
    echo "screen -r webgoat"
    screen -S webgoat -adm docker run --rm --name webgoat -p 127.10.0.6:1080:8080 --name webgoat -it danmx/docker-owasp-webgoat
}

d-nowasp() {
    echo "screen -r nowasp"
    screen -S nowasp -adm docker run --rm --name nowasp -p 127.10.0.7:1080:80 citizenstig/nowasp
}

d-juice-shop() {
    echo "screen -r juice-shop"
    screen -S juice-shop -adm docker run --rm --name juice-shop -p 127.10.0.8:1080:3000 bkimminich/juice-shop
}

d-hackazon() {
    echo "screen -r hackazon"
    screen -S hackazon -adm docker run --rm --name hackazon -p 127.10.0.9:1080:80 mutzel/all-in-one-hackazon:postinstall supervisord -n
}

d-tiredful() {
    echo "screen -r tiredful"
    screen -S tiredful -adm docker run --rm --name tiredful -p 127.10.0.10:1080:8000 tuxotron/tiredful-api
}

d-xvwa() {
    echo "screen -r xvwa"
    screen -S xvwa -adm docker run --rm --name xvwa -p 127.10.0.11:1080:80 tuxotron/xvwa
}

d-security-ninjas() {
    echo "screen -r security-ninjas"
    screen -S security-ninjas -adm docker run --rm --name security-ninjas -p 127.10.0.12:1080:80 opendns/security-ninjas
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
    firefox https://appwrite.ds &; disown
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
    firefox https://bibliogram.ds &; disown
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
    firefox https://bookstack.ds &; disown
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
    firefox https://botpress.ds &; disown
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
    firefox https://calibre.ds &; disown
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
    firefox https://chatwoot.ds &; disown
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
    firefox https://commento.ds &; disown
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
    firefox https://crater.ds &; disown
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
    firefox https://cryptpad.ds &; disown
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
    firefox https://directus.ds &; disown
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
    firefox https://discourse.ds &; disown
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
    firefox https://dolibarr.ds &; disown
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
    firefox https://drawio.ds &; disown
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
    firefox https://element.ds &; disown
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
    firefox https://ethercalc.ds &; disown
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
    firefox https://etherpad.ds &; disown
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
    firefox https://ethibox.ds &; disown
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
    firefox https://fathom.ds &; disown
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
    firefox https://firefly.ds &; disown
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
    firefox https://flarum.ds &; disown
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
    firefox https://framadate.ds &; disown
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
    firefox https://freshrss.ds &; disown
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
    firefox https://ghost.ds &; disown
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
    firefox https://gitlab.ds &; disown
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
    firefox https://gogs.ds &; disown
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
    firefox https://grafana.ds &; disown
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
    firefox https://grav.ds &; disown
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
    firefox https://habitica.ds &; disown
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
    firefox https://hasura.ds &; disown
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
    firefox https://hedgedoc.ds &; disown
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
    firefox https://huginn.ds &; disown
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
    firefox https://invoiceninja.ds &; disown
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
    firefox https://jenkins.ds &; disown
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
    firefox https://jitsi.ds &; disown
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
    firefox https://kanboard.ds &; disown
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
    firefox https://listmonk.ds &; disown
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
    firefox https://magento.ds &; disown
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
    firefox https://mailserver.ds &; disown
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
    firefox https://mailtrain.ds &; disown
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
    firefox https://mastodon.ds &; disown
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
    firefox https://matomo.ds &; disown
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
    firefox https://mattermost.ds &; disown
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
    firefox https://matterwiki.ds &; disown
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
    firefox https://mautic.ds &; disown
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
    firefox https://mediawiki.ds &; disown
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
    firefox https://metabase.ds &; disown
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
    firefox https://minio.ds &; disown
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
    firefox https://mobilizon.ds &; disown
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
    firefox https://monitoring.ds &; disown
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
    firefox https://n8n.ds &; disown
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
    firefox https://nextcloud.ds &; disown
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
    firefox https://nitter.ds &; disown
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
    firefox https://nocodb.ds &; disown
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
    firefox https://odoo.ds &; disown
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
    firefox https://passbolt.ds &; disown
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
    firefox https://peertube.ds &; disown
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
    firefox https://phpbb.ds &; disown
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
    firefox https://pinafore.ds &; disown
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
    firefox https://pixelfed.ds &; disown
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
    firefox https://plume.ds &; disown
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
    firefox https://polr.ds &; disown
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
    firefox https://portainer.ds &; disown
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
    firefox https://posthog.ds &; disown
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
    firefox https://prestashop.ds &; disown
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
    firefox https://pydio.ds &; disown
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
    firefox https://pytition.ds &; disown
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
    firefox https://rainloop.ds &; disown
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
    firefox https://redmine.ds &; disown
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
    firefox https://registry.ds &; disown
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
    firefox https://rocketchat.ds &; disown
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
    firefox https://rsshub.ds &; disown
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
    firefox https://scrumblr.ds &; disown
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
    firefox https://searx.ds &; disown
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
    firefox https://suitecrm.ds &; disown
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
    firefox https://taiga.ds &; disown
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
    firefox https://talk.ds &; disown
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
    firefox https://traefik.ds &; disown
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
    firefox https://umami.ds &; disown
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
    firefox https://uptime-kuma.ds &; disown
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
    firefox https://waiting.ds &; disown
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
    firefox https://wallabag.ds &; disown
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
    firefox https://wekan.ds &; disown
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
    firefox https://whoogle-search.ds &; disown
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
    firefox https://wikijs.ds &; disown
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
    firefox https://wordpress.ds &; disown
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
    firefox https://writefreely.ds &; disown
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
    firefox https://zammad.ds &; disown
    watch docker stack ps zammad
}

ds-zammad-kill() {
    docker stack rm zammad
    sleep 6
    docker volume prune
}

# appwrite.ds bibliogram.ds bookstack.ds botpress.ds calibre.ds chatwoot.ds commento.ds crater.ds cryptpad.ds directus.ds discourse.ds dolibarr.ds drawio.ds element.ds ethercalc.ds etherpad.ds ethibox.ds fathom.ds firefly.ds flarum.ds framadate.ds freshrss.ds ghost.ds gitlab.ds gogs.ds grafana.ds grav.ds habitica.ds hasura.ds hedgedoc.ds huginn.ds invoiceninja.ds jenkins.ds jitsi.ds kanboard.ds listmonk.ds magento.ds mailserver.ds mailtrain.ds mastodon.ds matomo.ds mattermost.ds matterwiki.ds mautic.ds mediawiki.ds metabase.ds minio.ds mobilizon.ds monitoring.ds n8n.ds nextcloud.ds nitter.ds nocodb.ds odoo.ds passbolt.ds peertube.ds phpbb.ds pinafore.ds pixelfed.ds plume.ds polr.ds portainer.ds posthog.ds prestashop.ds pydio.ds pytition.ds rainloop.ds redmine.ds registry.ds rocketchat.ds rsshub.ds scrumblr.ds searx.ds suitecrm.ds taiga.ds talk.ds traefik.ds umami.ds uptime-kuma.ds waiting.ds wallabag.ds wekan.ds whoogle-search.ds wikijs.ds wordpress.ds writefreely.ds zammad.ds 
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
