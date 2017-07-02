local FML = require "therustyknife.FML"
local config = require "therustyknife.FML.config"
local table = FML.table


if FML.STAGE ~= "data" then return nil; end


local _M = {}
local _DOC = FML.make_doc(_M, {
	type = "module",
	name = "prototype-util",
	desc = "Conatains various utility functions for prototype creation.",
})


_DOC.is_result = {
	type = "function",
	desc = [[ Figure out if item is a result of recipe. ]],
	params = {
		{
			type = "string",
			name = "item",
			desc = "The item name",
		},
		{
			type = "VanillaPrototype",
			name = "recipe",
			desc = "The recipe to search in",
		},
	},
}
function _M.is_result(item, recipe)
	local function _is_result(item, recipe)
		if item == recipe.result then return true; end
		return table.any_tab(recipe.results, function(_, v) return _M.result_name(v) == item end)
	end
	
	if _is_result(item, recipe) then return true; end
	if recipe.normal and _is_result(item, recipe.normal) then return true; end
	if recipe.expensive and _is_result(item, recipe.expensive) then return true; end
	return false
end

_DOC.result_name = {
	type = "function",
	desc = [[ Get the result's name no matter what format it was specified in. ]],
	params = {
		{
			type = "table",
			name = "result",
			desc = "The result",
		},
	},
	returns = {
		{
			type = "string",
			desc = "The result name",
		},
	},
}
function _M.result_name(result)
	return result.name or result[1]
end

_DOC.get_possible_results = {
	type = "function",
	short_desc = "Get all the possible results of a recipe.",
	desc = [[ Get all the possible results of a recipe, including both the normal and expensive modes. ]],
	notes = {"At the moment, it is possible that one result will be returned multiple times. This will likely be fixed."}
	params = {
		{
			type = "VanillaPrototype",
			name = "recipe",
			desc = "The recipe to check",
		},
	},
	returns = {
		{
			type = "Array[string]",
			desc = "The result names",
		},
	},
}
function _M.get_possible_results(recipe)
	--TODO: make sure no result can be returned multiple times
	local res = table()
	local function _get_results(recipe)
		if recipe.result then res:insert(recipe.result); end
		for _, result in pairs(recipe.results or {}) do res:insert(_M.result_name(result)); end
	end
	
	_get_results(recipe)
	if recipe.expensive then _get_results(recipe.expensive); end
	if recipe.normal then _get_results(recipe.normal); end
	
	return res
end

_DOC.get_recipe_icons = {
	type = "function",
	desc = [[ Try to get the appropriate icon for this recipe in the icons table format. ]],
	params = {
		{
			type = "VanillaPrototype",
			name = "recipe",
			desc = "The recipe to get icons for",
		},
		{
			type = {"bool", "string"},
			name = "default",
			desc = "If true, use the default icon, if string, use this as the default, if false, return nil if not found",
			default = "true",
		},
	},
}
function _M.get_recipe_icons(recipe, default)
	if recipe.icon then return {{icon = recipe.icon}}; end
	if recipe.icons then return recipe.icons; end
	
	local function _get_icons(item)
		if not item then return nil; end
		if item.icon then return {{icon = item.icon}}; end
		if item.icons then return item.icons; end
		return nil
	end
	
	local possible_results = _M.get_possible_results(recipe)
	for _, type in pairs(config.RESULT_TYPES) do
		local first_icons
		for _, result in pairs(possible_results) do
			local icons = _get_icons(data.raw[type][result])
			if result == recipe.name and icons then return icons; end
			first_icons = first_icons or icons
		end
		if first_icons then return first_icons; end
	end
	
	FML.log.w("Icon not found for: "..recipe.name)
	
	if default == nil or default then
		if type(default) == "string" then return default; end
		return config.DATA.PATH.NO_ICON
	end
	return nil
end


return _M
