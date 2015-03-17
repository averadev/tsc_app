---------------------------------------------------------------------------------
-- The Saving Coupon
-- Alberto Vera
-- GeekBucket Software Factory
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- REQUIRE & VARIABLES
---------------------------------------------------------------------------------
local storyboard = require( "storyboard" )
local json = require("json")
local DBManager = require('src.resources.DBManager')
local scene = storyboard.newScene()

-- Constants
local intX = display.contentWidth
local intY = display.contentHeight
local midX = display.contentCenterX
local midY = display.contentCenterY
local sbH = display.topStatusBarContentHeight

-- Vairables
local countTimer = 1
local cupones = {}
local txtInfo, timeDownloading

-- local urlApi = "http://localhost/thesavingcoupon/"
local urlApi = "http://thesavingcoupon.com/"

---------------------------------------------------------------------------------
-- FUNCTIONS
---------------------------------------------------------------------------------
function doneDownloading()
    DBManager.updateLoaded(1)
    storyboard.gotoScene( "src.Home", {time = 500, effect = "crossFade"})
end

function loadData()
    local settings = DBManager.getSettings()
    -- Set url
    local url = urlApi.."api/data/format/json"
    url = url.."/id/"..settings.id

    local function callback(event)
        if ( event.isError ) then
        else
            local data = json.decode(event.response)
            -- Guardar info
            DBManager.saveCupones(data.cupones)
            DBManager.saveComercios(data.comercios)
            DBManager.saveCategorias(data.categories)
            DBManager.saveXrefComerCat(data.xrefComerCat)
            -- Cargar imagenes
            cupones = data.cupones
            loadImage( 0 )
        end
        return true
    end

    -- Do request
    network.request( url, "GET", callback ) 
end

function loadImage( index )
    if index < #cupones then
        index = index + 1
        local name = cupones[index].url

        -- Obtener imagen
        local path = system.pathForFile( name, system.TemporaryDirectory )
        local fhd = io.open( path )
        if fhd then
            fhd:close()
            loadImage( index )
        else
            local function networkListener( event )
                -- Verificamos el callback activo
                if ( event.isError ) then
                else
                    event.target:removeSelf()
                    event.target = nil
                    loadImage( index )
                end
            end
            display.loadRemoteImage( urlApi.."assets/img/coupon/".. name, "GET", networkListener, name, system.TemporaryDirectory )
        end
    else
        doneDownloading()
    end
    
end



---------------------------------------------------------------------------------
-- TIMERS
---------------------------------------------------------------------------------
function moveElements()
    -- Change Text
    if countTimer == 0 then 
        txtInfo.text = "Downloading content"
    elseif countTimer == 1 then 
        txtInfo.text = "Downloading content."
    elseif countTimer == 2 then 
        txtInfo.text = "Downloading content.."
    elseif countTimer == 3 then 
        txtInfo.text = "Downloading content..."
    else
        txtInfo.text = "Downloading content...."
        countTimer = -1
    end
    
    -- Add to counter
    countTimer = countTimer + 1 
end

---------------------------------------------------------------------------------
-- OVERRIDING SCENES METHODS
---------------------------------------------------------------------------------
-- Called when the scene's view does not exist:
function scene:createScene( event )
    -- Agregamos el home
	local screen = self.view
    
    -- Creamos toolbar
    local bg = display.newRect( midX, midY, intX, intY )
    bg:setFillColor( .95 ) 
	screen:insert(bg)
    
    local bgIcon = display.newImage(screen, "img/bgkReload.png", true) 
    bgIcon.x = midX
	bgIcon.y = midY
    
    txtInfo = display.newText(screen, "Downloading content", midX + 30, midY + 170, 300, 38, "OpenSans-Regular", 20)
    txtInfo:setFillColor( .4 )
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    storyboard.removeAll()
    DBManager.updateLoaded(0)
    loadData()
    timeDownloading = timer.performWithDelay(500, moveElements, 0)
end

-- Remove Listener
function scene:exitScene( event )
    timer.cancel(timeDownloading)
end

scene:addEventListener("createScene", scene )
scene:addEventListener("enterScene", scene )
scene:addEventListener("exitScene", scene )

return scene

