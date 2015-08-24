---------------------------------------------------------------------------------
-- The Saving Coupon
-- Alberto Vera
-- GeekBucket Software Factory
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- REQUIRE & VARIABLES
---------------------------------------------------------------------------------
local storyboard = require( "storyboard" )
local widget = require( "widget" )
local json = require("json")
local DBManager = require('src.resources.DBManager')
local scene = storyboard.newScene()

-- Menu Object
require('src.Menu')
local menuScreen = Menu:new()
local homeScreen = display.newGroup()

-- Constants
local intX = display.contentWidth
local intY = display.contentHeight
local midX = display.contentCenterX
local midY = display.contentCenterY
local sbH = display.topStatusBarContentHeight

-- Variables
local scrollView, bgShapeMenu, mask, myMap
local btnMenu, btnBack
local items = {}
local cupones = {}
local lastY = 220
local isHome, isLocation = true, false

-- Arrays
local txtPhones = { 
	{"The Saving Coupon", ""},
	{"Office", "987-869-0697"},
	{"Whatsapp", "+52 (987) 117-1172"},
    {"Emergencies", ""},
    {"Emergencies", "066"},
    {"Police", "987-872-0409"},
    {"Fire Fighters", "987-872-0800"},
    {"Red Cross", "987-872-9400"},
    {"Ferry", ""},
    {"Mexico Water Jets", "987-872-1508"},
    {"Ultramar", "987-869-3232"},
    {"Transport", ""},
    {"Airport", "987-872-2081"},
    {"Taxi", "987-872-0041"},
    {"Migration & Consulates", ""},
    {"Migration Office", "987-872-0071"},
    {"USA Consulate", "987-872-4574"},
    {"Canada Consulate", "984-803-2411"},
}
local txtAbout = { 
    "Native Mayans first established Cozumel as a ceremonial center and commercial port for trade. Today it still continues to be an important haven for ships, welcoming passengers from the most popular cruise lines as Mexico’s most popular port-of-call. One-day cruise ship visitors will discover island traditions, natural wonders and San Miguel, Cozumel’s only town.",
    "San Miguel offers an extensive selection of restaurants, cafes, boutiques and colorful shops selling unique souvenirs and traditional Mayan handicrafts. Take a leisurely seaside stroll along the charming malecón (boardwalk) that is full of with sculptures and monuments. Despite being the main tourist destination of Cozumel, San Miguel still retains a sense of laid-back tranquility.",
    "Cozumel is also renowned for its incredible snorkeling and diving due to the sea’s remarkable clarity. Whether you are a pro-diver or a first-time snorkeler, the island is sprinkled with accessible sites for underwater exploration over one of the world’s largest reef systems that teems with tropical fish and marine life.",
    "After Jacques Cousteau declared Cozumel to be of the most spectacular diving sites in the world in 1961, people from every corner of the planet now come to discover this underwater Caribbean biosphere.",
    "Several ecological parks, such as Chankanaab and Faro Celerain (Punta Sur), offer the most popular snorkel and dive sites for all levels. More activities for adventuresome sightseers include jungle trails, lush botanical gardens, enchanting lagoons, delightful dolphin encounter programs and sea turtle sanctuaries.",
    "If you’d prefer to escape the tourist areas, no worries, because on this small 48-km (30-mile) by 16-km (10-mile) island, roughly only six percent is actually developed, leaving a jungle-like interior and deserted beaches for rest and relaxation. Although it’s only 35 minutes from the Riviera Maya mainland, Cozumel provides blissful isolation if you wish.",
    "Whether you’re in search of extreme adventures or some peaceful beach time, Cozumel might just your ideal vacation island." 
}


---------------------------------------------------------------------------------
-- FUNCTIONS
---------------------------------------------------------------------------------

-- Mostrar Menu
function showMenu(event)
    if mask.alpha == 0 then
        isHome = false
        transition.to( homeScreen, { x = homeScreen.x + 400, time = 400, transition = easing.outExpo } )
        transition.to( menuScreen, { x = menuScreen.x + 400, time = 400, transition = easing.outExpo } )
        transition.to( mask, { alpha = .5, time = 400, transition = easing.outQuad } )
    end
end

function hideMenu(event)
    if isHome == false then
        isBreak = true
        transition.to( homeScreen, { x = 0, time = 400, transition = easing.outExpo } )
        transition.to( menuScreen, { x = - 400, time = 400, transition = easing.outExpo } )
        transition.to( mask, { alpha = 0, time = 400, transition = easing.outQuad } )
        timer.performWithDelay( 500, function()
            isHome = true
            isBreak = false
        end, 1 )
    end
end

function cleanItems()
    for z = 1, #items, 1 do 
        items[z]:removeSelf()
        items[z] = nil
    end
    items = {}
    lastY = 220
    -- Set scroll Top
    scrollView:setIsLocked(false)
    scrollView:scrollToPosition( { y = 0 } )
end

function getCouponsBy(id)
    cupones = {}
    if id == 0 then
        cupones = DBManager.getCoupons()
    else
        cupones = DBManager.getCouponsByCat(id)
    end
    scrollView.alpha = 0
    transition.to( scrollView, { alpha = 1, time = 300, delay = 300 } )
    showAll()
end

function verifyMap()
	if myMap then
        myMap:removeSelf()
        myMap = nil
    end
end


local locationHandler = function( event )
	-- Check for error (user may have turned off Location Services)
	if isLocation and myMap then
        isLocation = false
        Runtime:removeEventListener( "location", locationHandler )
        
        -- Set new location
        myMap:setRegion( event.latitude, event.longitude, 0.03, 0.03, true )
        
        -- Comercios
        cupones = DBManager.getComercios()
        for z = 1, #cupones, 1 do 
            -- Options
            local options = { 
                title = cupones[z].nombre, 
                subtitle = cupones[z].servicios, 
                listener = markerListener, 
                imageFile = "img/btnIconMap.png"
            }
            -- Add Maker
            print(cupones[z].nombre)
            myMap:addMarker( tonumber(cupones[z].latitud), tonumber(cupones[z].longitud), options )
        end
    else
        Runtime:removeEventListener( "location", locationHandler )
	end
end

function getMap()
    cleanItems()
    scrollView:setIsLocked(true)
    
    -- Mapa
    local hMap = intY - (65 + sbH)
    myMap = native.newMapView( midX, hMap / 2, intX, hMap )
	if myMap then
		myMap:setCenter( 20.511816, -86.938778, .2, .2 )
		scrollView:insert(myMap)

		isLocation = true
		Runtime:addEventListener( "location", locationHandler )
	end
end

function printTable(table, stringPrefix)
	if not stringPrefix then
		stringPrefix = "### "
	end
	if type(table) == "table" then
		for key, value in pairs(table) do
			if type(value) == "table" then
				print(stringPrefix .. tostring(key))
				print(stringPrefix .. "{")
				printTable(value, stringPrefix .. "   ")
				print(stringPrefix .. "}")
			else
				print(stringPrefix .. tostring(key) .. ": " .. tostring(value))
			end
		end
	end
end

function getAbout()
    scrollView.alpha = 0
    cleanItems()
    items[1] = display.newGroup()
    scrollView:insert(items[1])
    
    local imageDesc = display.newImage("img/about/0.jpg", true )
    imageDesc.anchorY = 0;
    imageDesc.x, imageDesc.y = 240, 0
    items[1]:insert(imageDesc)
    local aboutY = 160
	
	-- Obtener el clima
	local netConn = require('socket').connect('www.google.com', 80)
    if not (netConn == nil) then
		print ("internet") 
        local function callWeather(event)
			local data = json.decode(event.response)
			if data and data.currently then
				local imgIcon = display.newImage( "img/weather/"..data.currently.icon..".png" )
				if imgIcon then
    				items[1]:insert(imgIcon)
					imgIcon:translate( intX / 4, 180 )
				end
				local txtWeather = display.newText(data.currently.summary, intX / 4, 220, "OpenSans-Regular", 18)
				txtWeather:setFillColor( 0 )
				items[1]:insert(txtWeather)
				
				local offTime = data.offset * 3600
				local unixTime = data.currently.time + offTime
				print("unixTime: "..unixTime)
				print(os.date("%H:%M %S %z, %Z ", data.currently.time))
				
			end
			return true
		end
		local function callTime(event)
			local xml = event.response
			local posc1 = string.find(xml, "localtime")
			local posc2 = string.find(xml, "/localtime")
			
			if posc1 > 0 then
				local timetxt =  string.sub(xml, posc1 + 10, posc2 -2)
				
				local txtWeather = display.newText(timetxt, intX / 5 + midX, 185, "OpenSans-Regular", 16)
				txtWeather:setFillColor( 0 )
				items[1]:insert(txtWeather)
				local txtWeather = display.newText("Local Time", intX / 5 + midX, 220, "OpenSans-Regular", 18)
				txtWeather:setFillColor( 0 )
				items[1]:insert(txtWeather)
				
			end
			return true
		end
		-- Do request
		network.request( "https://api.forecast.io/forecast/999f1dab42b2fcff45367eefd1a89865/20.25,-86.55", "GET", callWeather )
		network.request( "http://www.earthtools.org/timezone-1.1/4.28/-74.22", "GET", callTime )
		aboutY = 260
    end
	
    
    for z = 1, #txtAbout, 1 do 
        local txtDesc = display.newText(txtAbout[z], 230, aboutY, 400, 0, "OpenSans-Regular", 16)
        txtDesc:setFillColor( .4 )
        txtDesc.anchorY = 0;
        items[1]:insert(txtDesc)
        -- Increase Y
        aboutY = aboutY + txtDesc.contentHeight + 30
        --Add images
        if z == 2 or z == 4 or z == 6 then
            local imageDesc = display.newImage("img/about/"..z..".jpg", true )
            imageDesc.anchorY = 0;
            imageDesc.x, imageDesc.y = 225, aboutY
            items[1]:insert(imageDesc)
            -- Increase Y
            if z == 4 then
                aboutY = aboutY + 210
            else
                aboutY = aboutY + 290
            end
        end
    end
	scrollView:setScrollHeight(aboutY)
    transition.to( scrollView, { alpha = 1, time = 300, delay = 300 } )
end

function getPhones()
    scrollView.alpha = 0
    cleanItems()
    items[1] = display.newGroup()
    scrollView:insert(items[1])
    
    local phonesY = 0
    -- Phones
    for z = 1, #txtPhones, 1 do 
        if txtPhones[z][2] == "" then
            local bg = display.newRect(midX, phonesY, intX, 50 )
            bg.anchorY = 0;
            bg:setFillColor( .4 ) 
            items[1]:insert(bg)
            
            -- Textos
            local txtDesc = display.newText(txtPhones[z][1], 170, phonesY + 15, 250, 0, "OpenSans-Regular", 20)
            txtDesc:setFillColor( 1 )
            txtDesc.anchorY = 0;
            items[1]:insert(txtDesc)

            -- Increase Y
            phonesY = phonesY + 50
        else
            local line = display.newRect( midX, phonesY, intX, 1 )
            line.anchorY = 0;
            line:setFillColor( .9 ) 
            items[1]:insert(line)

            -- Icon
            local imageIcon = display.newImage("img/iconPhoneList.png", true )
            imageIcon.x, imageIcon.y = 60, phonesY + 35
            imageIcon.alpha = .6
            items[1]:insert(imageIcon)

            -- Textos
            local txtDesc = display.newText(txtPhones[z][1], 230, phonesY + 15, 250, 0, "OpenSans-Regular", 20)
            txtDesc:setFillColor( .4 )
            txtDesc.anchorY = 0;
            items[1]:insert(txtDesc)
            local txtPhone = display.newText(txtPhones[z][2], 230, phonesY + 40, 250, 0, "OpenSans-Regular", 16)
            txtPhone:setFillColor( .4 )
            txtPhone.anchorY = 0;
            txtPhone:addEventListener( "tap", callPhone )
            items[1]:insert(txtPhone)

            -- Increase Y
            phonesY = phonesY + 70
        end
    end
    scrollView:setScrollHeight(phonesY)
    transition.to( scrollView, { alpha = 1, time = 300, delay = 300 } )
end

function showAll()
    cleanItems()
    for z = 1, #cupones, 1 do 
        addCoupon(cupones[z])
    end
	scrollView:setScrollHeight(lastY - 200)
end

function showScroll(event)
    -- Transition ScrollView
    transition.to( scrollView, { alpha = 0, time = 300, onComplete= function() showAll()  end } )
    transition.to( scrollView, { alpha = 1, time = 300, delay = 300 } )
    
    -- Transition Buttons
    transition.to( btnBack, { alpha = 0, time = 300 } )
    transition.to( btnMenu, { alpha = 1, time = 300, delay = 300 } )
end

function showCoupon(event)
    -- Transition ScrollView
    transition.to( scrollView, { alpha = 0, time = 300, onComplete= function() cleanItems() addDetail(event.target.index)  end } )
    transition.to( scrollView, { alpha = 1, time = 300, delay = 300 } )
    
    -- Transition Buttons
    transition.to( btnMenu, { alpha = 0, time = 300 } )
    transition.to( btnBack, { alpha = 1, time = 300, delay = 300 } )
end

function callPhone(event)
    system.openURL( "tel:"..event.target.text )
end

-- Cargamos por menu
function addCoupon(item) 
    
    -- Create Container
    local index = #items + 1
    items[index] = display.newContainer(scrollView, intX, 450 )
    items[index].x = midX
    items[index].y = lastY
    scrollView:insert(items[index])
    
    -- Agregamos bg
    local bgShape = display.newRect(items[index], 0, 0, 452, 392 )
    bgShape:setFillColor( .8 )
    
    -- Agregamos bgTop
    local bgShapeTop = display.newRect(items[index], 0, -150, 450, 90 )
    bgShapeTop:setFillColor( 1 )
    
    local path = system.pathForFile( item.url, system.TemporaryDirectory )
    local fhd = io.open( path )
    if fhd then
        local image = display.newImage(items[index], item.url, system.TemporaryDirectory )
        image.x, image.y = 0, 45
        image.width = 450
        image.height  = 300
    else
        
    end
    -- Texto
    local txtComer = display.newText(items[index], item.nombre, -50, -160, 310, 30, "OpenSans-Regular", 25)
    txtComer:setFillColor( .2 )
    local txtDesc = display.newText(items[index], item.descripcion, -50, -130, 310, 25, "OpenSans-Regular", 16)
    txtDesc:setFillColor( .2 )
    
    local imageN = display.newImage(items[index], "img/btnNext.png", true )
    imageN.index = index
    imageN.x, imageN.y = 180, -150
    imageN:addEventListener( "tap", showCoupon )
    
    -- Agregar espacio
    lastY = lastY + 430
end

function addDetail(index)
    -- Create Container
    local item = cupones[index]
    items[1] = display.newGroup()
    scrollView:insert(items[1])
    
    -- Agregamos bg
    local bgShape = display.newRect(items[1], midX, 330, 452, 600 )
    bgShape:setFillColor( .8 )
    -- Agregamos bgWhite
    local bgShapeWhite = display.newRect(items[1], midX, 330, 450, 598 )
    bgShapeWhite:setFillColor( 1 )
    
    -- Nav
    if index > 1 then
        local imageP = display.newImage(items[1], "img/btnPrevC.png", true )
        imageP.index = index - 1
        imageP.x, imageP.y = 40, 70
        imageP:addEventListener( "tap", showCoupon )
    end
    if index < #cupones then
            local imageN = display.newImage(items[1], "img/btnNextC.png", true )
            imageN.index = index + 1
            imageN.x, imageN.y = 440, 75
            imageN:addEventListener( "tap", showCoupon )
    end
    
    local path = system.pathForFile( item.url, system.TemporaryDirectory )
    local fhd = io.open( path )
    if fhd then
        local image = display.newImage(items[1], item.url, system.TemporaryDirectory )
        image.x, image.y = midX, 270
        image.width = 450
        image.height  = 300
    else
        
    end
    
    -- Iconos
    local iconPhone = display.newImage(items[1], "img/iconPhone.png", true )
    iconPhone.x, iconPhone.y = 50, 520
    local iconLocation = display.newImage(items[1], "img/iconLocation.png", true )
    iconLocation.x, iconLocation.y = 50, 580
    
    -- Texto
    local txtComer = display.newText(items[1], item.nombre, midX, 65, "OpenSans-Regular", 25)
    txtComer:setFillColor( .2 )
    local txtDesc = display.newText(items[1], item.descripcion, midX, 90,  "OpenSans-Regular", 16)
    txtDesc:setFillColor( .2 )
    
	if item.redimido == 1 then
		local txtCode0 = display.newText(items[1], "Code: "..item.code, midX, 455,  "OpenSans-Semibold", 30)
		txtCode0:setFillColor( .2 )
		local underline = display.newLine(items[1], midX - 150, 475, midX + 150, 475 )
		underline:setStrokeColor( .2)
		underline.strokeWidth = 2
	else
		local txtCode = display.newText(items[1], "This coupon was redeemed.", midX, 455,  "OpenSans-Semibold", 30)
		txtCode:setFillColor( 1, .65, .65 )
	end
    
    local txtTelefono = display.newText(items[1], item.telefono, midX + 20, 520, 370, 22,  "OpenSans-Semibold", 18)
    txtTelefono:setFillColor( .4 )
    txtTelefono:addEventListener( "tap", callPhone )
    local txtDireccion = display.newText(items[1], item.direccion, midX + 20, 580, 370, 44,  "OpenSans-Semibold", 18)
    txtDireccion:setFillColor( .4 )
    
    -- Agregamos bg
    local bgShapeT = display.newRect(items[1], midX, 725, 452, 150 )
    bgShapeT:setFillColor( .8 )
    -- Agregamos bgWhite
    local bgShapeTWhite = display.newRect(items[1], midX, 725, 450, 148 )
    bgShapeTWhite:setFillColor( 1 )
    -- Terminos y Condiciones
    local txtTitleTerm = display.newText(items[1], "Terms and Conditions: ", midX, 680, 420, 22,  "OpenSans-Semibold", 20)
    txtTitleTerm:setFillColor( .4 )
    local txtTerminos = display.newText(items[1], item.terminosCondiciones, midX, 740, 420, 0,  "OpenSans-Semibold", 16)
    txtTerminos:setFillColor( .4 )
    
    -- Reposicionar
    local termH = txtTerminos.contentHeight
    txtTerminos.height = txtTerminos.contentHeight
    txtTerminos.y = 700 + (termH / 2)
    bgShapeT.height = termH + 60
    bgShapeTWhite.height = termH + 58
    bgShapeT.y = 690 + (termH / 2)
    bgShapeTWhite.y = 690 + (termH / 2)
	
	-- Margin Fix
    local bgShapeTWhite = display.newRect(items[1], midX, 770 + termH, 1, 1 )
    bgShapeTWhite:setFillColor( .95 )
	
	scrollView:setScrollHeight(750 + termH)
end

---------------------------------------------------------------------------------
-- OVERRIDING SCENES METHODS
---------------------------------------------------------------------------------
-- Called when the scene's view does not exist:
function scene:createScene( event )
    -- Agregamos el home
	self.view:insert(homeScreen)
    
    local bg = display.newRect( midX, midY, intX, intY )
    bg:setFillColor( .95 ) 
	homeScreen:insert(bg)
    
    scrollView = widget.newScrollView
    {
        left = 0,
        top = 65 + sbH,
        width = intX + 5,
        height = intY - (65 + sbH),
        horizontalScrollDisabled = true,
        verticalScrollDisabled = false,
        backgroundColor = { .95 }
    }
    homeScreen:insert(scrollView)
    
    -- Creamos toolbar
    local titleBar = display.newRect( midX, 0, intY, 65 + sbH )
    titleBar.anchorY = 0;
    titleBar:setFillColor( .85 ) 
	homeScreen:insert(titleBar)
    
    local lineBar = display.newRect( midX, 62 + sbH, intY, 2 )
    lineBar.anchorY = 0;
    lineBar:setFillColor( .7 ) 
	homeScreen:insert(lineBar)
    
    btnMenu = display.newImage(homeScreen, "img/btnMenu.png", true) 
    btnMenu.x = 40
	btnMenu.y = sbH + 35
    btnMenu:addEventListener( "tap", showMenu )
    
    btnBack = display.newImage(homeScreen, "img/btnPrev.png", true) 
    btnBack.x = 40
	btnBack.y = sbH + 35
    btnBack.alpha = 0
    btnBack:addEventListener( "tap", showScroll )
    
    local imgLogo = display.newImage(homeScreen, "img/logo.png", true) 
    imgLogo.x = intX - 50
	imgLogo.y = sbH + 35
    imgLogo.alpha = .5
    
    -- Load menu
    menuScreen:builScreen(DBManager.getCategories())
    
    -- Creamos la mascara
    mask = display.newRect( midX, midY, intX, intY )
    mask:setFillColor( 0, 0, 0)
    mask.alpha = 0
    homeScreen:insert(mask)
    mask:addEventListener( "tap", hideMenu )
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    getCouponsBy(0)
end

-- Remove Listener
function scene:exitScene( event )
end

scene:addEventListener("createScene", scene )
scene:addEventListener("enterScene", scene )
scene:addEventListener("exitScene", scene )

return scene

