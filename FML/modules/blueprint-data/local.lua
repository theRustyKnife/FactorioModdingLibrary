return function(_M)
	local FML = therustyknife.FML
	local config = therustyknife.FML.config
	local table = FML.table
	
	
	local _DOC = _M._DOC.funcs
	
	
	local function entity_name(data_name) return config.BLUEPRINT_DATA.PROTOTYPE_NAME..data_name; end
	local entity_name_length = config.BLUEPRINT_DATA.PROTOTYPE_NAME:len()
	local function is_supported_entity(entity_name)
		local sub = entity_name:sub(1, entity_name_length)
		return sub == config.BLUEPRINT_DATA.PROTOTYPE_NAME
	end
	local function get_data_name(entity_name)
		return entity_name:sub(entity_name_length+1, entity_name:len())
	end
	
	if FML.STAGE == "data" then
		local PROTOTYPE_BASE = FML.data.inherit("constant-combinator")
		
		-- The item to be used for signalling
		FML.data.make{
			type = "item",
			name = config.BLUEPRINT_DATA.ITEM_NAME,
			flags = {"hidden"},
			icon = config.BLUEPRINT_DATA.ICON,
			stack_size = 1,
		}
		
		
		local function parse_settings(settings)
		--[[ Fill in all the required info and figure out the slot count along the way. ]]
			local res = {}
			local slots = 0
			for name, setting in pairs(settings) do
				if setting.index > slots then slots = setting.index; end
				res[name] = {
					name = name,
					type = setting.type,
					index = setting.index,
					default = setting.default,
				}
				if setting.type == "float" then
					res[name].exponent_index = setting.exponent_index or setting.index+1
					if res[name].exponent_index > slots then slots = res[name].exponent_index; end
				end
			end
			
			return res, slots
		end
		
		
		_DOC.add_prototype = {
			type = "function",
			short_desc = "Add a new blueprint data prototype.",
			desc = [[
			Add a new blueprint data prototype.  
			collision_box is the size of the proxy entity that will be used and is recommended to be set to the same
			size as the entity it's used for. This is mainly to prevent players from creating blueprints without the
			proxy included.
			]],
			notes = {"Only available during the data stage."},
			params = {
				{
					type = "BlueprintDataPrototype",
					name = "prototype",
					desc = "The prototype to add",
				},
				{
					type = "BoundingBox",
					name = "collision_box",
					desc = "The bounding box to use for this blueprint data group",
					default = "{{0, 0}, {0, 0}}",
				},
			},
		}
		function _M.add_prototype(prototype, collision_box)
			collision_box = collision_box or config.BLUEPRINT_DATA.DEFAULT_COLLISION_BOX
			if type(prototype) == "table" and not prototype.name then
				for _, p in pairs(prototype) do _M.add_prototype(p, collision_box); end
				return
			end
			
			local settings, slots = parse_settings(prototype.settings)
			FML.data.make{
				base = PROTOTYPE_BASE,
				properties = {
					name = entity_name(prototype.name),
					icon = config.BLUEPRINT_DATA.ICON,
					flags = {"placeable-off-grid", "placeable-neutral", "player-creation"},
					collision_mask = {},
					collision_box = collision_box,
					selection_box = {{0, 0}, {0, 0}},
					item_slot_count = slots,
					order = "zzz",
					hidden = true,
					sprites = {
						_for = {names = {"north", "east", "south", "west"}, set = {
							filename = config.DATA.PATH.TRANS,
							x = 0, y = 0, width = 0, height = 0,
						}},
					},
					localised_name = {serpent.dump{name = prototype.name, settings = settings}}, -- This is where the data is stored
				},
				generate = {"item"},
			}
		end
		--TODO: a way to alter already added prototypes?
		
	elseif FML.STAGE == "runtime" then
		local SIGNAL = {type = "item", name = config.BLUEPRINT_DATA.ITEM_NAME}
		
		local global
		
		local prototypes = {}
		local lut = {}
		
		
		FML.events.on_load(function()
			global = FML.get_fml_global("blueprint_data")
			global.data_entity_types = table(global.data_entity_types)
			global.entity_data_types = table(global.entity_data_types)
			FML.log.dump(
					"Running on_load in blueprint-data, "..(config.MOD and config.MOD.NAME or "console")..", global: ",
					global or "nil"
				)
		end)
		
		
		local function trimed_description(entity_name)
			return string.gmatch(game.entity_prototypes[entity_name].localised_name[1], "[^%.]+")
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
		
		local funcs = {
			_reset = function(data) -- Reset all settings to the default (destroy the entity)
				if data.__entity then
					if data.__entity.valid then data.__entity.destroy(); end
					data.__entity = nil
					data.__control_behavior = nil
				end
			end,
			_copy = function(data, from) -- Copy settings from another data
				assert(data.__type == from.__type,
					"Attempt to copy blueprint data from a different type (from "..from.__type.." to "..data.__type..")")
				if not from.__entity then data:reset(); return; end
				data.__control_behavior.parameters = from.__control_behavior.parameters
			end,
		}
		
		local MT = {
			__index = function(data, key)
				if funcs[key] then return funcs[key]; end -- The methods have precedence
				if type(key) == "string" and key:sub(1, 2) == "__" then return rawget(data, key); end
				
				FML.log.d(key)
				
				local prototype = prototypes[data.__type]
				assert(prototype.settings[key],
					"Blueprint data group "..data.__type.." doesn't contain key "..tostring(key))
				
				local setting = prototype.settings[key]
				if not data.__entity then return setting.default; end
				local signal = data.__control_behavior.get_signal(setting.index)
				if not signal or not signal.signal then return setting.default; end
				
				if setting.type == "int" then return signal.count; end
				if setting.type == "bool" then return signal.count ~= 0; end
				--TODO: implement
				if setting.type == "float" then error("Blueprint data float is not yet implemented."); end
			end,
			__newindex = function(data, key, value)
				if type(key) == "string" and key:sub(1, 2) == "__" then rawset(data, key, value); return; end
				
				FML.log.d(serpent.line(data.__type))
				FML.log.d(serpent.line(prototypes))
				local prototype = prototypes[data.__type]
				assert(prototype.settings[key],
					"Blueprint data group "..data.__type.." doesn't contain key "..tostring(key))
				
				if not data.__entity then
					data.__entity = get_entity(data.__parent, data.__type)
					data.__control_behavior = data.__entity.get_or_create_control_behavior()
				end
				
				local setting = prototype.settings[key]
				if setting.type == "int" then
					data.__control_behavior.set_signal(setting.index, {signal = SIGNAL, count = value})
				elseif setting.type == "bool" then
					value = value and 1 or 0
					data.__control_behavior.set_signal(setting.index, {signal = SIGNAL, count = value})
				elseif setting.type == "float" then
					--TODO: implement
					error("Blueprint data float is not yet implemented.")
				end
			end,
		}
		
		
		_DOC.get = {
			type = "function",
			desc = "Get a BlueprintData object for an entity.",
			notes = {"Only available in the runtime stage."},
			params = {
				{
					type = "LuaEntity",
					name = "parent",
					desc = "The entity to get the data for",
				},
				{
					type = "string",
					name = "data_name",
					desc = "The blueprint data group to get",
				},
			},
			returns = {
				{
					type = "BlueprintData",
					desc = "The BlueprintData object",
				},
			},
		}
		function _M.get(parent, data_name)
			if parent.unit_number and lut[parent.unit_number] and lut[parent.unit_number][data_name] then
				return lut[parent.unit_number][data_name]
			end
			
			local data_entity_name = entity_name(data_name)
			
			-- Save this entity's relation with this data type
			if not global.entity_data_types[parent.name] or not global.entity_data_types[parent.name][data_name] then
				global.data_entity_types[data_name] = table(global.data_entity_types[data_name])
				global.data_entity_types[data_name][parent.name] = true
				global.entity_data_types[parent.name] = table(global.entity_data_types[parent.name])
				global.entity_data_types[parent.name][data_name] = true
			end
			
			if not prototypes[data_name] then -- Make sure the prototype is loaded
				assert(game.entity_prototypes[data_entity_name], "Blueprint data named "..data_name.." doesn't exist")
				FML.log.d(trimed_description(data_entity_name))
				FML.log.d(serpent.line(loadstring(trimed_description(data_entity_name))))
				prototypes[data_name] = loadstring(trimed_description(data_entity_name))()
			end
			
			local entity = get_entity(parent, data_name, false)
			local res = setmetatable({
				__type = data_name,
				__parent = parent,
				__entity = entity,
				__control_behavior = entity and entity.get_or_create_control_behavior(),
			}, MT)
			
			if parent.unit_number then
				lut[parent.unit_number] = table(lut[parent.unit_number])
				lut[parent.unit_number][data_name] = res
			end
			
			return res
		end
		
		
		FML.events.on_built(function(event)
			local entity = event.created_entity
			if entity.type == "entity-ghost" and is_supported_entity(entity.ghost_name) then
				if entity.surface.find_entity(entity.ghost_name, entity.position) then entity.destroy()
				else entity.revive(); end
			end
		end)
		
		FML.events.on_destroyed(function(event)
			local entity = event.entity
			local entity_name = entity.type == "entity_ghost" and entity.ghost_name or entity.name
			if global.entity_data_types[entity_name] then
				FML.log.dump("Clearing data entities for "..entity_name..": ", global.entity_data_types[entity_name])
				for data_type, _ in pairs(global.entity_data_types[entity_name]) do
					local data_entity = get_entity(entity, data_type, false)
					if data_entity and data_entity.valid then data_entity.destroy(); end
				end
			end
		end)
		
		FML.events.on(defines.events.on_marked_for_deconstruction, function(event)
			FML.log.d("Deconstructing "..event.entity.name)
			local entity = event.entity
			if entity.to_be_deconstructed() and is_supported_entity(entity.name) then
				local data_name = get_data_name(entity.name)
				local found_entity
				FML.log.dump("Data name: ", data_name)
				FML.log.dump("data_entity_types: ", global.data_entity_types)
				if global.data_entity_types[data_name] then
					for entity_name, _ in pairs(global.data_entity_types[data_name]) do
						found_entity = entity.surface.find_entity(entity_name, entity.position)
						if found_entity then break; end
					end
				end
				if found_entity then entity.cancel_deconstruction(entity.force)
				else entity.destroy(); end
			end
		end)
	end
end
