return function(_M)
	local FML = therustyknife.FML
	if FML.TYPE == "shared" then
		local config = FML.config
		local table = FML.table
		local log = FML.log
		
		
		-- GUI opening mechanics
		local interfaces
		local watched_names = table()
		
		local global
		FML.events.on_load(function()
			global = table(FML.get_fml_global("GUI"))
			global:mk"open_guis" --TODO: use this to figure out if the player has a gui or not
		end)
		
		
		local function init_interfaces()
			if not interfaces then
				interfaces = table()
				for mod, version in pairs(table.merge(game.active_mods, {console = config.VERSION.NAME})) do
					local interface_name = "therustyknife."..mod..".FML.GUI"
					if remote.interfaces[interface_name] then
						interfaces[mod] = FML.remote.get_interface(interface_name)
					end
				end
				log.dump("Initialized interfaces: ", interfaces:indices())
			end
		end
		
		
		local function block_gui(player)
			---[[ LEGACY
			if player.selected then
				if player.selected.operable then
					global.post_open = table(global.post_open) -- make sure the table exists
					global.post_open:insert(player.selected)
				end
				player.selected.operable = false
			end
			--]]
			--[[ HOPEFULLY WILL WORK SOON
			player.opened = defines.gui_type.none
			--]]
		end
		
		
		function _M.watch_opening(what)
			if type(what) == "table" then for _, e in pairs(what) do _M.watch_opening(e); end
			else watched_names[what] = true; end
		end
		
		--TODO: check if other mods are watching before unwathing
		function _M.unwatch_opening(what)
			if type(what) == "table" then for _, e in pairs(what) do _M.unwatch_opening(e); end
			else watched_names[what] = nil; end
		end
		
		function _M.close_gui(player_index)
			if not global.open_guis[player_index] or not global.open_guis[player_index].valid then return; end
			--[[ HOPEFULLY WILL WORK SOON
			player.opened = defines.gui_type.none
			--]]
			interfaces:foreach(function(interface)
				interface.on_close{player = game.players[player_index], element = global.open_guis[player_index]}
			end)
			if global.open_guis[player_index].valid then
				global.open_guis[player_index].destroy()
				global.open_guis[player_index] = nil
			end
		end
		
		
		--TODO: handle closing when entity is destroyed
		
		
		FML.events.on(config.GUI.NAMES.OPEN_KEY, function(event)
			local player = game.players[event.player_index]
			if player 
					and not player.opened_self and player.opened_gui_type == defines.gui_type.none -- Check if other gui isn't open
					and player.selected and player.selected.valid and watched_names[player.selected.name] then -- Check if our gui isn't open
				-- Prevent the normal GUI from appearing
				block_gui(player)
				
				if not (global.open_guis[player.index] and global.open_guis[player.index].valid) then
					log.d("Player #"..player.index..' opened "'..player.selected.name..'" at '..FML.format.position(player.selected.position))
					init_interfaces()
					-- Call all the local instances
					local status = false
					local element
					interfaces:foreach(function(interface, mod)
						local res = interface.on_open{
								player = player, -- The player that did the opening
								entity = player.selected, -- The entity that was opened
								opened = status, -- The name of the mod that handled the opening or false if not handled yet
								element = element, -- The root element of the gui that was created by the mod that handled
									-- the opening or nil if not handled yet
							}
						if res then status = mod; end
						element = res or element
					end)
					
					if status and element and element.valid then global.open_guis[player.index] = element
					else global.open_guis[player.index] = nil; end
					
					log.dump("Status: ", status)
				end
			elseif global.open_guis[player.index] and global.open_guis[player.index].valid then
				block_gui(player) -- Block non watched entity guis if a gui is open
			end
		end)
		
		---[[ LEGACY
		FML.events.on_tick(function(event)
			-- Reset operable on the entities that were opened last tick
			if global.post_open then
				for _, e in ipairs(global.post_open) do if e.valid then e.operable = true; end end
				global.post_open = nil
			end
		end)
		--]]
		
		FML.events.on(config.GUI.NAMES.CLOSE_KEY, function(event)
			_M.close_gui(event.player_index) -- This should handle everything
		end)
		
		FML.remote.add_interface("therustyknife.FML.GUI", _M, false)
	end
end
