# Megophrys

## AS-IS NO WARRANTY

This is open-source for educational purposes and is not guaranteed to work
on your system or with your settings.

## Dependencies

 - [limb 1.2](https://github.com/27theo/limb/releases/tag/v1.2)
 - [WunderSys 1.3](https://github.com/tynil/WunderSys/releases/tag/v1.3)

## Packages

 - Megophrys: more refined, fully namespaced systems
 - Achaea [Unconverted]: all other settings used by Nasuta

It should go without saying the latter is "unstable" and of varying
quality.

## Lua Files

Most of the settings live in functions which live in scripts. Triggers
are lightweight and mostly call functions conditionally without any extra
logic. This should enhance the searchability of this repository.

For convenience, these are currently organized as follows:

 - `init.lua`: Initialization code
 - `events.lua`: Events fired by triggers
 - `Magi.lua`: Magi-specific stuff
 - `Util.lua`: Various utilities for selfishness and text-formatting
