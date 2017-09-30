--/ cast
--- Functions for converting between types.


return function(_M)
	function _M.bool(what)
	--- Convert anything to bool.
	--- `nil` and `false` will be converted to `false`, anything else to `true`.
	--@ Any what: The value to convert
	--: bool: The result
		return what and true or false
	end
end
