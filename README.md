# csstrings-transition-shaper
Tool for quick transition shaping of Cinematic Studio Strings legato and marcato.
What this does is basically controlled dent in dynamics. When used carefully, one can enhance realism experience of listening to a track made with CSS.
I made this tool upon studying MIDI files provided by Alex Wallbank (creator of CS libraries) himself. He programs his CC1 values so that he makes dynamics dent in place of transition from one note to another. This tool should help you do the same in case you draw CC1 values by mouse or you have them generated by a script (such as my Musescore_CS_converter.lua) instead of recording them in real-time.
It is necessary that there exists CC1 event at the time of transition already! This script will alter this existing CC1 event, change it's value and create two more events (one before and one after) with original CC1 event value.

# How to use
1. Open MIDI editor,
2. select notes you want to alter (use second note of each transition, like in demo.png),
3. run the script,
4. you can set three values: *pre-offset* (time in ms when new previous CC1 event will be created), *post-offset* (time in ms when new after CC1 event will be created) and *intensity* (how much to decrease original CC1 event,
5. hit *Apply*
