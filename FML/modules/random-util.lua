--/ random-util
--- Random utilities that didn't fit into the other modules.
--- Functions from here may be moved in the future. In such case, they'll be deprecated in this module first before
--- removal.

return function(_M, STAGE)
	local FML = therustyknife.FML
	
	
	if STAGE == 'RUNTIME' or STAGE == 'RUNTIME_SHARED' then
		function _M.make_request(target, requests)
		--- Request items for an entity.
		--@ LuaEntity target: The entity to deliver items into
		--@ Dictionary[string, uint] requests: The items to request and their amounts
		--: LuaEntity: The created item-request-proxy
			return target.surface.create_entity{
				name = "item-request-proxy",
				target = target,
				modules = requests,
				position = target.position,
				force = target.force,
			}
		end
	end
	
	function _M.calculate_overflow(value, args)
	--- Calculate overflow in the given bounds.
	--- The numbers don't necessarily have to be integers. If the calculation doesn't work the value of min will be
	--- returned. This may happen as a result of poor float precision with large numbers.
	--@ float value: The value to calculate for
	--@ kw float min: The lowest possible value (inclusive)
	--@ kw float max: The highest possible value (exclusive)
	--: float: The calculated value
		args = args or {}
		local min = args.min or -2147483648
		local max = args.max or 2147483648
		local res = ((value-min) % (max-min)) + min
		if res >= min and res < max then return res else return min; end
	end
	
	function _M.string_starts_with(s, start)
	--- Check if a string starts with another string.
	--@ string s: The string to check
	--@ string start: The start we're looking for
	--: bool: `true` if `s` starts with `start`, false otherwise
		return s:sub(1, start:len()) == start
	end
end
