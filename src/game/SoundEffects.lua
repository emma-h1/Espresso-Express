local Globals = require "src.Globals"
-- Sound Dictionary / Table
local sounds = {}  -- create an empty table

-- Load sound effects
sounds['titleMusic'] = love.audio.newSource("sounds/cafe-music.mp3","static")
sounds['bell'] = love.audio.newSource("sounds/bell-ring.mp3","static")
sounds['nightMusic'] = love.audio.newSource("sounds/Cozy-Place-Chill-Background-Music.mp3","static")
sounds['crickets'] = love.audio.newSource("sounds/crickets.mp3","static")
sounds['doorClose'] = love.audio.newSource("sounds/door-lock.mp3","static")
sounds['timeOver'] = love.audio.newSource('sounds/timeOver.mp3', 'static')
sounds['gameOver'] = love.audio.newSource('sounds/brass-fail.mp3', 'static')
sounds['glassBreak'] = love.audio.newSource('sounds/glass-being-knocked-over-103473.mp3', 'static')
sounds['dayMusic'] = love.audio.newSource('sounds/mug-full-of-tunes.mp3','static')
sounds['pageTurn'] = love.audio.newSource('sounds/turnpage.mp3','static')
sounds['purchase'] = love.audio.newSource('sounds/purchase.mp3','static')
sounds['equip'] = love.audio.newSource('sounds/equip.mp3','static')
-- Config music options
sounds['titleMusic']:setLooping(true) -- game music is looped
sounds['dayMusic']:setLooping(true)
sounds['nightMusic']:setLooping(true)
sounds['titleMusic']:setVolume(musicVolume)
sounds['dayMusic']:setVolume(musicVolume)
sounds['nightMusic']:setVolume(musicVolume)
-- Config sound effect options
sounds['crickets']:setVolume(.4)

return sounds