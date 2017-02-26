MAME=sdlmame
ROM=tgm2p
ROMDIR=~/game/tetris/mame/
export SCRIPTDIR=`realpath \`dirname "$0"\``
export RECORD="$1"

$MAME -rp $ROMDIR $ROM -window \
      -autoboot_delay 0 -autoboot_script $SCRIPTDIR/run.lua
