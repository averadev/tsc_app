--Include sqlite
local dbManager = {}

	require "sqlite3"
	local path, db

	--Open rackem.db.  If the file doesn't exist it will be created
	local function openConnection( )
	    path = system.pathForFile("tsc.db", system.DocumentsDirectory)
	    db = sqlite3.open( path )     
	end

	local function closeConnection( )
		if db and db:isopen() then
			db:close()
		end     
	end
	 
	--Handle the applicationExit event to close the db
	local function onSystemEvent( event )
	    if( event.type == "applicationExit" ) then              
	        closeConnection()
	    end
	end

	--Setup squema if it doesn't exist
	dbManager.setupSquema = function()
		openConnection( )
		
		local query = "CREATE TABLE IF NOT EXISTS config (id INTEGER PRIMARY KEY, type INTEGER, loaded INTEGER);"
		db:exec( query )

        -- Return if have connection
		for row in db:nrows("SELECT id FROM config;") do
            closeConnection( )
            if row.id == 0 then
                return false
            else
                return true
            end
		end
    
        local query = "CREATE TABLE IF NOT EXISTS cupon (id INTEGER PRIMARY KEY, url TEXT, descripcion TEXT, fechaInicio TEXT, fechaFin TEXT, idComercio INTEGER, code TEXT, terminosCondiciones TEXT, redimido INTEGER);"
		db:exec( query )
    
        local query = "CREATE TABLE IF NOT EXISTS comercio (id INTEGER PRIMARY KEY, nombre TEXT, telefono TEXT, direccion TEXT, servicios TEXT, latitud TEXT, longitud TEXT);"
		db:exec( query )
    
        local query = "CREATE TABLE IF NOT EXISTS categoria (id INTEGER PRIMARY KEY, nombre TEXT);"
		db:exec( query )
    
        local query = "CREATE TABLE IF NOT EXISTS xrefComerCat (idComercio INTEGER, idIndustria INTEGER);"
		db:exec( query )
        
        -- Populate config
        query = "INSERT INTO config VALUES (0, 0, 0);"
		db:exec( query )
		closeConnection( )
    
        return false
	end

    dbManager.isLoaded = function()
		openConnection( )
		for row in db:nrows("SELECT loaded FROM config;") do
            closeConnection( )
            if row.loaded == 0 then
                return false
            else
                return true
            end
		end
		closeConnection( )
		return false
	end

	dbManager.getSettings = function()
		local result = {}
		openConnection( )
		for row in db:nrows("SELECT * FROM config;") do
			closeConnection( )
			return  row
		end
		closeConnection( )
		return 1
	end

    dbManager.updateUser = function(id, tipo)
		openConnection( )
        local query = ''
        query = "UPDATE config SET loaded = 0, id = "..id ..", type="..tipo
        db:exec( query )
		closeConnection( )
	end

    dbManager.updateLoaded = function(status)
		openConnection( )
        local query = ''
        query = "UPDATE config SET loaded = "..status
        db:exec( query )
		closeConnection( )
	end

    dbManager.isCoupons = function()
		local result = {}
		openConnection( )
		for row in db:nrows("SELECT * FROM cupon;") do
			closeConnection( )
			return  true
		end
		closeConnection( )
		return false
	end

    dbManager.getComercios = function()
		local result, idx = {}, 1
		openConnection( )
		for row in db:nrows("SELECT * FROM comercio;") do
			result[idx] = row
			idx = idx + 1
		end
		closeConnection( )
		return result
	end

    dbManager.getCoupons = function()
		local result, idx = {}, 1
		openConnection( )
		for row in db:nrows("SELECT cupon.id, cupon.url, cupon.descripcion, cupon.code, cupon.terminosCondiciones, cupon.redimido, comercio.nombre,"
                            .." comercio.telefono, comercio.direccion FROM cupon join comercio on cupon.idComercio = comercio.id;") do
			result[idx] = row
			idx = idx + 1
		end
		closeConnection( )
		return result
	end

    dbManager.getCouponsByCat = function(id)
		local result, idx = {}, 1
		openConnection( )
		for row in db:nrows("select * from xrefComerCat"
                            .." join comercio on xrefComerCat.idComercio = comercio.id and xrefComerCat.idIndustria = "..id
                            .." join cupon on comercio.id = cupon.idComercio;") do
			result[idx] = row
			idx = idx + 1
		end
		closeConnection( )
		return result
	end



    dbManager.getCategories = function()
		local result, idx = {}, 1
		openConnection( )
		for row in db:nrows("SELECT id, nombre, "
                            .." (select count(cupon.id) from xrefComerCat "
                            .." join comercio on xrefComerCat.idComercio = comercio.id and xrefComerCat.idIndustria = categoria.id "
                            .." join cupon on comercio.id = cupon.idComercio) as total "
                            .." FROM categoria;") do
			result[idx] = row
			idx = idx + 1
		end
		closeConnection( )
		return result
	end

	dbManager.saveCupones = function(items)
		openConnection( )
    
        -- Delete all
        query = "DELETE FROM cupon;"
        db:exec( query )
    
        -- Save update
        for z = 1, #items, 1 do 
            query = "INSERT INTO cupon VALUES ("
                    ..items[z].id..",'"
                    ..items[z].url.."','"
                    ..items[z].descripcion.."','"
                    ..items[z].fechaInicio.."','"
                    ..items[z].fechaFin.."',"
                    ..items[z].idComercio..",'"
                    ..items[z].code.."','"
                    ..items[z].terminosCondiciones.."',"
					..items[z].redimido..");"
            db:exec( query )
        end
    
		closeConnection( )
		return 1
	end

	dbManager.saveComercios = function(items)
		openConnection( )
    
        -- Delete all
        query = "DELETE FROM comercio;"
        db:exec( query )
    
        -- Save update
        for z = 1, #items, 1 do 
            query = "INSERT INTO comercio VALUES ("
                    ..items[z].id..",'"
                    ..items[z].nombre.."','"
                    ..items[z].telefono.."','"
                    ..items[z].direccion.."','"
                    ..items[z].servicios.."','"
                    ..items[z].latitud.."','"
                    ..items[z].longitud.."');"
            db:exec( query )
        end
    
		closeConnection( )
		return 1
	end

	dbManager.saveCategorias = function(items)
		openConnection( )
    
        -- Delete all
        query = "DELETE FROM categoria;"
        db:exec( query )
    
        -- Save update
        for z = 1, #items, 1 do 
            query = "INSERT INTO categoria VALUES ("
                    ..items[z].id..",'"
                    ..items[z].nombre.."');"
            db:exec( query )
        end
    
		closeConnection( )
		return 1
	end

	dbManager.saveXrefComerCat = function(items)
		openConnection( )
    
        -- Delete all
        query = "DELETE FROM xrefComerCat;"
        db:exec( query )
    
        -- Save update
        for z = 1, #items, 1 do 
            query = "INSERT INTO xrefComerCat VALUES ("
                    ..items[z].idComercio..",'"
                    ..items[z].idIndustria.."');"
            db:exec( query )
        end
    
		closeConnection( )
		return 1
	end
	

	--setup the system listener to catch applicationExit
	Runtime:addEventListener( "system", onSystemEvent )
    

return dbManager