local Class = require "libs.hump.class"
local Globals = require "src.Globals"
local anim8 = require "libs.anim8"

local Ingredients = Class{}

function Ingredients:init(drink)
    -- All possible ingredients in game
    local mugSprite = love.graphics.newImage('graphics/sprites/mug.png') -- Make sprites a var to make getting dimensions easy
    local glassSprite = love.graphics.newImage('graphics/sprites/tallGlass.png')
    self.cups = {
        {
            name = "Mug",  -- Match names in the Shop.lua
            sprite = mugSprite, 
            x = 50,  -- Starting X 
            y = 115, -- Starting Y
            itemWidth = mugSprite:getWidth(), -- Width of the image
            itemHeight = mugSprite:getHeight(), -- Height of the image
            hasAnimation = false -- Ideally, everything would have an animation
        },
        {
            name = "Glass", 
            sprite = glassSprite, 
            x = 200, 
            y = 115,
            itemWidth = glassSprite:getWidth(),
            itemHeight = glassSprite:getHeight(),
            hasAnimation = false
        }
    }

    local coffeePotSprite = love.graphics.newImage('graphics/sprites/coffeePot.png')
    -- Sprites for animation
    local coffeePotAnimateImg = love.graphics.newImage("graphics/animationSprites/coffeePotAnimate.png")
    local coffeePotGrid = anim8.newGrid(300, 400, coffeePotAnimateImg:getWidth(), coffeePotAnimateImg:getHeight())
    local coffeePotAnimation = anim8.newAnimation(coffeePotGrid('1-5', 1), 0.2)
    self.coffees = {
        {
            name = "Coffee", 
            sprite = coffeePotSprite, 
            x = 830, 
            y = 280,
            itemWidth = coffeePotSprite:getWidth(),
            itemHeight = coffeePotSprite:getHeight(),
            hasAnimation = true,
            animationSheet = coffeePotAnimateImg,
            animation = coffeePotAnimation
        }
    }

    local regularMilkSprite = love.graphics.newImage('graphics/sprites/milk.png')
    local almondMilkSprite = love.graphics.newImage('graphics/upgrades/almondMilk.png')
    local oatMilkSprite = love.graphics.newImage('graphics/upgrades/oatMilk.png')

    -- Load regular milk sprite sheet and animation
    local milkAnimateImage = love.graphics.newImage("graphics/animationSprites/milkAnimate.png")
    local milkGrid = anim8.newGrid(300, 400, milkAnimateImage:getWidth(), milkAnimateImage:getHeight())
    local milkAnimation = anim8.newAnimation(milkGrid('1-5', 1), 0.2)
    self.milks = {
        {
            name = "Regular Milk", 
            sprite = regularMilkSprite, 
            x = 50, 
            y = 265,
            itemWidth = regularMilkSprite:getWidth(),
            itemHeight = regularMilkSprite:getHeight(),
            hasAnimation = true,
            animationSheet = milkAnimateImage,
            animation = milkAnimation
        },
        {
            name = "Almond Milk", 
            sprite = almondMilkSprite, 
            x = 200, 
            y = 265,
            itemWidth = almondMilkSprite:getWidth(),
            itemHeight = almondMilkSprite:getHeight(),
            hasAnimation = false
        },
        {
            name = "Oat Milk", 
            sprite = oatMilkSprite, 
            x = 350, 
            y = 265,
            itemWidth = oatMilkSprite:getWidth(),
            itemHeight = oatMilkSprite:getHeight(),
            hasAnimation = false
        }
    }

    local whippedCreamSprite = love.graphics.newImage('graphics/upgrades/whippedCream.png')
    self.whippedCreams = {
        {
            name = "Whipped Cream", 
            sprite = whippedCreamSprite, 
            x = 500, 
            y = 90,
            itemWidth = whippedCreamSprite:getWidth(),
            itemHeight = whippedCreamSprite:getHeight(),
            hasAnimation = false
        }
    }

    local caramelSyrupSprite = love.graphics.newImage('graphics/upgrades/caramelSyrup.png')
    local chocolateSyrupSprite = love.graphics.newImage('graphics/upgrades/chocolateSyrup.png')
    self.syrups = {
        {
            name = "Caramel Syrup", 
            sprite = caramelSyrupSprite, 
            x = 650, 
            y = 90,
            itemWidth = caramelSyrupSprite:getWidth(),
            itemHeight = caramelSyrupSprite:getHeight(),
            hasAnimation = false
        },
        {
            name = "Chocolate Syrup", 
            sprite = chocolateSyrupSprite, 
            x = 800, 
            y = 90,
            itemWidth = chocolateSyrupSprite:getWidth(),
            itemHeight = chocolateSyrupSprite:getHeight(),
            hasAnimation = false
        }
    }

    local sugarSprite = love.graphics.newImage('graphics/sprites/sugar.png')
    -- Load sugar sprite sheet and animation
    local sugarAnimateImage = love.graphics.newImage("graphics/animationSprites/sugarAnimate.png")
    local sugarGrid = anim8.newGrid(300, 400, sugarAnimateImage:getWidth(), sugarAnimateImage:getHeight())
    local sugarAnimation = anim8.newAnimation(sugarGrid('1-5', 1), 0.2)
    self.sugars = {
        {
            name = "Sugar", 
            sprite = sugarSprite,
            x = 350, 
            y = 115,
            itemWidth = sugarSprite:getWidth(),
            itemHeight = sugarSprite:getHeight(),
            hasAnimation = true,
            animationSheet = sugarAnimateImage,
            animation = sugarAnimation
        }
    }

    -- Unlocked items. Customers' orders are randomized from this
    self.unlocked = {
        cups = {"Mug", "Glass"},
        coffees = {"Coffee"},
        milks = {"Regular Milk"},
        whippedCreams = {},
        syrups = {},
        sugars = {"Sugar"}
    }

    -- Coffee machine positioning. This image is not clickable
    self.coffeeMachine = love.graphics.newImage('graphics/sprites/coffeeMachine.png')
    self.coffeeMachineX = 830
    self.coffeeMachineY = 280

    -- Build station napkin. Drag ingredients to this image to combine into drink
    self.buildStation = love.graphics.newImage('graphics/sprites/napkin.png')
    self.buildStationX = 450
    self.buildStationY = 600
    self.buildStationWdith, self.buildStationHeight = self.buildStation:getDimensions()

    self.currentDrink = drink -- The drink the player is building
    self.dragging = nil -- Info of item being dragged
end

-- Helper function to find an ingredient by name in a category
function Ingredients:getIngredient(category, name)
    for _, ingredient in pairs(self[category]) do
        if ingredient.name == name then
            return ingredient
        end
    end
    return nil
end

-- Helper function to check collision with mouse clicks AABB
function Ingredients:collision(mouseX, mouseY, areaX, areaY, areaWidth, areaHeight)
    return mouseX >= areaX
        and mouseX <= areaX + areaWidth
        and mouseY >= areaY
        and mouseY <= areaY + areaHeight
end

function Ingredients:mousepressed(x, y)
    -- Iterate through each name of ingredient in each category
    for category, _ in pairs(self.unlocked) do
        for _, name in pairs(self.unlocked[category]) do
            local ingredient = self:getIngredient(category, name) -- Get the ingredient info
            -- This ingredient is being dragged
            if ingredient and self:collision(x, y, ingredient.x, ingredient.y, 
                                                ingredient.itemWidth, ingredient.itemHeight) then
                -- Track original position of item to return it there when mousereleased
                ingredient.originalX = ingredient.x
                ingredient.originalY = ingredient.y
                -- Store info for the drag and the drink for building
                self.dragging = {
                    category = category,
                    name = name,
                    ingredient = ingredient,
                    offsetX = x - ingredient.x,
                    offsetY = y - ingredient.y
                }
                return
            end
        end
    end
end

function Ingredients:mousereleased(x, y)
    -- Prevent error from dragging outside window
    if x ~= nil and y ~= nil and self.dragging then
        -- Check if mouse is released over building station area
        if self:collision(x, y, self.buildStationX, self.buildStationY, 
                          self.buildStationWdith, self.buildStationHeight) then
            self.currentDrink:addIngredient(self.dragging.category, self.dragging.name, self.dragging.ingredient)
        end
        
        -- Reset ingredient position when released and don't drag item anymore
        self.dragging.ingredient.x = self.dragging.ingredient.originalX
        self.dragging.ingredient.y = self.dragging.ingredient.originalY
        self.dragging = nil
    end
end

function Ingredients:mousemoved(x, y)
    -- Ingredient follows mouse as it's being dragged
    if self.dragging then
        self.dragging.ingredient.x = x - self.dragging.offsetX
        self.dragging.ingredient.y = y - self.dragging.offsetY
    end
end

function Ingredients:draw()
    -- Draw cups
    for _, name in pairs(self.unlocked.cups) do
        local ingredient = self:getIngredient("cups", name)
        if ingredient then
            love.graphics.draw(ingredient.sprite, ingredient.x, ingredient.y)
        end
    end

    -- Draw sugars
    for _, name in pairs(self.unlocked.sugars) do
        local ingredient = self:getIngredient("sugars", name)
        if ingredient then
            love.graphics.draw(ingredient.sprite, ingredient.x, ingredient.y)
        end
    end

    -- Draw whipped creams
    for _, name in pairs(self.unlocked.whippedCreams) do
        local ingredient = self:getIngredient("whippedCreams", name)
        if ingredient then
            love.graphics.draw(ingredient.sprite, ingredient.x, ingredient.y)
        end
    end
    
    -- Draw syrups
    for _, name in pairs(self.unlocked.syrups) do
        local ingredient = self:getIngredient("syrups", name)
        if ingredient then
            love.graphics.draw(ingredient.sprite, ingredient.x, ingredient.y)
        end
    end
    
    -- Draw milks
    for _, name in pairs(self.unlocked.milks) do
        local ingredient = self:getIngredient("milks", name)
        if ingredient then
            love.graphics.draw(ingredient.sprite, ingredient.x, ingredient.y)
        end
    end

    -- Draw coffee pot
    local coffee = self:getIngredient("coffees", "Coffee")
    if coffee then
        love.graphics.draw(coffee.sprite, coffee.x, coffee.y)
    end

    -- Coffee pot is drawn and hidden behind coffee machine. The player sees the machine but picks up the pot

    love.graphics.draw(self.coffeeMachine,self.coffeeMachineX, self.coffeeMachineY) -- Player does not interact with this image
    
     -- Draw dragged ingredient if dragging
     if self.dragging then
         love.graphics.draw(self.dragging.ingredient.sprite, self.dragging.ingredient.x, self.dragging.ingredient.y)
     end
end

return Ingredients