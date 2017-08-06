return function(_M)
	local FML = therustyknife.FML
	if FML.STAGE == "data" then
		local config = FML.config
		local table = FML.table
		
		
		-- Controls
		FML.data.make{
			{ -- Open GUI (by clicking)
				type = "custom-input",
				name = config.GUI.NAMES.OPEN_KEY,
				key_sequence = "mouse-button-1",
				consuming = "none",
			},
			{ -- Close GUI (E - can't use escape AFAIK)
				type = "custom-input",
				name = config.GUI.NAMES.CLOSE_KEY,
				key_sequence = "E",
				consuming = "none",
			},
		}
		
		-- Styles
		table.merge(data.raw["gui-style"].default, {
			[_M.STYLES.flow.no_space_v] = {
				type = "flow_style",
				parent = "flow_style",
				vertical_spacing = 0,
			},
			[_M.STYLES.flow.no_space] = {
				type = "flow_style",
				parent = "flow_style",
				vertical_spacing = 0,
				horizontal_spacing = 0,
			},
			[_M.STYLES.table.no_space] = {
				type = "table_style",
				parent = "table_style",
				vertical_spacing = 0,
				horizontal_spacing = 0,
			},
		})
		
		return nil, true --TODO: check what this does
	end
end
