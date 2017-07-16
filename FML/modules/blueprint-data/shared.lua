return function(_M)
	local FML = therustyknife.FML
	local config = therustyknife.FML.config
	local table = FML.table
	
	
	if FML.TYPE == "shared" then
		local global
		
		
		local function entity_name(data_name) return config.BLUEPRINT_DATA.PROTOTYPE_NAME..data_name; end
		local entity_name_length = config.BLUEPRINT_DATA.PROTOTYPE_NAME:len()
		local function is_supported_entity(entity_name)
			local sub = entity_name:sub(1, entity_name_length)
			return sub == config.BLUEPRINT_DATA.PROTOTYPE_NAME
		end
		local function get_data_name(entity_name)
			return entity_name:sub(entity_name_length+1, entity_name:len())
		end
		
		local function get_entity(parent, data_name, create)
			local entity_name = entity_name(data_name)
			local entity = parent.surface.find_entity(entity_name, parent.position)
			if entity or create == false then return entity; end
			entity = parent.surface.create_entity{
				name = entity_name,
				position = parent.position,
				force = parent.force,
			}
			entity.destructible = false
			return entity
		end
		
		
		FML.remote.add_interface("therustyknife.FML.blueprint_data", {
			associate_entity = function(entity, data)
				global.data_entity_types[data] = table(global.data_entity_types[data])
				global.data_entity_types[data][entity] = true
				global.entity_data_types[entity] = table(global.entity_data_types[entity])
				global.entity_data_types[entity][data] = true
			end,
		})
		
		
		FML.events.on_load(function()
			global = FML.get_fml_global("blueprint_data")
			global.data_entity_types = table(global.data_entity_types)
			global.entity_data_types = table(global.entity_data_types)
		end)
		
		
		-- Handle entities built from blueprints
		FML.events.on_built(function(event)
			local entity = event.created_entity
			if entity.type == "entity-ghost" and is_supported_entity(entity.ghost_name) then
				-- If the entity doesn't have any viable parent, then destroy it
				if entity.surface.find_entity(entity.ghost_name, entity.position) then entity.destroy()
				-- If the entity does have a (potential) parent, then revive it from the ghost
				else entity.revive(); end
			end
		end)
		
		--TODO: check how this works when an entity with data is killed and a ghost is left behind. It's probably going
		-- to have it's settings lost right now
		
		-- Remove entities when their parents are destroyed
		FML.events.on_destroyed(function(event)
			local entity = event.entity
			local entity_name = entity.type == "entity_ghost" and entity.ghost_name or entity.name
			-- If this entity type has any known data attached to it, make sure there are no entities left
			if global.entity_data_types[entity_name] then
				for data_type, _ in pairs(global.entity_data_types[entity_name]) do
					local data_entity = get_entity(entity, data_type, false)
					if data_entity and data_entity.valid then data_entity.destroy(); end
				end
			end
		end)
		
		-- Make sure the data entities don't get picked up by bots - they'll be destroyed when their parents are deconstructed
		FML.events.on(defines.events.on_marked_for_deconstruction, function(event)
			local entity = event.entity
			if is_supported_entity(entity.name) then
				local data_name = get_data_name(entity.name)
				local found_entity
				for entity_name, _ in pairs(global.data_entity_types[data_name] or {}) do
					found_entity = entity.surface.find_entity(entity_name, entity.position)
					if found_entity then break; end
				end
				if found_entity then entity.cancel_deconstruction(entity.force)
				-- This happens when this entity was associated with a ghost - no event runs for removing a ghost
				else entity.destroy(); end
			end
		end)
	end
end