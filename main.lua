local Globals = require "src.Globals"
local Push = require "libs.push"
local Sounds = require "src.game.SoundEffects"
local Tween = require "libs.tween"
local Stats = require "src.game.Stats"


-- Variables for fade transition between states
local fade = {
    fadeDuration = 2,  -- In seconds
    fadeOpacity = 0,       -- For fading out screen
    musicVolume = .5     -- For fading out music
}


-- Load is executed only once; used to setup initial resource for your game
function love.load()
    love.window.setTitle("Espresso Express")
    Push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = false, resizable = true})
    bgTween = nil

    stats = Stats()

    titleBg = love.graphics.newImage("graphics/backgrounds/titlescreen.png")
    dayBg = love.graphics.newImage('graphics/backgrounds/cafe-day.png')
    nightBg = love.graphics.newImage('graphics/backgrounds/cafe-night.png')
    gameOverBg = love.graphics.newImage('graphics/backgrounds/gameOverScreen.png')

    counter = love.graphics.newImage('graphics/backgrounds/counter.png')
    timeOutClipboard = love.graphics.newImage('graphics/backgrounds/clipboard.png')
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
    
    elseif key == "return" and gameState == "dayState" and not stats.timerRunning and not bgTween then
        Sounds['crickets']:play()
        Sounds['doorClose']:play()
        bgTween = Tween.new(fade.fadeDuration, fade, {fadeOpacity = 1, musicVolume = 0}, 'linear')

    elseif key == "return" and gameState == "nightState" and not bgTween then
        Sounds['bell']:play()
        bgTween = Tween.new(fade.fadeDuration, fade, {fadeOpacity = 1, musicVolume = 0}, 'linear')
    
    elseif key == 'return' and gameState == "over" then
        gameState = 'start'
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
                Sounds['titleMusic']:setVolume(musicVolume)
                stats:startDayPhase()
                bgTween:reset()
                bgTween = nil
            end
        end
    elseif gameState == "dayState" then
        stats:update(dt)
        Sounds['dayMusic']:play()

        if bgTween then
            Sounds['dayMusic']:setVolume(fade.musicVolume)
            bgComplete = bgTween:update(dt)

            -- Tween completed, reset vars and switch gamestate
            if bgComplete then
                Sounds['dayMusic']:stop()
                Sounds['dayMusic']:setVolume(musicVolume)
                stats:startNightPhase()
                bgTween:reset()
                bgTween = nil
            end
        end

    elseif gameState == "nightState" then
        stats:update(dt)
        Sounds['nightMusic']:play()

        if bgTween then
            Sounds['crickets']:stop()
            Sounds['nightMusic']:setVolume(fade.musicVolume)
            bgComplete = bgTween:update(dt)

            -- Tween completed, reset vars and switch gamestate
            if bgComplete then
                Sounds['nightMusic']:stop()
                Sounds['nightMusic']:setVolume(musicVolume)
                stats:startDayPhase()
                bgTween:reset()
                bgTween = nil
            end
        end
        
    elseif gameState == "over" then
        Sounds['dayMusic']:stop()
        Sounds['bell']:stop()

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
    elseif gameState == "dayState" then
        drawDayState()
        stats:draw()

        if bgTween then
            love.graphics.setColor(0, 0, 0, fade.fadeOpacity)
            love.graphics.rectangle("fill", 0, 0, gameWidth, gameHeight)
            love.graphics.setColor(1, 1, 1, 1)
        end

    elseif gameState == 'nightState' then
        drawNightState()
        stats:draw()

        if bgTween then
            love.graphics.setColor(1, 1, 1, fade.fadeOpacity)
            love.graphics.rectangle("fill", 0, 0, gameWidth, gameHeight)
            love.graphics.setColor(1, 1, 1, 1)
        end

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

function drawDayState()
    stats:draw()
    love.graphics.draw(dayBg, 0, 0)
    love.graphics.draw(counter, 0, 0)
    if not stats.timerRunning then
        love.graphics.draw(timeOutClipboard, 0, -60)
    end
end

function drawNightState()
    stats:draw()
    love.graphics.draw(nightBg, 0, 0)
    love.graphics.draw(timeOutClipboard, 0, -60)
end

function drawGameOverState()
    love.graphics.draw(gameOverBg, 0, 0)
    love.graphics.print("Game Over", gameOverFont, gameWidth/2 -120, 60)
    love.graphics.printf("Day "..tostring(stats.day).." End", statFontLarge, gameWidth/2-110,150,200,"center")
    love.graphics.printf("Customers Served: Money Earned: Tips Earned: Drinks Thrown Away: Rent: Total Profit: Total Coins:", statFontSmall, gameWidth/2-110,200,200,"center")
    love.graphics.printf("You could not pay your rent, and the cafe was shut down", gameOverFont, gameWidth/2 - 350, 510, 650, "center")
    love.graphics.print("press enter to play again", gameOverFont, gameWidth/2 -230, 650)

end