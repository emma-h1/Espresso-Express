local Class = require "libs.hump.class"
local Ingredients = require "src.game.Ingredients"
local customerSprites = love.graphics.newImage("graphics/sprites/character-sprites.png")

local sw, sh = 384, 512 -- animale sprite width and height
local allCustomers = {}

local animals = {
  bunny = love.graphics.newQuad(0, 0, sw, sh, customerSprites:getDimensions()),
  frog = love.graphics.newQuad(sw, 0, sw, sh, customerSprites:getDimensions()),
  capybara = love.graphics.newQuad(sw * 2,  0, sw, sh, customerSprites:getDimensions()),
  cat = love.graphics.newQuad(sw * 3,  0, sw, sh, customerSprites:getDimensions())
}

local ingredients = Ingredients()  
local unlocked = ingredients:getUnlocked()

local Customer = Class{}
Customer.ANIMAL_TYPES = {"bunny", "frog", "capybara", "cat"}

function Customer:init(type,order,rating, custNum)
  self.order = order
  self.type = type
  self.rating = rating 
  self.sprite = animals[self.type] or bunny
  -- start customer out of frame to 
  self.x = -sw
  self.y = 200
  -- customer spot in line
  self.custNum = custNum
  self.speed = 100
  self.target = 100 + (custNum - 1) * sw

  -- add tip

end

function Customer:update(dt)
  -- Move toward target position along serving table
  if self.x < self.target then
    self.x = math.min(self.x + self.speed * dt, self.target)
  end
end

function Customer:draw()
  love.graphics.draw(customerSprites, self.sprite, self.x, self.y)
end  

function Customer:generateOrder()
  self.order = {}

  -- Order must have a cup
  local cupOptions = unlocked.cups
  self.order.cup = cupOptions[math.random(#cupOptions)]

  -- Coffee must be included
  local coffeeOptions = unlocked.coffees
  self.order.coffee = coffeeOptions[math.random(#coffeeOptions)]

  -- rest of the options are optional, with variability in choices
  local milkOptions = unlocked.milks
  if #milkOptions > 0 and math.random() < 0.7 then 
      self.order.milk = milkOptions[math.random(#milkOptions)]
  end

  local syrupOptions = unlocked.syrups
  if #syrupOptions > 0 and math.random() < 0.5 then
      self.order.syrup = syrupOptions[math.random(#syrupOptions)]
  end

  local whippedCreamOptions = unlocked.whippedCreams
  if #whippedCreamOptions > 0 and math.random() < 0.3 then
      self.order.whippedCream = whippedCreamOptions[math.random(#whippedCreamOptions)]
  end

  local sugarOptions = unlocked.sugars
  if #sugarOptions > 0 and math.random() < 0.6 then
      self.order.sugar = sugarOptions[math.random(#sugarOptions)]
  end

  return self.order
end

function Customer:getOrder(ingredients)
  return self.order
end

return Customer