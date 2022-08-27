---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 22/07/2022 14:45
---

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
    print("sample", samplePath, sample)
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
    inst:addVoice(createSampleSynth("drums/kick", trackProps), 35) -- todo duplicate memory usage when samples are used for multiple notes?
    inst:addVoice(createSampleSynth("drums/kick", trackProps), 36)
    inst:addVoice(createSampleSynth("drums/snare", trackProps), 38)
    inst:addVoice(createSampleSynth("drums/clap", trackProps), 39)
    inst:addVoice(createSampleSynth("drums/tom-low", trackProps), 41)
    inst:addVoice(createSampleSynth("drums/tom-low", trackProps), 43)
    inst:addVoice(createSampleSynth("drums/tom-mid", trackProps), 45)
    inst:addVoice(createSampleSynth("drums/tom-mid", trackProps), 47)
    inst:addVoice(createSampleSynth("drums/tom-hi", trackProps), 48)
    inst:addVoice(createSampleSynth("drums/tom-hi", trackProps), 50)
    inst:addVoice(createSampleSynth("drums/hh-closed", trackProps), 42)
    inst:addVoice(createSampleSynth("drums/hh-closed", trackProps), 44)
    inst:addVoice(createSampleSynth("drums/hh-open", trackProps), 46)
    inst:addVoice(createSampleSynth("drums/cymbal-crash", trackProps), 49)
    inst:addVoice(createSampleSynth("drums/cymbal-ride", trackProps), 51)
    inst:addVoice(createSampleSynth("drums/cowbell", trackProps), 56)
    inst:addVoice(createSampleSynth("drums/clav", trackProps), 75)
    return inst
end

function createInstrument(polyphony, trackProps)
    if trackProps.synth == "drums" then
        return createDrumInstrument(trackProps)
    else
        return createWaveInstrument(polyphony, trackProps)
    end
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

            local props = trackProps[i] or {
                isMuted = false,
                isSolo = false,
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
                track:setInstrument(createDrumInstrument(trackProps))
            else
                print("Creating Sawtooth for track", i)
                props.synth = snd.kWaveSawtooth
                props.volume = defaultWaveVolume
                props.attack = defaultWaveAttack
                props.decay = defaultWaveDecay
                props.sustain = defaultWaveSustain
                props.release = defaultWaveRelease
                local inst = createWaveInstrument(polyphony, trackProps)
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
        return s, createTrackProps(s)
    end
end
