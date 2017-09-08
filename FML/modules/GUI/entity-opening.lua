return function(_M)
	local FML = therustyknife.FML
	if FML.STAGE == "runtime" and FML.TYPE ~= "shared" then
		local config = FML.config
		local table = FML.table
		local log = FML.log
		
		
		local _DOC = _M._DOC.funcs
		
		
		local local_handlers = table{open = table()}
		local global
		FML.events.on_load(function()
			global = table(FML.get_fml_global("GUI"))
			global:mk"handlers"
		end)
		
		-- Add the remote functions to the local module
		local GUI_remote = FML.remote.get_interface("therustyknife.FML.GUI")
		
		_DOC.watch_opening = {
			desc = [[ Watch an entity for gui opening. ]],
			notes = {
				"Open handlers are not save/load persistent - they have to be reregistered every load.",
				"If you want to handle the close event as well, return a handler name from the on_open function (see [[handlers|handlers]]).",
			},
			params = {
				{
					type = "string",
					name = "what",
					desc = "The name of the entity to watch",
				},
				{
					type = "function",
					name = "on_open",
					desc = "The function to be called when this entity is opened",
				},
			},
			returns = {
				{
					type = "uint",
					desc = "The id of the added handler - used for removal",
				},
			},
		}
		function _M.watch_opening(what, on_open)
			log.d("Watch: "..what)
			FML.remote.call_when_loaded(GUI_remote.watch_opening, what)
			local_handlers.open:mk(what)
			return local_handlers.open[what]:insert_at_next_index(on_open)
		end
		
		_DOC.unwatch_opening = {
			desc = [[ Stop watching an entity for gui opening. ]],
			notes = {"It's not recommended to use this as it's easy to cause desyncs with it."},
			params = {
				{
					type = "string",
					name = "what",
					desc = "The name of the entity to stop watching",
				},
				{
					type = "uint",
					name = "id",
					desc = "The id of the handler to remove (obtained when calling watch_opening)",
				},
			},
		}
		function _M.unwatch_opening(what, id)
			if not local_handlers.open[what] then return; end
			local_handlers.open[what][id] = nil
			
			--TODO: unwatch if no other handlers exist - Also wait until the remote implementation works as intended
		end
		
		_DOC.close_gui = {
			desc = [[ Close any GUI of the given player. ]],
			params = {
				{
					type = "uint",
					name = "player_index",
					desc = "Index of the player to close gui for",
				},
			},
		}
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
end
