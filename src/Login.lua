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
local json = require("json")
local scene = storyboard.newScene()

-- Variables
local intX = display.contentWidth
local intY = display.contentHeight
local midX = display.contentCenterX
local midY = display.contentCenterY
local grpLogin, grpMask
local imgLogo, sprLoading, txtEmail, txtPass
local urlApi = "http://thesavingcoupon.com/"

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
            transition.to( imgLogo, { y = 130, xScale=.5, yScale=.5, time = 400, transition = easing.outExpo } )
            transition.to( grpLogin, { y = -150, time = 400, transition = easing.outExpo } )
        end
    elseif ( "submitted" == event.phase ) then
        getUser()
    end
end

function getReturnButtons()
    if not (grpLogin.y == 0) then
		native.setKeyboardFocus(nil)
        transition.to( imgLogo, { y = midY / 2, xScale=1, yScale=1, time = 400, transition = easing.outExpo } )
        transition.to( grpLogin, { y = 0, time = 400, transition = easing.outExpo } )
    end
end

function getCouponBook()
	system.openURL( "http://thesavingcoupon.com/movil" )
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

function urlencode(str)
	  if (str) then
		  str = string.gsub (str, "\n", "\r\n")
		  str = string.gsub (str, "([^%w ])",
		  function ( c ) return string.format ("%%%02X", string.byte( c )) end)
		  str = string.gsub (str, " ", "%%20")
	  end
	  return str    
end

function getUser()
	showMask(true)
    local settings = DBManager.getSettings()
    -- Set url
    local url = urlApi.."api/verifyuser/format/json"
    url = url.."/user/"..urlencode(txtEmail.text)
	url = url.."/pass/"..txtPass.text

    local function callback(event)
        if ( event.isError ) then
        else
            local data = json.decode(event.response)
			if data.success then
				DBManager.updateUser(data.idCliente, data.idTipoCupon)
            	getReturnButtons()
				goToHome()
			else
				showMask(false)
				native.showAlert( "TSC", data.message, { "OK"})
			end
        end
        return true
    end

    -- Do request
    network.request( url, "GET", callback ) 
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
    
    txtEmail = native.newTextField( midX, midY - 30, 380, 40 )
    txtEmail.inputType = "email"
    txtEmail.hasBackground = false
    txtEmail.placeholder = "your@email.com"
    txtEmail:addEventListener( "userInput", onTxtFocus )
	grpLogin:insert(txtEmail)
    
    txtPass = native.newTextField( midX, midY + 35, 380, 40 )
    txtPass.isSecure = true
    txtPass.hasBackground = false
    txtPass.placeholder = "password"
    txtPass:addEventListener( "userInput", onTxtFocus )
	grpLogin:insert(txtPass)
    
    local btnLogin = display.newRoundedRect( midX, midY + 120, 400, 65, 10 )
    btnLogin:setFillColor( 70/255, 130/255, 180/255 ) 
	btnLogin.stroke = { .8 }
	btnLogin.strokeWidth = 2
    btnLogin:addEventListener( "tap", getUser )
    grpLogin:insert(btnLogin)
    
    local txtLogin = display.newText( "Log In", midX + 40, midY + 125, 150, 45, "OpenSans-ExtraBold", 28)
    txtLogin:setFillColor( 1 )
    grpLogin:insert(txtLogin)
	
	local bgLink = display.newRect(  midX, midY + 210, 220, 60 )
	bgLink:setFillColor( .5 )
	bgLink.alpha = .01
    bgLink:addEventListener( "tap", getCouponBook )
	grpLogin:insert( bgLink )
	
	local txtGetTSC = display.newText( "NOT A MEMBER CLICK HERE", midX + 30, midY + 200, 250, 22, "OpenSans-ExtraBold", 18)
    txtGetTSC:setFillColor( 1 )
    grpLogin:insert(txtGetTSC)
	
	local lineLink = display.newRect(  midX, midY + 220, 220, 1 )
	lineLink:setFillColor( .3 )
	grpLogin:insert( lineLink )
    
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
	storyboard.removeAll()
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
        getReturnButtons()
        return true
    end
end
Runtime:addEventListener( "key", onKeyEvent )

scene:addEventListener("createScene", scene )
scene:addEventListener("enterScene", scene )
scene:addEventListener("exitScene", scene )

return scene

