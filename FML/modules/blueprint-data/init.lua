return {
	_M = true,
	function(_M)
		therustyknife.FML.make_doc(_M, {
			type = "module",
			name = "blueprint-data",
			desc = [[ Allows saving data for entities in blueprints. ]],
		})
	end,
	_M_require ".shared",
	_M_require ".local",
}
