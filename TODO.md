# TODO

## VS FREYA

- [ ] Freya
  - [ ] Sprites
  - [ ] Songs
    - [x] `freyin`
    - [ ] `alightly`
    - [ ] `uzil`
  - [x] Dialogue
    - [x] `freyin`
    - [x] `uzil`
    - [ ] Post-`uzil`
  - [x] Freeplay Icon
- [ ] Milky
  - [ ] Sprites
    - [x] Normal
    - [x] Annoyed
    - [x] Pissed
    - [ ] SHADOWW MILKY!!!!!!!!
  - [ ] Songs
    - [x] `lactose`
    - [x] `crystal`
    - [x] `intolerant`
    - [ ] `shadows` (still needs a better name)
  - [ ] Cutscenes
    - [x] `lactose`
    - [x] `intolerant`
    - [ ] `shadows`
    - [ ] Post-`shadows`
  - [x] Freeplay Icon
- [ ] Killer Animate
  - [ ] Sprites
    - [x] Normal
    - [x] Annoyed
    - [ ] Pissed
  - [ ] Songs
    - [x] `cubical`
    - [ ] `be-square`
    - [ ] `twisted-knife`
      - [ ] Finish chart
  - [x] Freeplay Icon

## KITSUNE ENGINE

### ADDITIONS AND WHATEVER

some stuff i finna add eventually/soon lol!

- [x] Chart generator via `.MIDI`
  - [x] Hint generation
  - [x] Note generation
  - [x] Automatic difficulty generation
  - [x] Store `.MIDI` file in `.FNFC` files
- [x] Unhardcode backing cards
- [ ] Softcode TitleState & MainMenuState
  - [ ] Unhardcode offsets for TitleState
  - [ ] Unhardcode more of the intro besides `introText.txt`
- [ ] Finish credits list menu
- [ ] Abstract support
- [ ] MODCHARTING!!!! (cuz yes)
- [ ] Extra key support
- [ ] WEGA NOTETYPE!!!!!!!!
- [ ] Finish improving caching for sprites and audio
  - [ ] Make `LoadingState` work outside of the `html5` target
- [ ] Audio effect support (`reverb`, `chorus`, `distortion`, and `delay`), cuz yes
- [ ] .GIF & .SVG support via `flxgif` and some SVG library for `flixel` idk
- [ ] Support for older Haxe versions
  - [ ] 4.2.5
  - [ ] 4.1.5
  - [ ] 5.0.0 (git)
  - [ ] 3.2.x
- [ ] Full CNE/Psych/Ludum Dare/osu!mania support via [`moonchart`](https://github.com/MaybeMaru/moonchart)
- [ ] EXPERIMENTAL Lua support (for modcharting only, since it isn't the main focus of the engine like Psych's)

## ENHANCEMENTS FROM ISSUES

- [x] [Add parallax/scrolling properties to CharacterData](https://github.com/FunkinCrew/Funkin/issues/3719)
- [ ] [Expand the Character/Animation Debug to let you add animations and misc. data](https://github.com/FunkinCrew/Funkin/issues/3726)
- [ ] [Let animated health icons bop like legacy ones do](https://github.com/FunkinCrew/Funkin/issues/3725)
- [ ] [Change the traffic light in Blazin's BG to be stuck on a red light](https://github.com/FunkinCrew/Funkin/issues/3743)

### FIX KNOWN BUGS

yeah vslice has more bugs than the fucking floor so im accounting whatever issues pop up on the base funkin repo lol

- [x] Characters in the Character Select menu keep cloning themselves
- [x] A-Bot Visualizer doesn't react to volume
- [x] The HaxeUI part of the Character Offset Editor isn't showing up
- [x] [Lag spikes (and freezes) occur a lot during gameplay; causing the game's song audio to desync](https://github.com/FunkinCrew/Funkin/issues/3495) (i set the vocal resync tolerance back to 100 since stutters varied from song to song)
- [x] [Inability to pan the camera in the Animation Debug](https://github.com/FunkinCrew/Funkin/issues/3690)
- [x] Freeplay difficulties aren't loading for some reason
- [x] [Input offsets don't apply to hit windows, only rating windows](https://github.com/FunkinCrew/Funkin/issues/3692)
- [x] `Conductor` doesn't update during gameplay
- [x] [You can die during the cutscenes in Week 3's Pico mixes](https://github.com/FunkinCrew/Funkin/issues/3146)
- [x] Characters don't apply to camera movement, for some reason
- [ ] Backspace crashes in the input offset menu
- [ ] [Some menus open in a very weird way when opening the debug selection menu](https://github.com/FunkinCrew/Funkin/issues/2438)
- [ ] DJ Boyfriend/Pico flickering, for some reason
- [ ] `Save` doesn't detect any data in the save file; leaving with a default save every session (idk how to fix this so i probly need some help for dis...)
- [ ] [Characters in the Character Select menu don't play their confirm animations if you select mid-transition too fast](https://github.com/FunkinCrew/Funkin/issues/3730)
- [ ] The character offsets in `blazin` get messed up when dying or restarting, including the death screen
