local samples = {
    {
        path = "Choir-C3.wav",
        noteStart = 47,
        noteRoot = 48,
        noteEnd = 49,
    },
    {
        path = "Choir-D#3.wav",
        noteStart = 50,
        noteRoot = 51,
        noteEnd = 52,
    },
    {
        path = "Choir-F#3.wav",
        noteStart = 53,
        noteRoot = 54,
        noteEnd = 55,
    },
    {
        path = "Choir-A3.wav",
        noteStart = 56,
        noteRoot = 57,
        noteEnd = 58,
    },
    {
        path = "Choir-C4.wav",
        noteStart = 59,
        noteRoot = 60,
        noteEnd = 61,
    },
    {
        path = "Choir-D#4.wav",
        noteStart = 62,
        noteRoot = 63,
        noteEnd = 64,
    },
    {
        path = "Choir-F#4.wav",
        noteStart = 65,
        noteRoot = 66,
        noteEnd = 67,
    },
    {
        path = "Choir-A4.wav",
        noteStart = 68,
        noteRoot = 69,
        noteEnd = 70,
    },
    {
        path = "Choir-C5.wav",
        noteStart = 71,
        noteRoot = 72,
        noteEnd = 73,
    },
    {
        path = "Choir-D#5.wav",
        noteStart = 74,
        noteRoot = 75,
        noteEnd = 76,
    },
    {
        path = "Choir-F#5.wav",
        noteStart = 77,
        noteRoot = 78,
        noteEnd = 79
    },
}


local result = {}

for _,item in ipairs(samples) do
    for note = item.noteStart, item.noteEnd do
        result[note] = item
    end
end

return result
