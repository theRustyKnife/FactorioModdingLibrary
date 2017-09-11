return function(_M)
	local FML = therustyknife.FML
	local config = therustyknife.FML.config
	local table = therustyknife.FML.table
	local log = therustyknife.FML.log
	
	
	local SIGNAL = {type = "item", name = config.BLUEPRINT_DATA.ITEM_NAME}
	
	local global
	local prototypes = {}
	local lut = {}
	
	
	local associate_entity = FML.remote.get_rich_callback("therustyknife.FML.blueprint_data", "associate_entity")
	
	local function trimed_description(entity_name)
		return game.entity_prototypes[entity_name].localised_description[1]
	end
	
	local function load_prototype(name)
		if not prototypes[name] then
			FML.log.d("Loading prototype for "..name.."...")
			assert(game.entity_prototypes[_M._entity_name(name)], "Blueprint data named "..name.." doesn't exist")
			prototypes[name] = loadstring(trimed_description(_M._entity_name(name)))()
		end
		return prototypes[name]
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
			if not from.__entity then data:_reset(); return; end
			if not data.__entity then
				data.__entity = _M._get_entity(data.__parent, data.__type)
				data.__control_behavior = data.__entity.get_or_create_control_behavior()
			end
			data.__control_behavior.parameters = from.__control_behavior.parameters
		end,
	}
	
	local MT = {
		__index = function(data, key)
			if funcs[key] then return funcs[key]; end -- The methods have precedence
			if type(key) == "string" and key:sub(1, 2) == "__" then return rawget(data, key); end
			
			local prototype = load_prototype(data.__type)
			assert(prototype.settings[key],
				"Blueprint data group "..data.__type.." doesn't contain key "..tostring(key))
			
			local setting = prototype.settings[key]
			if not data.__entity then return setting.default; end
			local signal = data.__control_behavior.get_signal(setting.index)
			if not signal or not signal.signal then return setting.default; end
			
			if setting.type == "int" or setting.type == "enum" then return signal.count; end
			if setting.type == "bool" then return signal.count ~= 0; end
			--TODO: implement
			if setting.type == "float" then error("Blueprint data float is not yet implemented."); end
		end,
		__newindex = function(data, key, value)
			if type(key) == "string" and key:sub(1, 2) == "__" then rawset(data, key, value); return; end
			
			local prototype = load_prototype(data.__type)
			assert(prototype.settings[key],
				"Blueprint data group "..data.__type.." doesn't contain key "..tostring(key))
			
			if not data.__entity then
				data.__entity = get_entity(data.__parent, data.__type)
				data.__control_behavior = data.__entity.get_or_create_control_behavior()
			end
			
			local setting = prototype.settings[key]
			if setting.type == "int" or setting.type == "enum" then
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
	
	
	FML.events.on_delayed_load(function()
		log.d("Loading BlueprintData instances...")
		global = FML.get_fml_global("blueprint_data")
		global.data = table(global.data)
		for _, data in ipairs(global.data) do setmetatable(data, MT); end
	end)
	
	
	function _M.get(parent, data_name)
		if parent.unit_number and lut[parent.unit_number] and lut[parent.unit_number][data_name] then
			return lut[parent.unit_number][data_name]
		end
		
		associate_entity(parent.name, data_name)
		load_prototype(data_name) -- Make sure the prototype is loaded
		
		local data_entity_name = _M._entity_name(data_name)
		local entity = _M._get_entity(parent, data_name, false)
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
		
		if global then global.data:insert(res)
		else log.w("Created BlueprintData before global was accessible - it isn't going to be loaded automatically.")
		end
		
		return res
	end
	
	function _M.get_enum(group, name) return load_prototype(group).settings[name].options; end
end
