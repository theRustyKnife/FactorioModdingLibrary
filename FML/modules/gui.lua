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
	else return nil, true; end
end