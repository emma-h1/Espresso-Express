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

    self.coins = 0

    self.day = 0

    self.maxSecs = 5 -- max seconds for the level
    self.elapsedSecs = 0 -- elapsed seconds
    self.timeOut = false -- when time is out
    self.timerRunning = false -- control timer activation between day/night

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
end
    
function Stats:update(dt)
    self.timer:update(dt)

    if self.timeOut then
        self:handleTimeOut()
    end

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
end

function Stats:levelUp()
    self.level = self.level + 1
    self.targetScore = self.targetScore + self.level * 100
end

function Stats:clock()
    self.elapsedSecs = self.elapsedSecs + 1
    
    if self.elapsedSecs >= self.maxSecs then
        if self.coins >= 0 then
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