
* [Replay Format](format.md)

* TAP only saves its nvram after the title screen ("insert coin") disappears. So after you play a game, you have to fast forward past that to get the PRNG seed to be written to disk. Otherwise you will get the same seed again when you start a new recording. (This has been partially alleviated by the record script waiting a random number of frames before starting a game.)
