---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 22/07/2022 17:05
---

local snd <const> = playdate.sound

local masterplayer <const> = masterplayer

masterplayer.sawToothInstrument = { source=snd.kWaveSawtooth, name="Sawtooth" }

masterplayer.instruments = {
    { source=snd.kWaveSine, name="Sine" },
    { source=snd.kWaveSquare, name="Square" },
    masterplayer.sawToothInstrument,
    { source=snd.kWaveTriangle, name="Triangle" },
    { source=snd.kWaveNoise, name="Noise" },
    { source=snd.kWavePOPhase, name="POPhase" },
    { source=snd.kWavePODigital, name="PODigital" },
    { source=snd.kWavePOVosim, name="POVosim" },
}

function masterplayer.addInstrument(path, name)
    masterplayer.instruments[#masterplayer.instruments+1] = { source=path, name=name }
end
