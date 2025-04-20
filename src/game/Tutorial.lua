local Class = require "libs.hump.class"
local Globals = require "src.Globals"

local Tutorial = Class{}

function Tutorial:init()
    self.pageText = {
        "Welcome to the Espresso Express Tutorial. The goal of the game is to serve customers the drinks they order and grow your cafe.",
        "Each day starts immediately. Customers will appear and order their drink on the main screen.",
        "Go to the kitchen to make the drink that matches the order. Drag and drop ingredients over the napkin to make the drink.",
        "The cup MUST be placed first, followed by the coffee from the coffee machine. After that, the order of ingredients does not matter.",
        "Click the trash to clear your build station. You will lose coins for wasting the drink.",
        "Once the drink is done, go back to the main screen and drag the drink over the customer. You will receive experience and coins if the order matches.",
        "When the day is over, you will have the chance to go to the shop and purchase upgrades and decor for your cafe.",
        "Upgrades are new ingredients that customers can order and you can include in your drinks.",
        "Decor are items to decorate your cafe and will show up when they are equipped. Only one item per location can be equipped. Click the equip button again to unequip.",
        "Every day you must earn enough coins to pay rent. If your coins drops below zero after a day is over, the game ends."
    }

    self.pageImg = {
        love.graphics.newImage('graphics/tutorialImages/tutorial1.png'),
        love.graphics.newImage('graphics/tutorialImages/tutorial2.png'),
        love.graphics.newImage('graphics/tutorialImages/tutorial3.png'),
        love.graphics.newImage('graphics/tutorialImages/tutorial4.png'),
        love.graphics.newImage('graphics/tutorialImages/tutorial5.png'),
        love.graphics.newImage('graphics/tutorialImages/tutorial6.png'),
        love.graphics.newImage('graphics/tutorialImages/tutorial7.png'),
        love.graphics.newImage('graphics/tutorialImages/tutorial8.png'),
        love.graphics.newImage('graphics/tutorialImages/tutorial9.png'),
        love.graphics.newImage('graphics/tutorialImages/tutorial10.png')
    }

    self.currentPage = 1
    self.totalPages = 10
end

function Tutorial:draw()
    love.graphics.draw(self.pageImg[self.currentPage],380, 200)
    love.graphics.setColor(0,0,0,1)
    love.graphics.printf(self.pageText[self.currentPage],statFontLarge, gameWidth/2-350,520,650,"center")
end

return Tutorial