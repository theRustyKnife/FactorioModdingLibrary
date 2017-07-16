return {
	_M = true,
	function(_M)
		FML.make_doc(_M, {
			type = "module",
			name = "blueprint-data",
			desc = [[ Allows saving data for entities in blueprints. ]],
		})
	end,
	require ".shared.lua",
	require ".local.lua",
}