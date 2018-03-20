# SpaceRace
This repository houses a mostly-faithful reimplementation of 1995's Space 4X sleeper hit **Ascendancy**, made by the now defunct company **The Logic Factory**.

The codebase currently consists of Godot 2.1.4-styled GDScript and will likely move to Godot 3 in the future.

## Some important caveats:

- The game is incomplete as of March 2018
  - With the amount of features missing, it's not even in the typical alpha stage of development
  - There is no music. It's just not Ascendancy without the music..
  - There is no space travel in this space game.. yet. But ships can be ejected from planets, to be stuck in space forever.
- I don't have access to an iDevice compatible with the last released iOS version of the game, so can't compare or analyze that
- Without access to the source code, all game interactions can only be an approximation derived from existing gameplay (without the fabled Antagonizer patch, for now)
  - If you're reading this and you're a decompilation/disassembly wizard proficient in either Watcom compiled C++ from the 90s (bundled with DOS/4GW) or iOS ARM from 2012ish, and you're interested in contributing, hit me up!
- Much was learned from http://b-sting.nl/ascendancy/index.html and http://mikefay.info/wiki/index.php?title=Game-Ascendancy
- Where possible, data files and tables from the original were interpreted and used accordingly
- Wherever math is involved there might be inaccuracies - this is where the source would help, again
- Many of the UI elements are barely-reskinned Godot Engine default elements, although this does come with the benefit of supporting the mousewheel for scrollable containers natively \o/
- This repository does not contain the graphical assets required to run it to avoid copyright problems.
  - The extractor used during development has been modified by me to fix some minor bugs, I will likely have to find it again and fork it
  - These can be extracted from the original's data files, but the code's current organization is not prepared for a raw dump of index-based filenames.
  - This will require either a mapping file (which sounds like a candidate for making the game more moddable, ie texture packs), or a switch to a global texture manager (or both)
      - The TextureHandler aims to be the one spot where texture paths are collected, but Godot's Scene format kind of requires most of the paths to be stored in there, for now. It's probably possible to have all Sprites and TextureFrames load their textures in _ready(), though.
  - I'm currently focused on getting this mapping done and will likely have to distribute the game as a ready-to-compile Godot project, because at least Godot 2 doesn't exactly expose how multiple packed data files are supposed to be handled

## What does work (for the most part):
- Starting a new game
- Picking your race, color and the galaxy's settings
- The history screen
- Starfield / Cosmos generation
- Star System generation
- Crude nearest-neighbor Star Lanes that don't even connect all star clusters (obviously WIP)
- Much of the Cosmos / Galaxy Screen
- Many of the Gameplay Event notifications as well as advancing turns
- Much of the Star System / Battle Screen
- Most of the Planet Screen
  - supports both viewing empty planets as well as colonized ones
  - supports building up your colony while respecting most limitations like planet square type, required research and population 
- Most of the Planet List Screen
- Most of the Research Screen
- Rudimentary AI (very WIP)
  - picks not entirely unreasonable construction projects
  - follows a generally useful research plan in the beginning (targets early space travel, then prefers high-value research like the megafacility, if available)

## Current work in progress focus:
- building ships and colonizing
- control in the battle screen
- mapping the renamed texture files back to the original names and / or providing an extractor for the .cob files that just does the work
- colony management will need improvements so AIs build ships, too
- slowly getting to feature parity for each of the game's screens