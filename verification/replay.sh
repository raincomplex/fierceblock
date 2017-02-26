if [ "$1" == "" ]; then echo 'Usage: ./replay FILE'; exit 1; fi
export REPLAY="$1"
./record.sh
