local Class = require "libs.hump.class"
local Timer = require "libs.hump.timer"
local Tween = require "libs.tween" 
local Sounds = require "src.game.SoundEffects"
local Globals = require "src.Globals"

local Stats = Class{}
function Stats:init()
    self.level = 0 -- current level    
    self.totalScore = 0 -- total score so far
    self.targetScore = 100

    self.coins = 500

    self.day = 0

    self.maxSecs = 5 -- max seconds for the level
    self.elapsedSecs = 0 -- elapsed seconds
    self.timeOut = false -- when time is out
    self.timerRunning = false -- control timer activation between day/night

    -- Tween xp and coins when value changes, value lowers then disappears
    self.tweenScore = nil
    self.scoreY = 0
    self.tweenCoin = nil
    self.coinY = 0
    self.tweenScoreValue = 0
    self.tweenCoinValue = 0

    self.nightStarted = false
    self.timer = Timer.new()

    self.timer:every(1, function() 
        if self.timerRunning then
            self:clock() 
        end
    end)

    self.hud = love.graphics.newImage('graphics/backgrounds/stats-hud.png')
end

function Stats:draw()
    love.graphics.draw(self.hud, 0, 0)
    love.graphics.printf("Level "..tostring(self.level), statFontLarge, 67,30,100,"center")
    love.graphics.printf("Time "..tostring(self.elapsedSecs).."/"..tostring(self.maxSecs), statFontSmall,gameWidth - 150,130,200)
    love.graphics.printf(tostring(self.totalScore).."/"..tostring(self.targetScore), statFontSmall,90,65,200)
    love.graphics.printf(tostring(self.coins), statFontLarge,270,30,200)
    love.graphics.printf("Day "..tostring(self.day), statFontLarge,gameWidth-150,45,200)

    if not self.timerRunning and gameState == "dayState" then
        love.graphics.setColor(0,0,0)
        love.graphics.printf("Day "..tostring(self.day).." End", statFontLarge, gameWidth/2-110,140,200,"center")
        love.graphics.printf("Customers Served: Money Earned: Tips Earned: Drinks Thrown Away: Rent: Total Profit:", statFontSmall, gameWidth/2-110,190,200,"center")
        love.graphics.printf("Press Enter to Continue", statFontLarge, gameWidth/2-270,630,500,"center")
        love.graphics.setColor(1,1,1)
    end

    if self.tweenScore then
        love.graphics.setFont(statFontLarge)
        love.graphics.setColor(.2, .4, .2)
        love.graphics.print(self.tweenScoreValue, 67, self.scoreY)
        love.graphics.setColor(1, 1, 1)
    end

    if self.tweenCoin then
        love.graphics.setFont(statFontLarge)
        if self.tweenCoinValue > 0 then
            love.graphics.setColor(.2, .4, .2)
        else
            love.graphics.setColor(.5, .2, .2)
        end
        love.graphics.print(self.tweenCoinValue, 270, self.coinY)
        love.graphics.setColor(1, 1, 1)
    end
end
    
function Stats:update(dt)
    self.timer:update(dt)

    if self.timeOut then
        self:handleTimeOut()
    end

    if self.tweenScore then
        self.tweenScore:update(dt)
    end

    if self.tweenCoin then
        self.tweenCoin:update(dt)
    end

    Timer.update(dt)

    -- Game ends when the player has a negative nubmer of coins at the end of the day
    if not self.timerRunning and self.coins < 0 then
        Sounds['gameOver']:play()
        Sounds['glassBreak']:play()
        gameState = "over"
    end
end

function Stats:handleTimeOut()
    if gameState == "kitchenState" then
        gameState = "dayState"
    end
    if gameState == "dayState" then
        -- Stop timer when day time is out
        self.timerRunning = false
    end
    --reset timer for night cycle
    if gameState == "nightState" then
        self.timerRunning = false
    end
    self.timeOut = false
end

function Stats:startDayPhase()
    -- Reset timer and start it for the new day
    self.elapsedSecs = 0
    gameState = "dayState"
    self.timerRunning = true
    self.day = self.day + 1
end

function Stats:startKitchenPhase()
    gameState = "kitchenState"
    self.timerRunning = true
end

function Stats:addScore(n)
    self.totalScore = self.totalScore + n
    if self.totalScore >= self.targetScore then
        self:levelUp()
    end

    self.tweenScoreValue = n
    self.scoreY = 85
    self.tweenScore = Tween.new(1, self, {scoreY = self.scoreY + 10})

    Timer.after(1, function() self.tweenScore = nil end)
end

function Stats:addOrSubtractCoin(n)
    self.coins = self.coins + n
    self.tweenCoinValue = n
    self.coinY = 55
    self.tweenCoin = Tween.new(1, self, {coinY = self.coinY + 10})

    Timer.after(1, function() self.tweenCoin = nil end)
end

function Stats:levelUp()
    self.level = self.level + 1
    self.targetScore = self.targetScore + self.level * 100
end

function Stats:clock()
    self.elapsedSecs = self.elapsedSecs + 1
    
    if self.elapsedSecs >= self.maxSecs then
        if self.coins >= 0 and gameState == 'dayState' then
            Sounds['timeOver']:play()
        end
        self.timeOut = true
    end
end

function Stats:startNightPhase()
    -- Transition to night phase
    gameState = "nightState"
    self.elapsedSecs = 0
    self.timerRunning = true

end
    
return Stats