# ADDITIONS AND WHATEVER
some stuff i finna add eventually/soon lol

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
- [ ] Extra key support
- [ ] Improve caching for sprites and audio
  - [ ] Make `LoadingState` work outside of the `html5` target
- [ ] LO-FI & HI-FI mode (kinda like Mic'd Up's implementation but cooler)
- [ ] .GIF & .SVG support via `flxgif` and some SVG library for `flixel` idk
- [ ] Full CNE/Psych/Ludum Dare/osu!mania support via [`moonchart`](https://github.com/MaybeMaru/moonchart)
- [ ] EXPERIMENTAL Lua support (will be barebones and specifically for modcharting, since it isn't the main focus of the engine like Psych's)

# ENHANCEMENTS FROM ISSUES
- [x] [Add parallax/scrolling properties to CharacterData](https://github.com/FunkinCrew/Funkin/issues/3719)
- [ ] [Expand the Character/Animation Debug to let you add animations and misc. data](https://github.com/FunkinCrew/Funkin/issues/3726)

# FIX KNOWN BUGS
yeah vslice has more bugs than the fucking floor so im accounting whatever issues pop up on the base funkin repo lol

- [x] Characters in the Character Select menu keep cloning themselves
- [x] A-Bot Visualizer doesn't react to volume
- [x] The HaxeUI part of the Character Offset Editor isn't showing up
- [x] [Lag spikes (and freezes) occur a lot during gameplay; causing the game's song audio to desync](https://github.com/FunkinCrew/Funkin/issues/3495)
- [x] [Inability to pan the camera in the Animation Debug](https://github.com/FunkinCrew/Funkin/issues/3690)
- [x] Freeplay difficulties aren't loading for some reason
- [x] [Input offsets don't apply to hit windows, only rating windows](https://github.com/FunkinCrew/Funkin/issues/3692)
- [x] `Conductor` doesn't update during gameplay
- [ ] Backspace crashes in the input offset menu
- [ ] DJ Boyfriend/Pico flickering, for some reason
- [x] [You can die during the cutscenes in Week 3's Pico mixes](https://github.com/FunkinCrew/Funkin/issues/3146)
- [ ] `Save` doesn't detect any data in the save file; causing it to not load
- [ ] [Characters in the Character Select menu don't play their confirm animations if you select mid-transition too fast](https://github.com/FunkinCrew/Funkin/issues/3730)
