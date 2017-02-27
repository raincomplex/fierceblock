if [ "$1" == "" ]; then echo 'Usage: ./replay FILE'; exit 1; fi
export REPLAY="$1"
rm -f desync.log
./record.sh
if [ -e desync.log ]; then echo 'DESYNC DETECTED'; exit 1; fi
