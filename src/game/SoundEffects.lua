-- Sound Dictionary / Table
local sounds = {}  -- create an empty table

-- Load sound effects
sounds['titleMusic'] = love.audio.newSource("sounds/cafe-music.mp3","static")
sounds['bell'] = love.audio.newSource("sounds/bell-ring.mp3","static")
sounds['nightMusic'] = love.audio.newSource("sounds/Cozy-Place-Chill-Background-Music.mp3","static")
sounds['crickets'] = love.audio.newSource("sounds/crickets.mp3","static")
sounds['doorClose'] = love.audio.newSource("sounds/door-lock.mp3","static")
sounds['timeOver'] = love.audio.newSource('sounds/timeOver.mp3', 'static')
-- Config music options
sounds['titleMusic']:setLooping(true) -- game music is looped
sounds['titleMusic']:setVolume(1)

sounds['nightMusic']:setLooping(true)

return sounds