---------------------------------------------------------------------------------
-- The Saving Coupon
-- Alberto Vera
-- GeekBucket Software Factory
---------------------------------------------------------------------------------

os.execute('cls')
if display.topStatusBarContentHeight > 15 then
    display.setStatusBar( display.TranslucentStatusBar )
else
    display.setStatusBar( display.HiddenStatusBar )
end

-- Requeridos
local DBManager = require('src.resources.DBManager')
storyboard = require "storyboard"


-- Create and change scene
local isUser = false --DBManager.setupSquema()
local isLoaded = DBManager.isLoaded()


if isUser then
    if isLoaded then
        storyboard.gotoScene("src.Home")
    else
        storyboard.gotoScene("src.Reload")
    end
else
    storyboard.gotoScene("src.Login")
end

