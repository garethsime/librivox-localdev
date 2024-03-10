#!/bin/bash

set -e

LIBRIVOX_CATALOG_DIR='librivox-catalog'
COLOR='always'

function help() {
    echo "Grabs a copy of librivox-catalog for you to mount into your docker containers."
    echo
    echo " -h|--help                     print this message"
    echo " -d|--librivox-dir=<dir>       the directory to dump the librivox-catalog code [DEFAULT: $LIBRIVOX_CATALOG_DIR]"
    echo " --color=<never|always>        whether to output colors [DEFAULT: always]"
    echo
    exit 1
}

function green() {
    if [ "$COLOR" == "always" ]; then
        GREEN='\033[0;32m'
        RESET='\033[0m'
        echo -e "$GREEN$1$RESET"
    else
        echo -e "$1"
    fi
}

#### Argument Parsing

TEMP=$(getopt -o 'hd:' -l 'help,librivox-dir:,color:' -n first-time-setup.sh -- "$@")
if [ $? -ne 0 ]; then
	  echo 'Terminating...' >&2
	  exit 1
fi

eval set -- "$TEMP"
unset TEMP

while true; do
    case "$1" in
        -d|--librivox-dir) LIBRIVOX_CATALOG_DIR="$2"; shift 2;;
        --color)
            case "$2" in
                always) COLOR="always";;
                never) COLOR="never";;
                *) echo 'Invalid value for --color'; help;;
            esac
            shift 2;;
        h) help;;
        --) shift; break;;
        *) help;;
    esac
done


#### Preflight Checks

if [ -d "$LIBRIVOX_CATALOG_DIR" ]; then
    echo "The ./$LIBRIVOX_CATALOG_DIR already exists, aborting first-time setup"
    exit 1
fi

if ! docker image inspect librivox-local >/dev/null 2>&1; then
    echo "You need to have built the 'librivox-local' image already"
    exit 1
fi

#### Actual setup code

green "Starting librivox-local and copying the files to './$LIBRIVOX_CATALOG_DIR'"
docker run --rm \
       -v "$(pwd)/$LIBRIVOX_CATALOG_DIR":/librivox/www/librivox.org/catalog \
       --entrypoint cp \
       librivox-local \
       -a /librivox/www/librivox.org/catalog.bak/. /librivox/www/librivox.org/catalog
echo "Done."

if [ ! -d "$LIBRIVOX_CATALOG_DIR" ]; then
    echo "The ./$LIBRIVOX_CATALOG_DIR failed to be created, aborting first-time setup"
    exit 2
fi

green "The directory will have the wrong permissions. You'll be asked for your sudo password to correct this."
green "(If you're uncomfortable with that, then exit now and run the 'chown' yourself.)"
green "(Even though you know it's just a 'chown', because you definitely didn't run a script off the internet without reading it first, right?)"
sudo -k chown -R "$(id -un):$(id -gn)" "$LIBRIVOX_CATALOG_DIR"
echo "Done."
