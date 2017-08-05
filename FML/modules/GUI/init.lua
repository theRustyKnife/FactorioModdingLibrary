return {
	_M = true,
	function(_M)
		therustyknife.FML.make_doc(_M, {
			type = "module",
			name = "GUI",
			desc = [[ Allows creating more complex GUI structures easily. ]],
		})
	end,
	_M_require ".styles",
	_M_require ".data",
	_M_require ".shared",
	_M_require ".entity-opening",
	_M_require "basic-entity",
}
