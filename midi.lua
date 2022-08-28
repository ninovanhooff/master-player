---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 22/07/2022 14:45
---

local lume <const> = lume
local snd <const> = playdate.sound
local defaultDrumVolume <const> = 0.5
local defaultWaveVolume <const> = 0.2
local defaultWaveAttack <const> = 0
local defaultWaveDecay <const> = 0.15
local defaultWaveSustain<const> = 0.2
local defaultWaveRelease <const> = 0

function newWaveSynth(trackProps)
    local s = snd.synth.new(trackProps.synth or snd.kWaveSawtooth)
    s:setVolume(trackProps.volume or defaultWaveVolume)
    s:setADSR(
        trackProps.attack or defaultWaveAttack,
        trackProps.decay or defaultWaveDecay, 
        trackProps.sustain or defaultWaveSustain, 
        trackProps.release or defaultWaveRelease
    )
    return s
end

function createSampleSynth(samplePath, trackProps)
    local sample = snd.sample.new(samplePath)
    local s = snd.synth.new(sample)
    s:setVolume(trackProps.volume or defaultDrumVolume)
    -- no drum defaults yet, use wave defaults
    s:setADSR(
        trackProps.attack or defaultWaveAttack,
        trackProps.decay or defaultWaveDecay,
        trackProps.sustain or defaultWaveSustain,
        trackProps.release or defaultWaveRelease
    )
    return s
end

function createWaveInstrument(polyphony, trackProps)
    local inst = snd.instrument.new()
    for _=1, polyphony do
        inst:addVoice(newWaveSynth(trackProps))
    end
    return inst
end

function createDrumInstrument(trackProps)
    local inst = snd.instrument.new()
    local instrumentProps = playdate.file.run("libs/master-player/drums/instrumentProps")
    print("notes: ", trackProps.notes)
    for _, note in ipairs(trackProps.notes) do
        if instrumentProps[note] then
            inst:addVoice(createSampleSynth("libs/master-player/drums/" .. instrumentProps[note], trackProps), note) -- todo duplicate memory usage when samples are used for multiple notes?
        else
            print("instrument does not support note " .. note)
        end
    end
    return inst
end

function createInstrument(polyphony, trackProps)
    if trackProps.synth == "drums" then
        return createDrumInstrument(trackProps)
    else
        return createWaveInstrument(polyphony, trackProps)
    end
end

local function getNotesForTrack(track)
    local notes = {}
    for _, item in ipairs(track:getNotes(1, track:getLength())) do
        notes[item.note] = true
    end
    return lume.sort(lume.keys(notes))
end

local function createTrackProps(s)
    local numTracks = s:getTrackCount()
    local trackProps = {}
    local active = {}
    local poly = 0

    for i=1,numTracks do
        local track = s:getTrackAtIndex(i)
        if track ~= nil then
            local polyphony = track:getPolyphony()
            if polyphony > 0 then active[#active+1] = i end
            if polyphony > poly then poly = polyphony end
            print("track "..i.." has polyphony ".. polyphony)

            local notes = getNotesForTrack(track)
            local props = {
                isMuted = #notes < 1,
                isSolo = false,
                notes = notes
            }
            trackProps[i] = props

            if i == 10 then
                print("Creating Drums for track", i)
                props.synth = "drums"
                props.volume = defaultDrumVolume
                props.attack = defaultWaveAttack
                props.decay = defaultWaveDecay
                props.sustain = defaultWaveSustain
                props.release = defaultWaveRelease
                track:setInstrument(createDrumInstrument(trackProps[i]))
            else
                print("Creating Sawtooth for track", i)
                props.synth = snd.kWaveSawtooth
                props.volume = defaultWaveVolume
                props.attack = defaultWaveAttack
                props.decay = defaultWaveDecay
                props.sustain = defaultWaveSustain
                props.release = defaultWaveRelease
                local inst = createWaveInstrument(polyphony, trackProps[i])
                track:setInstrument(inst)
            end
        end
    end

    return trackProps
end

function loadTrackProps(s, trackProps)
    local numTracks = s:getTrackCount()
    for i=1,numTracks do
        local track = s:getTrackAtIndex(i)
        if track ~= nil then
            local polyphony = track:getPolyphony()
            track:setInstrument(createInstrument(polyphony, trackProps[i]))
        end
    end
    return trackProps
end

function loadMidi(path, _trackProps)
    print("loading", path)
    local trackProps = _trackProps or {}
    local s = snd.sequence.new(path)
    local ntracks = s:getTrackCount()
    print("ntracks", ntracks)

    if ntracks == #trackProps then
        return s, loadTrackProps(s, trackProps)
    else
        print("Creating track props for", path)
        return s, createTrackProps(s)
    end
end
