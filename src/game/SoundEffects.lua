-- Sound Dictionary / Table
local sounds = {}  -- create an empty table

-- Load sound effects
sounds['titleMusic'] = love.audio.newSource("sounds/cafe-music.mp3","static")
sounds['bell'] = love.audio.newSource("sounds/bell-ring.mp3","static")

-- Config music options
sounds['titleMusic']:setLooping(true) -- game music is looped
sounds['titleMusic']:setVolume(0.3) -- volume 40%

return sounds