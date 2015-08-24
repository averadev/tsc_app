Menu = {}

function Menu:new()
    
    -- Constants
    local intX = display.contentWidth
    local intY = display.contentHeight
    local midX = display.contentCenterX
    local midY = display.contentCenterY
    local sbH = display.topStatusBarContentHeight
    local posY, scrollMenu
    
    local widget = require( "widget" )
    local Sprites = require('src.resources.Sprites')
	local DBManager = require('src.resources.DBManager')
    local fxTap = audio.loadSound( "fx/click.wav")
    
    -- Variables
    local self = display.newGroup()
    local iconCat, grpCat, grpBottom
    local catList = {}
    local menuList = {
        {"All Coupons", "menuAll.png", "all"},
        {"Map", "menuMap.png", "map"},
        {"About Cozumel", "menuCozumel.png", "about"},
        {"Useful Phones", "menuDirectory.png", "phones"},
        {"SPACE"},
        {"Categories", "menuCategories.png", ""},
        {"SPACE"},
        {"Reload Coupons", "menuReload.png", "reload"},
        {"Close Session", "menuCloseSession.png", "close"}
    }
    
    
    function tapMenu(event)
        -- Animate bg
        local t = event.target
        t:setFillColor( .9 ) 
        timer.performWithDelay( 150, function() t:setFillColor( .95 ) end, 1 )
		
		-- Delete Map
		if not (t.opt == 'map') then
			verifyMap()
		end
        
        -- Do by menu
        if t.opt == 'all' then
            hideMenu()
            getCouponsBy(0)
        elseif t.opt == 'map' then
            hideMenu()
            getMap()
        elseif t.opt == 'about' then
            hideMenu()
            getAbout()
        elseif t.opt == 'phones' then
            hideMenu()
            getPhones()
        elseif t.opt == 'reload' then
            hideMenu()
            storyboard.gotoScene( "src.Reload", {time = 500, effect = "crossFade"})
        elseif t.opt == 'close' then
			hideMenu()
            DBManager.updateUser(0,0)
			storyboard.gotoScene( "src.Login", {delay = 500, time = 500, effect = "crossFade"})
        end
    end
    
    function tapCategorie(event)
        local t = event.target
        t:setFillColor( .9 ) 
        timer.performWithDelay( 150, function() t:setFillColor( .95 ) end, 1 )
        
        -- Get coupons
		verifyMap()
        hideMenu()
        getCouponsBy(t.id)
    end
    
    function tapCat(event)
        -- Animate bg
        event.target:setFillColor( .9 ) 
        timer.performWithDelay( 150, function() event.target:setFillColor( .95 ) end, 1 )
        
        -- Animate sprite
        if grpCat.alpha == 0 then
            iconCat:setSequence("open")
            iconCat:play()
            transition.to( grpCat, { alpha = 1, time = 400 } )
            transition.to( grpBottom, { y = 0, time = 400 } )
            -- Set new scroll position
            scrollMenu:setScrollHeight(posY)
        else
            iconCat:setSequence("close")
            iconCat:play()
            transition.to( grpCat, { alpha = 0, time = 400 } )
            transition.to( grpBottom, { y = #catList * (-60), time = 400 } )
            -- Set new scroll position
            scrollMenu:setScrollHeight(630)
        end 
        
    end
    
    -- Creamos la pantalla del menu
    function self:builScreen(categories)
        
        -- Generales
        self.x = -400
        posY = sbH
        catList = categories
        
        scrollMenu = widget.newScrollView
        {
            left = 0,
            top = 0,
            width = 400,
            height = intY,
            horizontalScrollDisabled = true,
            verticalScrollDisabled = false,
            backgroundColor = { .95 }
        }
        self:insert(scrollMenu)
        
        -- Grupos
        grpCat = display.newGroup()
        scrollMenu:insert(grpCat)
        grpBottom = display.newGroup()
        scrollMenu:insert(grpBottom)
        
        local barTmp1 = display.newRect(200, 0, 400, posY + 40 )
        barTmp1.anchorY = 0;
        barTmp1:setFillColor( .8 ) 
        scrollMenu:insert(barTmp1)
        posY = posY + 40
        
        -- Opciones del menu
        for z = 1, #menuList, 1 do 
            local line = display.newRect( 200, posY - 1, 400, 1 )
            line.anchorY = 0;
            line:setFillColor( .9 ) 
            if z > 6 then grpBottom:insert(line)
            else scrollMenu:insert(line) end
            
            if menuList[z][1] == "SPACE" then
                local item = display.newRect( 200, posY, 400, 50 )
                item.anchorY = 0;
                item:setFillColor( .8 ) 
                if z > 6 then grpBottom:insert(item)
                else scrollMenu:insert(item) end
                
                posY = posY + 50
            elseif menuList[z][1] == "Categories" then
                local item = display.newRect( 200, posY, 400, 60 )
                item.anchorY = 0;
                item:setFillColor( .95 ) 
                item:addEventListener( "tap", tapCat )
                scrollMenu:insert(item)
                
                local sheet = graphics.newImageSheet(Sprites.menuCat.source, Sprites.menuCat.frames)
                iconCat = display.newSprite(sheet, Sprites.menuCat.sequences)
                iconCat.x, iconCat.y = 55, posY + 30 
                scrollMenu:insert(iconCat)
                
                local text = display.newText( menuList[z][1], 200, posY + 33, 200, 22, "OpenSans-Regular", 16 )
                text:setFillColor( .4 )
                scrollMenu:insert(text)
                
                posY = posY + 60
                
                local lineB = display.newRect( 200, posY - 1, 400, 1 )
                lineB.anchorY = 0;
                lineB:setFillColor( .9 ) 
                scrollMenu:insert(lineB)
                
                 -- Categorias
                for y = 1, #catList, 1 do 
                    
                    local line = display.newRect( 200, posY - 1, 400, 1 )
                    line.anchorY = 0;
                    line:setFillColor( .9 ) 
                    grpCat:insert(line)
                    
                    local itemCat = display.newRect( 200, posY, 400, 60 )
                    itemCat.id = catList[y].id
                    itemCat.anchorY = 0;
                    itemCat:setFillColor( .95 ) 
                    itemCat:addEventListener( "tap", tapCategorie )
                    grpCat:insert(itemCat)
                    
                    local textCat = display.newText( catList[y].nombre, 220, posY + 33, 200, 22, "OpenSans-Regular", 16 )
                    textCat:setFillColor( .4 )
                    grpCat:insert(textCat)
                    
                    local bgCount = display.newRoundedRect( 357, posY + 31, 26, 26, 4 )
                    bgCount:setFillColor( .9 ) 
                    grpCat:insert(bgCount)
                    
                    local textCount = display.newText( catList[y].total, 360, posY + 33, 22, 22, "OpenSans-Regular", 16 )
                    textCount:setFillColor( .4 )
                    grpCat:insert(textCount)
                    if catList[y].total < 10 then
                        textCount.x = 363
                    end
                    
                    
                    posY = posY + 60
                    
                end
            else
                local item = display.newRect( 200, posY, 400, 60 )
                item.anchorY = 0;
                item:setFillColor( .95 ) 
                item.opt = menuList[z][3]
                item:addEventListener( "tap", tapMenu )
                if z > 6 then grpBottom:insert(item)
                else scrollMenu:insert(item) end
                
                local icon = display.newImage( "img/"..menuList[z][2], true )  
                icon.x, icon.y = 55, posY + 30
                if z > 6 then grpBottom:insert(icon)
                else scrollMenu:insert(icon) end
                
                local text = display.newText( menuList[z][1], 200, posY + 33, 200, 22, "OpenSans-Regular", 16 )
                text:setFillColor( .4 )
                if z > 6 then grpBottom:insert(text)
                else scrollMenu:insert(text) end
                
                posY = posY + 60
            end
        end
        
        -- Set new scroll position
        scrollMenu:setScrollHeight(630)
        
        -- Close Categories
        grpCat.alpha = 0
        grpBottom.y = #catList * (-60)
        
        -- Border Right
        local borderRight = display.newRect( 398, midY, 4, intY )
        borderRight:setFillColor( {
            type = 'gradient',
            color1 = { .1, .1, .1, .7 }, 
            color2 = { .4, .4, .4, .2 },
            direction = "left"
        } ) 
        borderRight:setFillColor( 0, 0, 0 ) 
        self:insert(borderRight)
        
    end

    return self
end