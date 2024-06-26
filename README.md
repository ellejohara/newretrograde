# NewRetrograde

## Version 3.0

A retrograde plugin for MuseScore 3.x.

Basic Instructions:
Make a selection of notes, chords, and/or rests, on one or more staves with one or more voices, then run NewRetrograde to reverse the selection. Doesn't work so well if notes have text attachments on them such as chord notation or pedal markings, and note articulations get erased.

Tested on MuseScore 3.x in macOS and Windows 10 and it seems to work okay.

### Changelog

**3.0.8**
- Tuplets with rests now get removed properly before retrograde

**3.0.7**
- Fixed a bug that caused tuplets with notes of different durations to retrograde incorrectly

**3.0.6**
- Can now retrograde correctly when selection has a different number of voices in each measure

**3.0.5**

- Fixed a bug that broke the retrograde if the last measure of the score was selected

**3.0.4**

- Last measure before end of score now gets properly re-selected after retrograde

**3.0.3**

- Fixed a bug where the plugin wouldn't run if everything was selected via "Select all"
- Retrograde now writes selection completely in the last measure of the score (use rewindToTick instead of prev)

**3.0.2**

- Notes now get correct TPC values attached to them (again)
- Fixed a bug where the selection would deselect lower staves after retrograde

**3.0.1**

- Fixed problem selecting and retrograding lower staves

**3.0**

- Completely rewrote the code for the plugin (again)
- Streamlined the retrograde write process
- Multiple voices and staves with tuplets and chords now get retrograded correctly

**2.1**

- Fixed cursor rewind when everything is selected [elsewhere bugfix](https://musescore.org/en/node/333755#comment-1189340)
- Rewrote how notes and chords are created [elsewhere bugfix](https://musescore.org/en/node/333755#comment-1189404)

**2.0**

- Completely rewrote the code for the plugin
- Last measure select bugfix by [elsewhere](https://musescore.org/en/node/333755#comment-1152666)
- Tuplets now retrograde correctly
- Multiple voices and staves can now be retrograded

**1.1.0**

- MIDI note pitches now also include TPC data for proper accidentals
- Removed single-note code as the chord code can handle single notes

**1.0.1**

- Added functionality to include rests in retrograde selection
