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
end
