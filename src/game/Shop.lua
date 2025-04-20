local Class = require "libs.hump.class"
local Sounds = require "src.game.SoundEffects"
local Globals = require "src.Globals"

local Shop = Class{}

function Shop:init(stats, ingredients)
    self.ingredients = ingredients

    -- Table of recipe upgrades
    self.upgrades = {
        {
            name = "Almond Milk",
            minLvlRequired = 1,
            price = 20,
            purchased = false,
            sprite = love.graphics.newImage('graphics/upgrades/almondMilk.png'),
            unlock = function() table.insert(self.ingredients.unlocked.milks, "Almond Milk") end
        },
        {
            name = "Oat Milk",
            minLvlRequired = 3,
            price = 50,
            purchased = false,
            sprite = love.graphics.newImage('graphics/upgrades/oatMilk.png'),
            unlock = function() table.insert(self.ingredients.unlocked.milks, "Oat Milk") end
        },
        {
            name = "Whipped Cream",
            minLvlRequired = 5,
            price = 60,
            purchased = false,
            sprite = love.graphics.newImage('graphics/upgrades/whippedCream.png'),
            unlock = function() table.insert(self.ingredients.unlocked.whippedCreams, "Whipped Cream") end
        },
        {
            name = "Caramel Syrup",
            minLvlRequired = 10,
            price = 75,
            purchased = false,
            sprite = love.graphics.newImage('graphics/upgrades/caramelSyrup.png'),
            unlock = function() table.insert(self.ingredients.unlocked.syrups, "Caramel Syrup") end
        },
        {
            name = "Chocolate Syrup",
            minLvlRequired = 10,
            price = 75,
            purchased = false,
            sprite = love.graphics.newImage('graphics/upgrades/chocolateSyrup.png'),
            unlock = function() table.insert(self.ingredients.unlocked.syrups, "Chocolate Syrup") end
        }
    }

    -- Table of decor to buy and display
    self.decor = {
        {
            name = "Bar Seating",
            location = "backFloor",
            price = 300,
            purchased = false,
            equipped = false,
            sprite = love.graphics.newImage('graphics/decor/bar-seating.png')
        },
        {
            name = "Paintings",
            location = "backWall",
            price = 200,
            purchased = false,
            equipped = false,
            sprite = love.graphics.newImage('graphics/decor/paintings.png')
        },
        {
            name = "Bookshelf",
            location = "backWall",
            price = 200,
            purchased = false,
            equipped = false,
            sprite = love.graphics.newImage('graphics/decor/bookshelf.png')
        },
        {
            name = "Potted Plants",
            location = "sideFloor",
            price = 100,
            purchased = false,
            equipped = false,
            sprite = love.graphics.newImage('graphics/decor/potted-plants.png')
        }
    }

    -- Track equipped decor by location, can only display 1 per location
    self.equippedDecor = {
        backFloor = nil,
        backWall = nil,
        sideFloor = nil
    }

    -- Buttons and others colors
    self.colors = {
        {0.28, 0.6, 0.35}, -- 1 buy button
        {0.28, 0.6, 0.35, 0.5}, -- 2 disabled buy button
        {0.7, 0.7, 0.7}, -- 3 purchased button
        {0.34, 0.4, 0.73}, -- 4 equip button
        {0.5, 0.5, 0.7}, -- 5 equipped button
        {.9, 0.4, 0.4}, -- 6 minLvlRequired not met
    }

    self.stats = stats
    self.currentTab = "upgrades"

    self.itemRowHeight = 90
    self.itemStartY = 200
    self.itemNameCol = 280
    self.priceCol = 540
    self.levelCol = 680
    self.buyButtonCol = 820
    self.equipButtonCol = 690
    
    -- Tab positioning and dimensions
    upgradesTab = love.graphics.newImage('graphics/backgrounds/tab-upgrades.png')
    decorTab = love.graphics.newImage('graphics/backgrounds/tab-decor.png')
    self.tabWidth = 60
    self.tabHeight = 150
    self.tabX = 210
    self.tabY = 115
    
    -- For making buttons
    self.buttonWidth = 120
    self.buttonHeight = 40
    self.buttonRadius = 5
end

-- Helper function to check button collision with mouse clicks AABB
function Shop:buttonCollision(mouseX, mouseY, buttonX, buttonY, buttonWidth, buttonHeight)
    return mouseX >= buttonX 
        and mouseX <= buttonX + buttonWidth 
        and mouseY >= buttonY 
        and mouseY <= buttonY + buttonHeight
end

function Shop:setCurrentTab(x, y)
    -- Check if click is on tab images
    if self:buttonCollision(x, y, self.tabX, self.tabY, self.tabWidth, self.tabHeight) then -- Clicked the upgrades tab
        self.currentTab = "upgrades"
        Sounds['pageTurn']:play()
    elseif self:buttonCollision(x, y, self.tabX, self.tabY + self.tabHeight, self.tabWidth, self.tabHeight) then -- Clicked the decor tab
        self.currentTab = "decor"
        Sounds['pageTurn']:play()
    end
end

function Shop:clickBuyButton(x, y, item, itemY)
    -- Player's lvl is lower than required for upgrade. Cannot buy item
    if self.currentTab == 'upgrades'
    and self.stats.level < item.minLvlRequired then
        return
    end
    -- Buy item when button is clicked and requirements met
    if not item.purchased
    and self:buttonCollision(x, y, self.buyButtonCol, itemY + 10, self.buttonWidth, self.buttonHeight) then  
        if self.stats.coins >= item.price then
            item.purchased = true
            self.stats:addOrSubtractCoin(-item.price)
            Sounds['purchase']:play()

            if self.currentTab == 'upgrades' then
                item.unlock()
            end
        end
    end
end

-- Button for decor tab only
function Shop:clickEquipButton(x, y, item, itemY)
    -- Equip a purchased item
    if self.currentTab == "decor"
    and item.purchased 
    and not item.equipped
    and self:buttonCollision(x, y, self.equipButtonCol, itemY + 10, self.buttonWidth, self.buttonHeight) then

        -- Unequip equipped item in the same location (if any)
        for _, decorItem in pairs(self.decor) do
            if decorItem.location == item.location and decorItem.equipped then
                decorItem.equipped = false
            end
        end
     
        -- Equip clicked item
        item.equipped = true
        self.equippedDecor[item.location] = item.sprite
        Sounds['equip']:play()
        return
    end

    -- Unequip equipped item
    if self.currentTab == "decor"
    and item.purchased 
    and item.equipped
    and self:buttonCollision(x, y, self.equipButtonCol, itemY + 10, self.buttonWidth, self.buttonHeight) then
        item.equipped = false
        self.equippedDecor[item.location] = nil
        Sounds['equip']:play()
        return
    end
end

function Shop:getCurrentItems()
    if self.currentTab == 'upgrades' then
        return self.upgrades
    elseif self.currentTab == 'decor' then
        return self.decor
    end
end

function Shop:mousepressed(x, y)
    self:setCurrentTab(x, y)

    -- Get the correct items table depending on current tab
    local currentItems = self:getCurrentItems()
    
    -- Handle user interactions with items
    for i, item in pairs(currentItems) do
        local itemY = self.itemStartY + (i-1) * self.itemRowHeight
        
        self:clickBuyButton(x, y, item, itemY)

        self:clickEquipButton(x, y, item, itemY)
    end
end

-- Helper function to draw buttons with rounded corners
function Shop:drawButton(x, y, width, height, radius, color)
    love.graphics.setColor(color)
    
    -- Draw the main rectangle
    -- Overlap two rectangles of different sizes so the corners are empty
    love.graphics.rectangle("fill", x + radius, y, width - 2 * radius, height)
    love.graphics.rectangle("fill", x, y + radius, width, height - 2 * radius)
    
    -- Draw the four rounded corners
    love.graphics.arc("fill", x + radius, y + radius, radius, math.pi, math.pi * 1.5)
    love.graphics.arc("fill", x + width - radius, y + radius, radius, math.pi * 1.5, math.pi * 2)
    love.graphics.arc("fill", x + radius, y + height - radius, radius, math.pi * 0.5, math.pi)
    love.graphics.arc("fill", x + width - radius, y + height - radius, radius, 0, math.pi * 0.5)
end

function Shop:drawTabs()
    -- Draw upgrades tab
    if self.currentTab == "upgrades" then
        -- Draw active tab with full opacity
        love.graphics.draw(upgradesTab, self.tabX, self.tabY)
    else
        -- Draw inactive tab with reduced opacity
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.draw(upgradesTab, self.tabX, self.tabY)
    end
    
    -- Draw decor tab
    if self.currentTab == "decor" then
        -- Draw active tab with full opacity
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(decorTab, self.tabX, self.tabY + self.tabHeight)
    else
        -- Draw inactive tab with reduced opacity
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.draw(decorTab, self.tabX, self.tabY + self.tabHeight)
    end
end

function Shop:drawColumnHeaders()
    love.graphics.setColor(0, 0, 0, 1) -- Black
    if self.currentTab == "upgrades" then
        love.graphics.printf("Upgrade", self.itemNameCol, self.itemStartY - 40, 200, "left")
        love.graphics.printf("Price", self.priceCol, self.itemStartY - 40, 100, "left")
        love.graphics.printf("Level Req", self.levelCol, self.itemStartY - 40, 100, "left")
    else
        love.graphics.printf("Item", self.itemNameCol, self.itemStartY - 40, 200, "left")
        love.graphics.printf("Price", self.priceCol, self.itemStartY - 40, 100, "left")
    end
end

function Shop:drawUpgradesPage(item, y)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.printf(item.name, self.itemNameCol, y + 10, 200, "left")
    love.graphics.printf(item.price .. " coins", self.priceCol, y + 10, 100, "left")
    
    if self.stats.level < item.minLvlRequired then -- Change color if level is lower than required to buy
        love.graphics.setColor(self.colors[6])
    end
    love.graphics.printf("Level " .. item.minLvlRequired, self.levelCol, y + 10, 100, "left")
    
    -- Draw buy/purchased button
    if item.purchased then
        self:drawButton(self.buyButtonCol, y + 10, self.buttonWidth, self.buttonHeight, self.buttonRadius, self.colors[3])
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.printf("PURCHASED", self.buyButtonCol, y + 15, self.buttonWidth, "center")
    else
        local canBuy = self.stats.coins >= item.price and self.stats.level >= item.minLvlRequired

        self:drawButton(self.buyButtonCol, y + 10, self.buttonWidth, self.buttonHeight, self.buttonRadius, 
            canBuy and self.colors[1] or self.colors[2])
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("BUY", self.buyButtonCol, y + 15, self.buttonWidth, "center")
    end
end

function Shop:drawDecorPage(item, y)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.printf(item.name, self.itemNameCol, y + 10, 200, "left")
    love.graphics.printf(item.price .. " coins", self.priceCol, y + 10, 100, "left")
    
    -- Draw buy/purchased button
    if item.purchased then
        self:drawButton(self.buyButtonCol, y + 10, self.buttonWidth, self.buttonHeight, self.buttonRadius, self.colors[3])
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.printf("PURCHASED", self.buyButtonCol, y + 15, self.buttonWidth, "center")
        
        -- Draw equip/equipped button
        if item.equipped then
            self:drawButton(self.equipButtonCol, y + 10, self.buttonWidth, self.buttonHeight, self.buttonRadius, self.colors[5])
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.printf("EQUIPPED", self.equipButtonCol, y + 15, self.buttonWidth, "center")
        else
            self:drawButton(self.equipButtonCol, y + 10, self.buttonWidth, self.buttonHeight, self.buttonRadius, self.colors[4])
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.printf("EQUIP", self.equipButtonCol, y + 15, self.buttonWidth, "center")
        end
    else
        local canBuy = self.stats.coins >= item.price

        self:drawButton(self.buyButtonCol, y + 10, self.buttonWidth, self.buttonHeight, self.buttonRadius, 
            canBuy and self.colors[1] or self.colors[2])
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("BUY", self.buyButtonCol, y + 15, self.buttonWidth, "center")
    end
end

function Shop:drawShopSprites(item, y)
    local spriteSize = 70  -- Size for the sprite thumbnail display
    local spriteX = 450    -- X position for sprites
    local imgWidth, imgHeight = item.sprite:getDimensions()
    -- Make the scale for the sprite
    local scale = math.min(spriteSize / imgWidth, spriteSize / imgHeight)
    local drawWidth, drawHeight = imgWidth * scale, imgHeight * scale
    -- Center the sprite
    local drawX = spriteX + (spriteSize - drawWidth) / 2
    local drawY = y + (self.itemRowHeight - drawHeight) / 2
    
    love.graphics.draw(item.sprite, drawX, drawY, 0, scale, scale)
end

function Shop:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(statFontSmall)
    
    self:drawTabs()

    self:drawColumnHeaders()

    local currentItems = self:getCurrentItems()
    
    for i, item in pairs(currentItems) do
        local y = self.itemStartY + (i-1) * self.itemRowHeight

        love.graphics.setColor(1,1,1,1)
        self:drawShopSprites(item, y)
        
        if self.currentTab == "upgrades" then
            self:drawUpgradesPage(item, y)
        elseif self.currentTab == "decor" then
            self:drawDecorPage(item, y)
        end
    end
    love.graphics.setColor(0,0,0,1)
    love.graphics.printf("Press Enter to Continue", statFontLarge, gameWidth/2-270,640,500,"center")
end

-- Draw the equipped decor in the day state
function Shop:drawEquippedDecor()
    for _, item in pairs(self.equippedDecor) do
        if item then
            love.graphics.draw(item, 0, 0)
        end
    end
end

return Shop