--/ events

return function(_M)
	local FML = therustyknife.FML
	local config = therustyknife.FML.config
	local table = therustyknife.FML.table
	local log = therustyknife.FML.log
	local FML_EVENT_ID = therustyknife.FML.FML_EVENT_ID
	
	
	local handlers = table()
	local custom_handlers = table()
	
	
	local function register_event(event_id)
		if not handlers[event_id] then
			local t_handlers = handlers:mk(event_id)
			t_handlers:numeric_indices(true)
			script.on_event(event_id, function(...)
				for _, handler in t_handlers:ipairs_all() do handler(...); end
			end)
		end
	end
	
	
	--TODO: permanent handlers, perhaps using the handler module if nothing else...
	function _M.on(event_id, handler)
	--- Add a handler for the given event.
	--* Events from defines can be registered simply using their name (i.e. `events.on_tick(function(event) ... end)`).
	--@ {AnyEventID, Array[AnyEventID]} event_id: The event(s) to register the handler for
	--@ function handler: The handler function
	--: Dictionary[AnyEventID, uint]: The id(s) of the handler for each particular events
		local id_type = _M.id.type(event_id)
		
		if not id_type and type(event_id) == "table" then
			local res = table()
			for _, id in pairs(event_id) do
				res[id] = _M.on(id, handler)
			end
			return res
		end
		
		if id_type == 'FML' then
			custom_handlers:mk(event_id.id):numeric_indices(true)
			return {
				type = 'FML',
				index = custom_handlers[event_id.id]:n_insert_at_next_index(handler),
			}
		else
			register_event(event_id)
			return {
				type = 'vanilla',
				index = handlers[event_id]:n_insert_at_next_index(handler),
			}
		end
	end
	
	function _M.info(info, overwrite)
	--- Add common event information to the given table.
	--- Currently added are:
	--- - `tick` - The tick the event occured on
	--- - `raised_by` - The name of the mod that raised the event
	--@ table info={}: The info to build upon
	--@ bool overwrite=false: If `true`, original values will be overwritten with the new ones
	--: table: The info table
		info = info or {}
		info.tick = (not overwrite and info.tick) or game.tick
		info.raised_by = (not overwrite and info.raised_by) or (config.MOD and config.MOD.NAME) or 'FML'
		return info
	end
	
	function _M.raise(event_id, ...)
	--- Raise the event given by event_id.
	--- This can be used the same as `script.raise_event`, except it also works with FML's custom events.
	--- 
	--- If event_id is an Array, all of the events will be raised in the order they are in the array, with the same
	--- parameters.  
	--- Only one parameter can be passed to a vanilla handler. See
	--- [Factorio API docs](http://lua-api.factorio.com/latest/LuaBootstrap.html#LuaBootstrap.raise_event) for details.
	--@ {AnyEventID, Array[AnyEventID]} event_id: The id of the event to raise, or an array of them
	--@ Any ...: Any parameters to be passed to the handlers - has to be serializable
		local id_type = _M.id.type(event_id)
		
		if not id_type and type(event_id) == 'table' then
			for _, id in pairs(event_id) do _M.raise(id, ...); end
			return
		end
		
		if id_type == 'FML' then
			script.raise_event(FML_EVENT_ID, {
				event_info = {event_id=event_id.id},
				args = {...},
			})
		else
			script.raise_event(event_id, ...)
		end
	end
	
	--TODO: add option to only remove from certain events
	--TODO: this probably doesn't work...
	function _M.remove_handler(handler_id)
	--- Remove the given handler.
	--@ Dictionary[AnyEventID, uint] handler_id: The handler to remove
		for event_id, e_handler_id in pairs(handler_id) do
			local id_type = _M.id.type(e)
			
			if id_type == 'FML' and custom_handlers[event_id.id] then
				custom_handlers[event_id.id]:n_remove(e_handler_id)
			elseif id_type ~= 'FML' and handlers[event_id] then
				handlers[event_id]:n_remove(e_handler_id)
			end
		end
	end
	
	--TODO: remove by function?
	
	-- Forward the custom events to their appropriate handlers
	_M.on(FML_EVENT_ID, function(event)
		if custom_handlers[event.event_info.event_id] then
			for _, handler in custom_handlers[event.event_info.event_id]:ipairs_all() do
				handler(table.unpack(event.args))
			end
		end
	end)
end
