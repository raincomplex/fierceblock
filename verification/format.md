
A replay file is a series of commands. Each command is a keyword, then optional data separated by whitespace, then a newline.

Some commands only appear at the beginning of a replay. They are:

* `src NAME` -- denotes the software which created the replay. NAME is "mame", "fierceblock", etc.
* `mode NUMBER` -- 0=normal, 1=master, 2=tgm+, 3=death, 4=doubles
* `prng BYTES` -- the PRNG seed as a list of bytes in decimal ("prng 32 47 129 55")
* `piece NUMBER` -- a kludge related to how mame ticks the PRNG before starting a game; will go away eventually, but for now consider it part of the `prng` command
* `start` -- signals the end of the header block and the beginning of the replay proper

Each frame of the replay consists of a bunch of commands which describe changes to the current game state and player inputs, terminated with a `frame` command, which signals an advancement of the game state.

* `input NAME VALUE` -- Input names: up, down, left, right, a, b, c, start, coin. And values: 0 (unpressed), 1 (pressed).
* `field X Y BLOCK` -- 1 <= X <= 10. 1 <= Y <= 20. X increases to the right and Y increases upward. BLOCK is a character from "ITJLOSZ", or "-" to indicate it is empty.
* `frame` -- advance to next frame, processing the inputs and updating the game state

Some changes are coming:

* a way to specify a piece sequence instead of using only a seed
* compensation for input lag (TAP = 1 frame, TGM = 2 frames)
