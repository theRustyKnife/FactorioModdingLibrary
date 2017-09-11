return function(_M)
	local FML = therustyknife.FML
	local config = FML.config
	
	
	function _M._entity_name(data_name) return config.BLUEPRINT_DATA.PROTOTYPE_NAME..data_name; end
	
	function _M._get_entity(parent, data_name, create)
		local entity_name = _M._entity_name(data_name)
		local entity = parent.surface.find_entity(entity_name, parent.position)
		if entity or create == false then return entity; end
		entity = parent.surface.create_entity{
			name = entity_name,
			position = parent.position,
			force = parent.force,
			direction = parent.supports_direction and parent.direction or nil,
		}
		entity.destructible = false
		return entity
	end
end
