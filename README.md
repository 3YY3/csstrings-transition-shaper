# csstrings-transition-shaper
Tool for quick transition shaping of [Cinematic Studio Strings](https://cinematicstudioseries.com/strings/) legato and marcato.

This script is made for [Reaper DAW](https://www.reaper.fm/).


What this does is basically controlled dent in dynamics. When used carefully, one can enhance realism experience of listening to a track made with CSS.

I made this tool upon studying MIDI files provided by Alex Wallbank (creator of [Cinematic Studio libraries](https://cinematicstudioseries.com/)) himself. He programs his CC1 values so that he makes dynamics dent in place of transition from one note to another. This tool should help you do the same in case you draw CC1 values by mouse or you have them generated by a script (such as my [Musescore_CS_converter.lua](https://github.com/3YY3/musescore4-CS-converter/)) instead of recording them in real-time.

It is necessary that there exists CC1 event at the time of transition already! This script will alter this existing CC1 event, change it's value and create two more events (one before and one after) with original CC1 event value.

# How to use
1. Open MIDI editor,
2. select notes you want to alter (use second note of each transition, like in demo.png),
3. run the script,
4. you can set three values: *pre-offset* (time in ms when new previous CC1 event will be created), *post-offset* (time in ms when new after CC1 event will be created) and *intensity* (how much to decrease original CC1 event,
5. hit *Apply*


In the picture demo.png you can see what will happen upon using the script. Original MIDI events are on the left side of the picture, altered by the script on the right.

# Dependencies
In order to use this script, you need to install:
- [Scythe v3](https://jalovatt.github.io/scythe/#/)
