# Level 0: A Snake clone written in Haskell, using SDL
## Features
* it works
* it's fast
* readable code (it's readable to me!)
* map loading
* scoreboard

## Prerequisites
* GHC (tested with 7.0.3 and 7.4.1)
* SDL libraries
* a font

## Installation / usage
$ make
$ bin/level_0 [ms between frames [path to map file]]
eg
$ bin/level_0 16 map

A map is a plain text file, the first 32 characters on the first 32 lines are read, and when there is an 'x', you will have a wall that kills your snake when hit.
