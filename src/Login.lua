---------------------------------------------------------------------------------
-- The Saving Coupon
-- Alberto Vera
-- GeekBucket Software Factory
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- REQUIRE & VARIABLES
---------------------------------------------------------------------------------
local storyboard = require( "storyboard" )
local Sprites = require('src.resources.Sprites')
local DBManager = require('src.resources.DBManager')
local widget = require( "widget" )
local scene = storyboard.newScene()

-- Variables
local intX = display.contentWidth
local intY = display.contentHeight
local midX = display.contentCenterX
local midY = display.contentCenterY
local grpLogin, grpMask
local imgLogo, sprLoading, txtEmail, txtPass

---------------------------------------------------------------------------------
-- FUNCTIONS
---------------------------------------------------------------------------------

function goToHome()
    storyboard.gotoScene( "src.Reload", {time = 500, effect = "crossFade"})
end

-- Ajusta el contenido al mostrarse el teclado 
function onTxtFocus(event)
    if ( "began" == event.phase ) then
        -- Interfaz Sign In
        if grpLogin.y == 0 then
            transition.to( imgLogo, { y = 100, xScale=.5, yScale=.5, time = 400, transition = easing.outExpo } )
            transition.to( grpLogin, { y = -150, time = 400, transition = easing.outExpo } )
        end
    elseif ( "submitted" == event.phase ) then
        -- Hide Keyboard
        getReturnButtons()
        doSignIn()
    end
end

function getReturnButtons()
    if not (grpLogin.y == 0) then
        transition.to( imgLogo, { y = midY / 2, xScale=1, yScale=1, time = 400, transition = easing.outExpo } )
        transition.to( grpLogin, { y = 0, time = 400, transition = easing.outExpo } )
    end
end

function showMask(isDo)
    if isDo then
        grpMask.alpha = 1
        sprLoading:setSequence("play")
        sprLoading:play()
    else
        grpMask.alpha = 0
        sprLoading:setSequence("stop")
    end
end

function doSignIn()
    showMask(true)
    getReturnButtons()
    DBManager.updateUser(10,2)
    timer.performWithDelay( 2000, function()
        goToHome()
    end, 1 )
end

---------------------------------------------------------------------------------
-- OVERRIDING SCENES METHODS
---------------------------------------------------------------------------------
-- Called when the scene's view does not exist:
function scene:createScene( event )
    -- Agregamos el home
	local screen = self.view
    
    -- Background
    local background = display.newImage(screen, "img/bgkLogin.jpg", true) 
    background.x = midX
	background.y = 0
    background.anchorY = 0;
    
    -- Contenido
    imgLogo = display.newImage(screen, "img/imgLogo.png", true) 
    imgLogo.x = midX
	imgLogo.y = midY / 2
    
    -- TextFields Sign In
    grpLogin = display.newGroup()
	screen:insert(grpLogin)
    
    local imgFields = display.newImage(grpLogin, "img/imgFields.png", true) 
    imgFields.x = midX
	imgFields.y = midY
    
    txtEmail = native.newTextField( midX, midY - 30, 380, 60 )
    txtEmail.inputType = "email"
    txtEmail.hasBackground = false
    txtEmail.placeholder = "you@abc.com"
    txtEmail:addEventListener( "userInput", onTxtFocus )
	grpLogin:insert(txtEmail)
    
    txtPass = native.newTextField( midX, midY + 35, 380, 60 )
    txtPass.isSecure = true
    txtPass.hasBackground = false
    txtPass.placeholder = "my password"
    txtPass:addEventListener( "userInput", onTxtFocus )
	grpLogin:insert(txtPass)
    
    local btnLogin = display.newRoundedRect( midX, midY + 120, 400, 65, 10 )
    btnLogin:setFillColor( .231, .40, .557 ) 
    btnLogin:addEventListener( "tap", doSignIn )
    grpLogin:insert(btnLogin)
    
    local txtLogin = display.newText( "Log In", midX + 40, midY + 120, 150, 45, "OpenSans-ExtraBold", 28)
    txtLogin:setFillColor( 1 )
    grpLogin:insert(txtLogin)
    
    -- Loading
    grpMask = display.newGroup()
    grpMask.alpha = 0
    screen:insert(grpMask)
    
    local mask = display.newRect( midX, midY, intX, intY )
    mask:setFillColor( 0)
    mask.alpha = .5
    grpMask:insert(mask)
    
    local sheet = graphics.newImageSheet(Sprites.loading.source, Sprites.loading.frames)
    sprLoading = display.newSprite(sheet, Sprites.loading.sequences)
    sprLoading.x = midX
    sprLoading.y = midY 
    grpMask:insert(sprLoading)
    
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
end

function scene:exitScene( event )
    if txtEmail then
        txtEmail:removeSelf()
        txtEmail = nil
    end
    if txtPass then
        txtPass:removeSelf()
        txtPass = nil
    end
    Runtime:removeEventListener( "key", onKeyEvent )
end

-- Return button Android Devices
local function onKeyEvent( event )
    local phase = event.phase
    local keyName = event.keyName
    if ( "back" == keyName and phase == "up" ) then
        if groupBtn.x < 0 then
            getReturnButtons()
            return true
        end
    end
end
Runtime:addEventListener( "key", onKeyEvent )

scene:addEventListener("createScene", scene )
scene:addEventListener("enterScene", scene )
scene:addEventListener("exitScene", scene )

return scene

