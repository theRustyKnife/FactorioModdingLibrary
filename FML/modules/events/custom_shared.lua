--/ events

return function(_M)
	local FML = therustyknife.FML
	local table = therustyknife.FML.table
	
	
	local global
	
	
	_M.on_load(function()
		global = table.mk(FML.get_fml_global('events'), 'custom_shared')
		global:mk'dead_unit_numbers'
	end)
	
	
	_M.on_entity_died(function(event)
		local entity = event.entity
		if entity.valid and entity.unit_number then
			global.dead_unit_numbers[entity.unit_number] = entity.position
		end
	end)
	
	_M.on_built(function(event)
		local entity = event.created_entity
		if entity.unit_number and global.dead_unit_numbers[entity.unit_number]
				and FML.surface.positions_equal(entity.position, global.dead_unit_numbers[entity.unit_number]) then
			global.dead_unit_numbers[entity.unit_number] = nil
			_M.raise(_M.id'therustyknife.FML.events.entity-revived', _M.info{entity=entity})
		end
	end)
end
