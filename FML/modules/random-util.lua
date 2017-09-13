return function(_M)
	local FML = therustyknife.FML
	
	
	local _DOC = FML.make_doc(_M, {
		type = "module",
		name = "random-util",
		short_desc = "Random utilities that didn't fit into the other modules.",
		desc = [[
		Random utilities that didn't fit into the other modules.  
		Functions from here may be moved in the future. In such case, they'll be deprecated in this module first before
		removal.
		]],
	})
	
	
	if FML.STAGE == "runtime" then
		_DOC.make_request = {
			desc = [[ Request items for an entity. ]],
			params = {
				{
					type = "LuaEntity",
					name = "target",
					desc = "The entity to deliver items into",
				},
				{
					type = "Dictionary[string: uint]",
					name = "requests",
					desc = "The items to request and their amounts",
				},
			},
			returns = {
				{
					type = "LuaEntity",
					desc = "The created item-request-proxy",
				},
			},
		}
		function _M.make_request(target, requests)
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
