local Class = require "libs.hump.class"
local Sounds = require "src.game.SoundEffects"
local Timer = require "libs.hump.timer"

local Drink = Class{}

function Drink:init()
    -- Ingredients in the drink, stores the name (string) of the ingredient
    self.includedIngredients = {
        cups = nil,
        coffees = nil,
        milks = nil,
        whippedCreams = nil,
        syrups = nil,
        sugars = nil
    }

    self.timer = Timer.new()
    
    self.x = 430 -- Starting X of drink
    self.y = 450 -- Starting Y of drink

    -- Images to mix and match for drink

    -- Cups
    self.mug = love.graphics.newImage('graphics/drinkCombos/mug.png')
    self.glass = love.graphics.newImage('graphics/drinkCombos/glass.png')
    -- Coffee
    self.coffee = love.graphics.newImage('graphics/drinkCombos/coffee.png')
    -- Milk
    self.milk = love.graphics.newImage('graphics/drinkCombos/milk.png')
    -- Whipped Cream
    self.whippedCream = love.graphics.newImage('graphics/drinkCombos/whippedCream.png')
    -- Sugar
    self.sugar = love.graphics.newImage('graphics/drinkCombos/sugar.png')
    -- Syrups
    self.caramelSyrup = love.graphics.newImage('graphics/drinkCombos/caramelSyrup.png')
    self.chocolateSyrup = love.graphics.newImage('graphics/drinkCombos/chocolateSyrup.png')

    self.buildStation = love.graphics.newImage('graphics/sprites/napkin.png')

    self.animationX = 400 -- Staring x position of animation
    self.animationY = 300 -- Starting y position of animation
    self.isAnimating = nil -- Is an animation happening true/nil
    self.currentAnimationSheet = nil -- For drawing
    self.currentAnimation = nil -- For drawing

    -- get dimensions based on cup requested (helper for dragging)
    self.cupSizes = {

        mug = {width = self.mug:getWidth(), height = self.mug:getHeight()},
        glass = {width = self.glass:getWidth(), height = self.glass:getHeight()},

    }
    
    self.dragging = nil
end

-- help get dimensions of depending whats ordered
function Drink:getDimensions()
    local cup = self.includedIngredients.cups
    if cup == "Mug" then
        return self.cupSizes.mug.width, self.cupSizes.mug.height
    elseif cup == "Glass" then
        return self.cupSizes.glass.width, self.cupSizes.glass.height
    else
        return 100, 100
    end
 
end

-- helpfuler function so ingredients and drink dragging logic doesnt overlap
function Drink:isReadyToServe()
    return self.includedIngredients.cups ~= nil and self.includedIngredients.coffees ~= nil
end

-- Add an ingredient to drink
function Drink:addIngredient(category, name, ingredient)
    if self.isAnimating then -- Do not allow more ingredients if animation is in progress
        return
    end
    -- Require a cup to be placed before anything
    if self.includedIngredients.cups == nil and category ~= "cups" then
        return
    end

    -- Require coffee to be placed after a cup and before anything else
    if self.includedIngredients.coffees == nil and category ~= "coffees" and category ~= "cups" then
        return
    end

    -- Only add ingredient if there is no other ingredient in the same category in the drink
    if not self.includedIngredients[category] then
        -- Play sound effects
        if category == "cups" then
            self.width = ingredient.itemWidth
            self.height = ingredient.itemHeight
            Sounds['glassClink']:play()
        elseif category == "coffees" then
            Sounds['coffeePour']:play()
        elseif category == "milks" then
            Sounds['milkPour']:play()
        elseif category == "sugars" then
            Sounds['sugar']:play()
        elseif category == "syrups" then
            Sounds['syrup']:play()
        elseif category == "whippedCreams" then
            Sounds['cream']:play()
        end

        if ingredient.hasAnimation == false then
            self.includedIngredients[category] = name -- ingredient doesn't have animation, immediately add to drink
        else
            self:startAnimation(category, name, ingredient)
        end
    end
end

function Drink:startAnimation(category, name, ingredient)
    self.isAnimating = true
    self.currentAnimationSheet = ingredient.animationSheet
    self.currentAnimation = ingredient.animation

    self.timer:clear()

    -- New ingredient is not drawn in drink until animation is done
    self.timer:after(1, function()  -- After the animation ends, add ingredient to drink so it can be drawn
        self.includedIngredients[category] = name
        self:resetAnimation() end)
end

-- Clear the current drink
function Drink:reset()
    self.includedIngredients = {
        cups = nil,
        coffees = nil,
        milks = nil,
        whippedCreams = nil,
        syrups = nil,
        sugars = nil
    }

    self:resetAnimation()
end

function Drink:resetAnimation()
    self.isAnimating = nil
    self.currentAnimationSheet = nil
    self.currentAnimation = nil
end

function Drink:update(dt)
    self.timer:update(dt)
    if self.isAnimating then
        self.currentAnimation:update(dt) -- Update the animation
    end
end

function Drink:draw()
    love.graphics.draw(self.buildStation, 450, 550) -- Draw the build station napkin

    -- Draw the cup of the drink, if any
    if self.includedIngredients.cups then
        if self.includedIngredients.cups == "Mug" then
            love.graphics.draw(self.mug, self.x, self.y)
        elseif self.includedIngredients.cups == "Glass" then
            love.graphics.draw(self.glass, self.x, self.y)
        end
    end

    -- Draw the coffee of the drink, if any
    if self.includedIngredients.coffees then
        love.graphics.draw(self.coffee, self.x, self.y)
    end

    -- Draw the milk of the drink, if any
    if self.includedIngredients.milks then
        love.graphics.draw(self.milk, self.x, self.y)
    end

    -- Draw the syrup of the drink, if any
    if self.includedIngredients.syrups then
        if self.includedIngredients.syrups == "Caramel Syrup" then
            love.graphics.draw(self.caramelSyrup, self.x, self.y)
        elseif self.includedIngredients.syrups == "Chocolate Syrup" then
            love.graphics.draw(self.chocolateSyrup, self.x, self.y)
        end
    end

    -- Draw the sugar of the drink, if any
    if self.includedIngredients.sugars then
        love.graphics.draw(self.sugar, self.x, self.y)
    end

    -- Draw the whipped cream of the drink, if any
    if self.includedIngredients.whippedCreams then
        love.graphics.draw(self.whippedCream, self.x, self.y)
    end

    -- Draw the animation, if occurring
    if self.isAnimating then
        self.currentAnimation:draw(self.currentAnimationSheet, self.animationX, self.animationY)
    end
end

function Drink:mousepressed(x, y)
    -- expand mouse click boundary
    local marginX = 35
    local marginY = 100
    -- no dragging during animation, and if drink not being served
    if self.isAnimating then return end
    if not self:isReadyToServe() then return end

    local drinkW, drinkH = self:getDimensions()
    if x >= self.x - marginX and x <= self.x + drinkW + marginX and y >= self.y - marginY and y <= self.y + drinkH + marginY then
        self.dragging = {
            offsetX = x - self.x,
            offsetY = y - self.y
        }        
    end
end

function Drink:mousemoved(x, y)
    -- Drink follows mouse as it's being dragged
    if self.dragging then
        self.x = x - self.dragging.offsetX
        self.y = y - self.dragging.offsetY
    end
end

return Drink