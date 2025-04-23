local Class = require "libs.hump.class"
local Globals = require "src.Globals"
local Ingredients = require "src.game.Ingredients"
local CustomerParticles = require "src.game.CustomerParticles"
local Drink = require "src.game.Drink"
local Stats = require "src.game.Stats"
local anim8 = require "libs.anim8"
local Sounds = require "src.game.SoundEffects"


local sw, sh = 384, 512 -- animale sprite width and height
local customerSprites = love.graphics.newImage("graphics/sprites/character-sprites.png")

local animals = {
  bunny = love.graphics.newQuad(0, 0, sw, sh, customerSprites:getDimensions()),
  frog = love.graphics.newQuad(sw, 0, sw, sh, customerSprites:getDimensions()),
  capybara = love.graphics.newQuad(sw * 2,  0, sw, sh, customerSprites:getDimensions()),
  cat = love.graphics.newQuad(sw * 3,  0, sw, sh, customerSprites:getDimensions())
}

local thinkingBubbleImg = love.graphics.newImage("graphics/detail/thinking-bubble.png")
local thinkingGrid = anim8.newGrid(400, 800, thinkingBubbleImg:getWidth(), thinkingBubbleImg:getHeight())
local speechBubble = love.graphics.newImage("graphics/detail/speech-bubble.png")

local ingredients = Ingredients()  
local unlocked = ingredients:getUnlocked()
local stats = Stats()


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

  self.customerState = "thinking"
  self.thinkTimer = 0
  self.orderTimer = 0

  -- has the customer approached their spot at the table
  self.arrived = false
  self.served = false

  self.particles = CustomerParticles()
  self.drink = Drink()

  self.thinkingAnimation = anim8.newAnimation(thinkingGrid('1-3', 1), 1.2, 'pauseAtEnd')
  -- add tip
end

function Customer:update(dt)
  -- Move toward target position along serving table
  if self.customerState == "thinking" then
    if self.x < self.target then
      self.x = math.min(self.x + self.speed * dt, self.target)
      if self.x == self.target then 
        self.arrived = true
      else
        self.arrived = false
      end
    end
  end

  if self.customerState == "served" or self.customerState == "missed" then
    if self.x > -sw then 
      self.x = self.x - self.speed  * dt
    end
  end

  if self.particles:isActive() then
    self.particles:update(dt)
  end

  if self.arrived then 
    if self.customerState == "thinking" then 
      self.thinkingAnimation:update(dt)
      self.thinkTimer = self.thinkTimer + dt
      if self.thinkTimer > 4 then
        self.customerState = "ordering"
      end
    elseif self.customerState == "ordering" then
      self.orderTimer = self.orderTimer + dt
      if self.orderTimer < 15 and self.customerState == "served" then
        self.customerState = "done"
      elseif self.orderTimer > 20 then
          self.customerState = "missed"
      end
    end
  end 
end

function Customer:draw()
  love.graphics.draw(customerSprites, self.sprite, self.x, self.y)

  if self.arrived then 
    if self.customerState == "thinking" then
      self.thinkingAnimation:draw(thinkingBubbleImg, self.x + 30, self.y - 355)
    elseif self.customerState == "ordering" then
      love.graphics.draw(speechBubble,  self.x - 200, self.y - 120, 0, 0.2, 0.2)
      love.graphics.setFont(orderFont)
      love.graphics.setColor(0,0,0)
      love.graphics.printf(self:printOrder(), self.x + 100, self.y - 70, 400)
      love.graphics.setColor(1,1,1)
    end  
  end
  if self.particles:isActive() then
    self.particles:draw(self.x + 50, self.y + 50)
  end
  
end

function Customer:generateOrder()
  self.order = {}

  -- Order must have a cup
  local cupOptions = unlocked.cups
  self.order.cups = cupOptions[math.random(#cupOptions)]
  
  -- Coffee must be included
  local coffeeOptions = unlocked.coffees
  self.order.coffees = coffeeOptions[math.random(#coffeeOptions)]

  -- rest of the options are optional, with variability in choices
  local milkOptions = unlocked.milks
  if #milkOptions > 0 and math.random() < 0.9 then 
      self.order.milks = milkOptions[math.random(#milkOptions)]
  end

  local syrupOptions = unlocked.syrups
  if #syrupOptions > 0 and math.random() < 0.9 then
      self.order.syrups = syrupOptions[math.random(#syrupOptions)]
  end

  local whippedCreamOptions = unlocked.whippedCreams
  if #whippedCreamOptions > 0 and math.random() < 0.9 then
      self.order.whippedCreams = whippedCreamOptions[math.random(#whippedCreamOptions)]
  end

  local sugarOptions = unlocked.sugars
  if #sugarOptions > 0 and math.random() < 0.9 then
      self.order.sugars = sugarOptions[math.random(#sugarOptions)]
  end

  return self.order
end

function Customer:printOrder()
  -- mandatory ingredients, forces specification of cup type

  local drinkType = ""
  if self.order.cups == "Mug" then
      drinkType = "hot"
  elseif self.order.cups == "Glass" then
      drinkType = "iced"
  end

  -- base order (no addons)
  local orderText = string.format("Can I get a %s coffee", drinkType)

  -- if there are optional ingredients
  local addons = {}

  if self.order.milks then
      table.insert(addons, self.order.milks)
  end
  if self.order.syrups then
      table.insert(addons, self.order.syrups)
  end
  if self.order.sugars then
      table.insert(addons, self.order.sugars)
  end
  if self.order.whippedCreams then
      table.insert(addons, self.order.whippedCreams)
  end

  -- Concat addons to the order string
  if #addons > 0 then
      orderText = orderText .. " with " .. table.concat(addons, ", ", 1, #addons - 1)
      if #addons > 1 then
          orderText = orderText .. " and " .. addons[#addons]
      else
          orderText = orderText .. addons[1]
      end
  end
  orderText = orderText .. "?"
  return orderText
end

function Customer:serve(drink, stats)
  if self:compareOrder(drink.includedIngredients, self.order) then
      self.customerState = "served"
      self.served = true
      self.particles:trigger(self.x + 50, self.y + 50)
      Sounds["coffeeSip"]:play()

      if stats then
        stats:addOrSubtractCoin(10)
      end
      -- Add tip logic here
  else
      self.customerState = "missed"
      Sounds["angryCustomer"]:play()
      stats:addOrSubtractCoin(-2)


      -- add customer rating, leaves sad
  end
end

-- check if coffee served matches order
function Customer:compareOrder(drink1, drink2)
  local keys = {"cups", "coffees", "milks", "syrups", "sugars", "whippedCreams"}

  for _, key in ipairs(keys) do
      if drink1[key] ~= drink2[key] then
          return false
      end
  end
  return true
end

-- helper function to check drink is colliding with customer
function Customer:checkDrinkCollision(drink)
  local drinkW, drinkH = self.drink:getDimensions()

  return drink.x + drinkW > self.x and
         drink.x < self.x + sw and
         drink.y + drinkH > self.y and
         drink.y < self.y + sh
end

return Customer