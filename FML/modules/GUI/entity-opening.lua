--/ GUI


return function(_M)
	local FML = therustyknife.FML
	local config = therustyknife.FML.config
	local table = therustyknife.FML.table
	local log = therustyknife.FML.log
	
	
	local local_handlers = table{open = table()}
	local global
	FML.events.on_load(function()
		global = table(FML.get_fml_global("GUI"))
		global:mk"handlers"
	end)
	
	-- Add the remote functions to the local module
	local GUI_remote = FML.remote.get_interface("therustyknife.FML.GUI")
	
	
	function _M.watch_opening(what, on_open)
	--- Watch an entity for gui opening.
	--* Open handlers are not save/load persistent - they have to be reregistered every load.
	--* If you want to handle the close event as well, return a handler name from the on_open function.
	--@ string what: The name of the entity to watch
	--@ function on_open: The function to be called when this entity is opened
	--: uint: The id of the added handler - used for removal
	--? handlers
		log.d("Watch: "..what)
		FML.remote.call_when_loaded(GUI_remote.watch_opening, what)
		local_handlers.open:mk(what)
		return local_handlers.open[what]:insert_at_next_index(on_open)
	end
	
	function _M.unwatch_opening(what, id)
	--- Stop watching an entity for gui opening.
	--* It's not recommended to use this as it's easy to cause desyncs with it.
	--@ string what: The name of the entity to stop watching
	--@ uint id: The id of the handler to remove (obtained when calling watch_opening)
		if not local_handlers.open[what] then return; end
		local_handlers.open[what][id] = nil
		
		--TODO: unwatch if no other handlers exist - Also wait until the remote implementation works as intended
	end
	
	--f close_gui
	--- Close any GUI of the given player.
	--@ uint player_index: Index of the player to close gui for
	_M.close_gui = GUI_remote.close_gui
	
	
	local function on_open(event)
		if local_handlers.open[event.entity.name] then
			local ret
			local_handlers.open[event.entity.name]:foreach(function(handler)
				local res, close_handler = handler(event)
				if res then
					event.status = config.MOD.NAME
					event.element = res or event.element
					ret = res
				end
				
				if close_handler then global.handlers[event.element] = close_handler; end
			end)
			return ret
		end
	end
	
	local function on_close(event)
		for elem, handler in pairs(global.handlers) do
			if elem == event.element then FML.handlers.call(handler, event); break; end
		end
	end
	
	remote.add_interface("therustyknife."..config.MOD.NAME..".FML.GUI", {
			on_open = on_open, on_close = on_close
		})
end
