local Class = require "libs.hump.class"
local Sounds = require "src.game.SoundEffects"

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
end

-- Add an ingredient to drink
function Drink:addIngredient(category, name)
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
        self.includedIngredients[category] = name
        -- Play sound effects
        if category == "cups" then
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
    end
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
end

return Drink