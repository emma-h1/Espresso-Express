local Globals = require "src.Globals"
local Push = require "libs.push"
local Sounds = require "src.game.SoundEffects"

-- Variables for fade transition between states
local fadeTimer = 0
local fadeDuration = 1.5  -- In seconds
local isFading = false
local fadeOpacity = 0       -- For fading out screen
local musicVolume = 1     -- For fading out music

-- Load is executed only once; used to setup initial resource for your game
function love.load()
    love.window.setTitle("Espresso Express")
    Push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = false, resizable = true})

    titleBg = love.graphics.newImage("graphics/backgrounds/titlescreen.png")
end

-- When the game window resizes
function love.resize(w,h)
    Push:resize(w,h) -- must called Push to maintain game resolution
end

-- Event for keyboard pressing
function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "F2" or key == "tab" then
        debugFlag = not debugFlag
    elseif key == "return" and gameState == "start" and not isFading then
        Sounds['bell']:play()
        isFading = true
    end
end

function love.mousepressed(x, y, button, istouch)

end

-- Update is executed each frame, dt is delta time (a fraction of a sec)
function love.update(dt)
    if gameState == "start" then
        Sounds['titleMusic']:play()

        if isFading then
            fadeTransition(dt, Sounds['titleMusic'], 'play')
        end
    elseif gameState == "play" then
        
    elseif gameState == "over" then

    end
end

-- Smoothly transition between one game state to another, fade screen to white/black and fade
-- music to silent
function fadeTransition(dt, sound, nextGameState)
    fadeTimer = fadeTimer + dt
            
    -- Calculate progress of timer until end of duration
    local progress = fadeTimer / fadeDuration
    
    -- Update fade values
    fadeOpacity = progress  -- 0 to 1 image to white screen
    musicVolume = 1 - progress  -- 1 to 0 full volume to silent
    
    sound:setVolume(musicVolume)
    
    -- When fade is complete change and reset vars
    if progress >= 1 then
        sound:stop()
        gameState = nextGameState
        fadeTimer = 0
        fadeOpacity = 0
        musicVolume = 1
        progress = 0
        isFading = false
    end
end

-- Draws the game after the update
function love.draw()
    Push:start()

    -- always draw between Push:start() and Push:finish()
    if gameState == "start" then
        drawStartState()
        
        -- Draw white overlay with increasing opacity during fade
        if isFading then
            love.graphics.setColor(1, 1, 1, fadeOpacity)
            love.graphics.rectangle("fill", 0, 0, gameWidth, gameHeight)
            love.graphics.setColor(1, 1, 1, 1)
        end
    elseif gameState == "play" then
        drawPlayState()    
    elseif gameState == "over" then
        drawGameOverState()    
    end

    if debugFlag then
        love.graphics.print("DEBUG ON", 20, gameHeight-20)
    end

    Push:finish()
end

function drawStartState()
    love.graphics.draw(titleBg, 0, 0)

    love.graphics.printf("press enter to play or escape to exit", titleFont,
        0, 650, gameWidth, "center")
end

function drawPlayState()
    love.graphics.printf("Espresso Express Game Page", titleFont, 0, 50,
    gameWidth, "center")
end

function drawGameOverState()

end