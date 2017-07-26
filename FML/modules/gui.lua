--TODO: make this not be a giant pile of mess - sort into different files, rework the actual gui creation mechanic, ...
return function(_M)
	local FML = therustyknife.FML
	local config = therustyknife.FML.config

	local table = FML.table
	
	
	local STYLES = {
		flow = {
			no_space_v = "FML_style_flow-no-space-v",
			no_space = "FML_style_flow-no-space",
		},
	}
	
	
	if FML.STAGE == "data" then
		-- Controls
		FML.data.make{
			{ -- Open GUI (by clicking)
				type = "custom-input",
				name = config.GUI.NAMES.OPEN_KEY,
				key_sequence = "mouse-button-1",
				consuming = "none",
			},
			{ -- Close GUI (explicitly)
				type = "custom-input",
				name = config.GUI.NAMES.CLOSE_KEY,
				key_sequence = "TAB",
				consuming = "none",
			},
			{ -- Close GUI (by opening another GUI)
				type = "custom-input",
				name = config.GUI.NAMES.CLOSE_KEY_OVERRIDE,
				key_sequence = "E",
				consuming = "none",
			},
		}
		
		FML.log.dump(data.raw["gui-style"])
		-- Styles
		table.merge(data.raw["gui-style"].default, {
			[STYLES.flow.no_space_v] = {
				type = "flow_style",
				parent = "flow_style",
				vertical_spacing = 0,
			},
			[STYLES.flow.no_space] = {
				type = "flow_style",
				parent = "flow_style",
				vertical_spacing = 0,
				horizontal_spacing = 0,
			},
		})
		
		
		return nil, true

	elseif FML.STAGE == "runtime" then
		local _DOC = FML.make_doc(_M, {
			type = "module",
			name = "GUI",
			desc = [[ Allows creating more complex GUI structures easily. ]],
		})
		
		
		--TODO: refactor this to be *actually* usable
		--TODO: write docs
		
		-- The frame that contains the entity name and preview
		function _M.entity_title(args) -- parent, name, entity, cam, cam_zoom, cam_size
			local frame = args.parent.add{
				type = "frame",
				name = args.name,
				caption = args.entity.localised_name,
				direction = "horizontal"
			}
			if args.cam ~= false then
				local cam = frame.add{
					type = "camera",
					position = args.entity.position,
					surface_index = args.entity.surface.index,
					zoom = args.cam_zoom or 1, -- Assembler and smaller is 1, refinery is ~0.5
				}
				cam.style.minimal_width = args.cam_size or 100
				cam.style.minimal_height = args.cam_size or 100
			end
			return frame.add{
				type = "flow",
				direction = "vertical",
			}
		end
		
		-- The two-column base of the entity gui, with title
		function _M.entity_base(args) -- parent, name, entity, cam, cam_zoom
			local frame = args.parent.add{
				type = "flow",
				name = args.name,
				direction = "horizontal",
				style = STYLES.flow.no_space,
			}
			local primary_col = frame.add{
				type = "flow",
				direction = "vertical",
				style = STYLES.flow.no_space,
			}
			local secondary_col = frame.add{
				type = "flow",
				direction = "vertical",
				style = STYLES.flow.no_space,
			}
			local title = _M.entity_title{
					parent = primary_col, entity = args.entity, cam = args.cam, cam_zoom = args.cam_zoom
				}
			return {primary = primary_col, secondary = secondary_col, title = title}
		end
		
		-- A single segment of an entity's gui
		function _M.entity_segement(args) -- parent, name, title, direction
			return args.parent.add{
				type = "frame",
				name = args.name,
				caption = args.title,
				direction = args.direction or "vertical",
			}
		end
		
		
		--TODO: implement high-level GUI
		
		
		-- GUI opening mechanics
		--TODO: allow registering entities in data as well
		local watched_names = table()
		
		local global
		FML.events.on_load(function()
			global = table(FML.get_fml_global("GUI"))
		end)
		
		
		function _M.watch_opening(what)
			if type(what) == "table" then for _, e in pairs(what) do _M.watch_opening(e); end
			else watched_names[what] = true; end
		end
		
		function _M.unwatch_opening(what)
			if type(what) == "table" then for _, e in pairs(what) do _M.unwatch_opening(e); end
			else wached_names[what] = nil; end
		end
		
		
		FML.events.on(config.GUI.NAMES.OPEN_KEY, function(event)
			local player = game.players[event.player_index]
			if player and player.selected and player.selected.valid and wached_names[player.selected.name] then
				if player.selected.operable then
					global.post_open = table(global.post_open) -- make sure the table exists
					global.post_open:insert(player.selected)
				end
				player.selected.operable = false
				--TODO: raise the event or do whatever is needed
			end
		end)
		
		FML.events.on_tick(function(event)
			if global.post_open then
				for _, e in ipairs(global.post_open) do if e.valid then e.operable = true; end end
				global.post_open = nil
			end
		end)
		
		FML.events.on({config.GUI.NAMES.CLOSE_KEY, config.GUI.NAMES.CLOSE_KEY_OVERRIDE}, function(event)
			log.d("Pressed close GUI key")
			--TODO: implement
		end)
	else return nil, true; end
end