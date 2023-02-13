---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 29/09/2022 22:21
---

local masterplayer <const> = masterplayer
local loadSample = playdate.sound.sample.new

class("SampleCache", {}, masterplayer).extends()

function masterplayer.SampleCache:init()
    masterplayer.SampleCache.super.init()
    self.map = {}
end

function masterplayer.SampleCache:getOrLoad(path)
    if self.map[path] then
        return self.map[path]
    end

    print("Load sample", path)
    local sample = loadSample(path)
    self.map[path] = sample
    return sample
end

-- global singleton
if not masterplayer.sampleCache then
    masterplayer.sampleCache = masterplayer.SampleCache()
end
