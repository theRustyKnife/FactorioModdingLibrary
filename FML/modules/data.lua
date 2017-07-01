local FML = require "therustyknife.FML"
local config = require "therustyknife.FML.config"


if FML.STAGE ~= "data" then return nil; end


local _M = {}
local _DOC = FML.make_doc(_M, {
	type = "module",
	name = "data",
	desc = [[ Provides functions for simplified prototype definition. ]],
})


_DOC.inherit = {
	type = "function",
	desc = [[ Copy an existing prototype to be used as base for another one. ]],
	params = {
		{
			type = {"string", "table"},
			name = "base_type",
			desc = [[
			The type of the prototype to be coppied. If this is a table, it will be used as the base, regardless of
			what base_name is
			]],
		},
		{
			type = "string",
			name = "base_name",
			desc = "The name of the prototype to be coppied",
			default = "The value of base_type",
		},
		{
			type = "bool",
			name = "force",
			desc = "If true, raise an error if inheritance failed, otherwise return a function for later attempt",
			default = "false",
		},
	},
	returns = {
		{
			type = {"table", "table function(bool force)"},
			desc = "The prototype base or function to obtain it",
		},
	},
}
function _M.inherit(base_type, base_name, force)
	local res
	if type(base_type) == "table" then res = base_type
	else
		base_name = base_name or base_type
		if not data.raw[base_type] or not data.raw[base_type][base_name] then
			assert(not force, "can't inherit from type: " .. tostring(base_type) .. ", name: " .. tostring(base_name))
			return function(force) return _M.inherit(base_type, base_name, force); end
		end
		res = data.raw[base_type][base_name]
	end
	return FML.table.deep_copy(res)
end


_DOC.make = {
	type = "function",
	desc = [[ Parse and add the given prototype to data. ]],
	params = {
		{
			type = {"Prototype", "VanillaPrototype", "Array[{Prototype, VanillaPrototype}]"},
			name = "prototype",
			desc = "The prototype to be added",
		},
		{
			type = "bool",
			name = "deep",
			desc = "If true, the prototype base will be deep coppied before modification",
			default = "true",
		},
	},
	returns = {
		{
			type = "VanillaPrototype",
			desc = "The prototype table, as it was added to data",
		},
	},
}
--[[
Random Notes on This Topic

--TODO: Some proper documentation of the concepts is really imprortant here!

--TODO: All the bellow, docs for it
This is the way to allow for modification of values in multiple places at once:
	In a table, use special function attributes that will be called with certain parameters to allow you to transform 
	the required properties into whatever you want. The proposed functions are:
		_each - gets called for every value in the same table, regardless of it's type (except the special ones)
		_tabs - gets called for every table value in the same table,
		_vals - gets called for every non-table value in the same table
	All of the functions take the following parameters:
		*Any* val - the original value of the attribute
		*string* name - the name of the attribute AKA the index in the table
		*function* set - a function that, if called, sets the value to whatever was passed as a parameter
	The set function really only exists to allow setting the value to nil, since if anything else than nil is returned, it 
	it will be set to the attribute. This functionallity is more useful in the case bellow:
	What will also be possible, is to use a function in place of any attribute. This function will be called with the 
	same parameters as the special table functions. Here the setting ability will be useful. (I'm not sure how much is 
	this going to be used overall tho.)
	As for some random detail: the iteration functions are going to be called before any of the other attributes are 
	applied. This will cause a behavior similar to how css works: more specific attributes are prioritized.
	Additionally, there will be one more special attribute, _for, which will be a table with the following structure:
		{
			names = Array[string], -- The attribute names to use
			set = Any, -- What to set to those attributes - if function, it will behave the same way other attributes do
		}
	Moreover, _for can be an array of the above structures, where all of them will be applied. Note that _for will be 
	applied after the special function calls, but before any other, explicitly defined attributes, therefore it may get 
	overwritten by them.
]]
function _M.make(prototype, deep)
	-- If an array of prototypes is passed, loop and add them
	if not prototype.type and not prototype.base and not prototype.properties then
		local res = FML.table.new()
		for _, p in ipairs(prototype) do res:insert(_M.make(p)); end
		return res
	end
	
	-- If VanillaPrototype was passed, extend data directly
	if prototype.type then
		data:extend{prototype}
		return prototype
	end
	
	if prototype.base then
		if type(prototype.base) == "function" then prototype.base = prototype.base(true); end
		if deep == nil or deep then prototype.base = FML.table.deep_copy(prototype.base); end
	end
	local res = prototype.base or {}
	
	local function _get_special_functions(tab)
	-- Helper function for extracting the special functions and clearing the table
		local each, tabs, vals, _for = tab._each, tab._tabs, tab._vals, tab._for
		tab._each, tab._tabs, tab._vals, tab._for = nil, nil, nil, nil
		return each, tabs, vals, _for
	end
	
	local function _call_val(value, name, dest, func)
		local to_set = true
		local res_val = func(
				value, name,
				function(val) dest[name] = val; to_set = false; end
			)
		if to_set and res_val ~= nil then dest[name] = res_val; end
	end
	
	local function _add_properties(dest, src)
		-- Get the special attributes and clear them from the table
		local each, tabs, vals, _for = _get_special_functions(src)
		
		-- Apply the special functions
		for val_name, val in pairs(src) do
			if each then _call_val(dest[val_name], val_name, dest, each); end
			if type(val) == "table" and tabs then _call_val(dest[val_name], val_name, dest, tabs); end
			if type(val) ~= "table" and vals then _call_val(dest[val_name], val_name, dest, vals); end
		end
		
		-- Apply _for
		if _for then
			local function _do_for(dest, _for)
				for _, name in pairs(_for.names) do
					dest[name] = _for.set
				end
			end
			if _for.names then _do_for(dest, _for)
			else
				for _, f in ipairs(_for) do
					_do_for(dest, _for)
				end
			end
		end
		
		-- Copy all the regular attribute specifications
		for name, value in pairs(src) do
			local t = type(value)
			if t == "table" then
				if type(dest[name]) ~= "table" then dest[name] = {}; end -- Make sure dest is a table we can use
				_add_properties(dest[name], src[name])
			
			elseif t == "function" then
				_call_val(dest[name], name, dest, value)
			
			else dest[name] = value
			end
		end
	end
	_add_properties(res, FML.table.deep_copy(prototype.properties) or {})
	
	data:extend{res}
	local res = data.raw[res.type][res.name] -- Do this to allow modification of the prototype directly
	
	if prototype.generate then
		local item = prototype.generate.item or FML.table.contains(prototype.generate, "item")
		local recipe = prototype.generate.recipe or FML.table.contains(prototype.generate, "recipe")
		
		if item or recipe then
			if type(item) ~= "table" then item = nil; end
			item = _M.make_item_for(res, item)
		end
		
		if recipe then
			if type(recipe) ~= "table" then recipe = nil; end
			recipe = _M.make_recipe_for(item, recipe)
		end
	end
	
	return res
end


_DOC.make_item_for = {
	type = "function",
	desc = [[ Make an item prototype for the given entity prototype and add it to data. ]],
	params = {
		{
			type = "VanillaPrototype",
			name = "entity_prototype",
			descc = "The entity prototype to generate item for",
		},
		{
			type = "SimpleItemPrototype",
			name = "properties",
			desc = [[
			A table that may contain any combination of: base and properties, as in Prototype, and set_minable_result -
			bool, default true
			]],
			default = "{}",
		},
	},
	returns = {
		{
			type = "VanillaPrototype",
			desc = "The prototype table, as it was added to data",
		},
	},
}
function _M.make_item_for(entity_prototype, properties)
	properties = properties or {}
	
	local base = properties.base or {
		type = "item",
		name = entity_prototype.name,
		place_result = entity_prototype.name,
		icon = entity_prototype.icon,
		icons = entity_prototype.icons,
		order = entity_prototype.order or "zzz[unsorted]",
		stack_size = 100,
		flags = {"goes-to-quickbar"},
	}
	
	base.name = entity_prototype.name
	
	local res = _M.make{
		base = base,
		properties = properties.properties or {},
	}
	
	if properties.set_minable_result == nil or properties.set_minable_result then
		entity_prototype.minable = entity_prototype.minable or config.DATA.DEFAULT_MINABLE
		entity_prototype.minable.result = res.name
	end
	
	return res
end


_DOC.make_recipe_for = {
	type = "function",
	desc = [[ Make a recipe prototype for the given item prototype and add it to data. ]],
	params = {
		{
			type = "VanillaPrototype",
			name = "item_prototype",
			desc = "The item prototype to generate recipe for",
		},
		{
			type = "SimpleRecipePrototype",
			name = "properties",
			desc = [[
			A table that may contain any combination of: base and properties, as in Prototype, and unlock_with - string,
			default nil
			]],
			default = "{}",
		},
	},
	returns = {
		{
			type = "VanillaPrototype",
			desc = "The prototype table, as it was added to data",
		},
	},
}
function _M.make_recipe_for(item_prototype, properties)
	properties = properties or {}
	
	local base = properties.base or config.DATA.RECIPE_BASE
	
	base.name = item_prototype.name
	base.result = item_prototype.name
	
	local res = _M.make{
		base = base,
		properties = properties.properties or {},
	}
	
	if properties.unlock_with then
		local tech = data.raw["technology"][properties.unlock_with]
		assert(
				tech,
				"Can't add recipe "..res.name.." to "..tostring(properties.unlock_with).."'s effects, because the tech"..
				"does not (yet) exist."
			)
		
		tech.effects = tech.effects or {}
		table.insert(tech.effects, {type = "unlock-recipe", recipe = res.name})
	end
	
	return res
end


return _M
