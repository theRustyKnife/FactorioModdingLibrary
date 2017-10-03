--/ random-util
--- Random utilities that didn't fit into the other modules.
--- Functions from here may be moved in the future. In such case, they'll be deprecated in this module first before
--- removal.

return function(_M)
	local FML = therustyknife.FML
	
	
	if FML.STAGE == "runtime" then
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
	--- The numbers don't necessarily have to be integers.
	--@ float value: The value to calculate for
	--@ kw float min: The lowest possible value (inclusive)
	--@ kw float max: The highest possible value (inclusive)
	--: float: The calculated value
		local min = args.min or -2147483648
		local max = args.max or 2147483647
		local d = max - min
		
		while true do
			if value > min and value < max then return value
			elseif value > max then value = value-d
			elseif value < min then value = value+d
			end
		end
	end
end
