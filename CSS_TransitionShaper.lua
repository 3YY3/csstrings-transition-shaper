--[[
Cinematic Studio Strings (CSS) note transition shaper
CSS_TransitionShaper.lua
Copyright © 2023 3YY3, MIT License
Not affiliated with Cinematic Studio Series in any way.
]]--

--NOTE: make randomization parameter to make shape every time a little different


-- DEFAULT VALUES
ppq = 960
--End

--GUI SLIDERS DEFAULT VALUES
preoffset = 0
postoffset = 0
intensity = 0
-- Real GUI default values are located at the end of the GUI section. Their setting 
-- is bugged in slider element so one needs to set values manually. Manual
-- setting is done in a super-shitty 'additive' way dependent on min max values,
-- horizontal/vertical type and increment value of particular slider. Take care.

--End


--Scythe GUI initialization
local libPath = reaper.GetExtState("Scythe v3", "libPath")
if not libPath or libPath == "" then
    reaper.MB("Couldn't load the Scythe library. Please install 'Scythe library v3' from ReaPack, then run 'Script: Scythe_Set v3 library path.lua' in your Action List.", "Whoops!", 0)
    return
end

loadfile(libPath .. "scythe.lua")()
--End


--Error messages and checks
function takeError()
    reaper.ShowMessageBox("Please, open some MIDI take in editor first.", "Error", 0)
end

function takeCheck(check)
    local check = true
    local noteFound = false
    local totalcnt, notecnt, cccnt = reaper.MIDI_CountEvts(take)
    for i = 0, notecnt, 1 do
        local _, sel = reaper.MIDI_GetNote(take, i)
        if sel == true then
            noteFound = true
        end
    end
    if cccnt == 0 then
        reaper.ShowMessageBox("No CC events to alter!", "Error", 0)
        check = false
    elseif notecnt == 0 then
        reaper.ShowMessageBox("No notes exist in active take!", "Error", 0)
        check = false
    elseif noteFound == false then
        reaper.ShowMessageBox("Please, select at least one note to edit.", "Error", 0)
        check = false
    end
    return check
end
--End


--Button click function
function btnClick()
    preoffset = GUI.Val("PreoffsetSlider")
    intensity = GUI.Val("Intensity")
    postoffset = GUI.Val("PostoffsetSlider")
    shapeTransition()
end
--End


--Shaper
function shapeTransition()
    local totalcnt, notecnt, cccnt = reaper.MIDI_CountEvts(take)
    local bpm, bpi = reaper.GetProjectTimeSignature2()
    local ticktime = 60000 / (bpm * ppq)
    for i = 0, notecnt, 1 do
        local _, sel, _, nstart, nend, _, _, _ = reaper.MIDI_GetNote(take, i)
        if sel == true then
            --Process to alter the CC1shape: 
            --1) retrieve actual cc1 val of note beginning
            --2) create new midiccevents based on variables of transitionlength(or pre-offset and post-offset) and transitionheight (dynamic spread of transition)
            --3) set the original note as unselected
            for i = 0, cccnt, 1 do
                local _, _, _, ccppqpos, chanmsg, chan, ccnumber, ccval = reaper.MIDI_GetCC(take, i)
                if ccppqpos == nstart and ccnumber == 1 then
                    
                    --Point 1: move original cc event down by intensity
                    newccval = ccval - intensity
                    if newccval > 127 then
                        newccval = 127
                    elseif newccval < 0 then
                        newccval = 0
                    end
                    reaper.MIDI_SetCC(take, i, false, false, ccppqpos, chanmsg, chan, ccnumber, newccval)
                    
                    --Point 2: create new point before point 1
                    local prediff = preoffset / ticktime
                    math.floor(prediff)
                    local preccppqpos = ccppqpos + prediff
                    reaper.MIDI_InsertCC(take, false, false, preccppqpos, chanmsg, chan, ccnumber, ccval)
                    
                    --Point 3: create new point after point 1
                    local postdiff = postoffset / ticktime
                    math.floor(postdiff)
                    local postccppqpos = ccppqpos + postdiff
                    reaper.MIDI_InsertCC(take, false, false, postccppqpos, chanmsg, chan, ccnumber, ccval)
                    
                    -- Set bezier curve
                    local _, _, cccnt = reaper.MIDI_CountEvts(take)
                    for i=0, cccnt, 1 do
                        reaper.MIDI_SetCCShape(take, i, 5, 0)
                    end
                    
                    break
                end
            end
        end
    end
end
--End


function Main()
    take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive())
    if take then
        local check = takeCheck(check)
        if check == true then
    --GUI layout----------------------------------------------------------------
            GUI = require("gui.core")

            window = GUI.createWindow({
                name = "CSS transient shaper tool",
                w = 900,
                h = 300,
            })

            layer = GUI.createLayer({
                name = "MainLayer"
            })
            layer:addElements( GUI.createElements(
                {
                name = "ApplyBtn",
                type = "Button",
                x = 752,
                y = 228,
                w = 128,
                h = 48,
                caption = "Apply",
                func = btnClick
                },
                {
                name = "PreoffsetSlider",
                type = "Slider",
                x = 16,
                y = 192,
                w = 384,
                h = 32,
                min = -500,
                max = 0,
                inc = 10,
                defaults = 0,
                showHandles = true,
                showValues = true,
                caption = "Pre-offset [ms]"
                },
                {
                name = "Intensity",
                type = "Slider",
                x = 448,
                y = 48,
                w = 128,
                h = 32,
                min = 0,
                max = 64,
                inc = 1,
                horizontal = false,
                defaults = 0,
                showHandles = true,
                showValues = true,
                caption = "Intensity"
                },
                {
                name = "PostoffsetSlider",
                type = "Slider",
                x = 500,
                y = 192,
                w = 384,
                h = 32,
                min = 0,
                max = 500,
                inc = 10,
                defaults = 0,
                showHandles = true,
                showValues = true,
                caption = "Post-offset [ms]"
                }
            ))

            window:addLayers(layer)
            
            window:open()
            GUI.Main()
            GUI.Val("PreoffsetSlider", 40) -- Set -100ms: increment by 10, so value has to be 10 times less. Minimum value is -500, so: -500 + 40*10 = -100.
            GUI.Val("Intensity", 54) -- Set 10: increment by 1. Maximum value is 64 (we care cause it's vertical, probably?), so: 64 - 54 = 10.
            GUI.Val("PostoffsetSlider", 25) -- Set 250ms: increment by 10, so value has to be 10 times less. Minimum value is 0, so: 0 + 25*10 = 250.
    --End-----------------------------------------------------------------------
            reaper.UpdateArrange()
        end
    else 
        takeError()
    end
end

Main()