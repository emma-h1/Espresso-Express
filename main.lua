local Globals = require "src.Globals"
local Push = require "libs.push"
local Sounds = require "src.game.SoundEffects"
local Tween = require "libs.tween"

-- Variables for fade transition between states
local fade = {
    fadeDuration = 2,  -- In seconds
    fadeOpacity = 0,       -- For fading out screen
    musicVolume = 1     -- For fading out music
}

bgComplete = false 

-- Load is executed only once; used to setup initial resource for your game
function love.load()
    love.window.setTitle("Espresso Express")
    Push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = false, resizable = true})
    bgTween = nil

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
    elseif key == "return" and gameState == "start" and not bgTween then
        Sounds['bell']:play()
        bgTween = Tween.new(fade.fadeDuration, fade, {fadeOpacity = 1, musicVolume = 0}, 'linear')
    end
end

function love.mousepressed(x, y, button, istouch)

end

-- Update is executed each frame, dt is delta time (a fraction of a sec)
function love.update(dt)
    if gameState == "start" then
        Sounds['titleMusic']:play()

        if bgTween then
            Sounds['titleMusic']:setVolume(fade.musicVolume)
            bgComplete = bgTween:update(dt)

            -- Tween completed, reset vars and switch gamestate
            if bgComplete then
                Sounds['titleMusic']:stop()
                gameState = 'play'
                bgTween:reset()
                bgTween = nil
            end
        end
    elseif gameState == "play" then
        
    elseif gameState == "over" then

    end
end


-- Draws the game after the update
function love.draw()
    Push:start()

    -- always draw between Push:start() and Push:finish()
    if gameState == "start" then
        drawStartState()
        
        -- Draw white overlay with increasing opacity during fade
        if bgTween then
            love.graphics.setColor(1, 1, 1, fade.fadeOpacity)
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