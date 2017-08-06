return function(_M)
	local FML = therustyknife.FML
	
	local _DOC = FML.make_doc(_M, {
		type = "module",
		name = "cast",
		desc = [[ Functions for converting between types. ]],
	})
	
	
	_DOC.bool = {
		short_desc = "Convert any thing to bool.",
		desc = [[ Convert any thing to bool. `nil` and `false` will be converted to `false`, anything else to `true`. ]],
	}
	function _M.bool(what)
		return what and true or false
	end
end
