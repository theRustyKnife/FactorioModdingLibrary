--/ prototype-util
--- Conatains various utility functions for prototype creation.

module({'DATA', 'SETTINGS'}, function(_M)
	local FML = therustyknife.FML
	local config = therustyknife.FML.config
	local table = FML.table

	
	function _M.is_result(item, recipe)
	--- Figure out if item is a result of recipe.
	--@ string item: The item name
	--@ VanillaPrototype recipe: The recipe to search in
	--: bool: true if item is result of recipe
		local function _is_result(item, recipe)
			if item == recipe.result then return true; end
			return table.any_tab(recipe.results, function(_, v) return _M.result_name(v) == item end)
		end
		
		if _is_result(item, recipe) then return true; end
		if recipe.normal and _is_result(item, recipe.normal) then return true; end
		if recipe.expensive and _is_result(item, recipe.expensive) then return true; end
		return false
	end

	function _M.result_name(result)
	--- Get the result's name no matter what format it was specified in.
	--@ table result: The result
	--: string: The result name
		return result.name or result[1]
	end
	
	function _M.get_possible_results(recipe)
	--- Get all the possible results of a recipe.
	--- Includes both the normal and expensive modes.
	--* At the moment, it is possible that one result will be returned multiple times. This will likely be fixed.
	--@ VanillaPrototype recipe: The recipe to check
	--: Array[string]: The result names
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

	function _M.get_recipe_icons(recipe, default)
	--- Try to get the appropriate icon for this recipe in the icons table format.
	--@ VanillaPrototype recipe: The recipe to get icons for
	--@ {bool, string} default=true: If true, use the default icon, if string, use this as the default, if false, return nil if not found
	--: table: The foung icons table
		if recipe.icon then return {{icon = recipe.icon}}; end
		if recipe.icons then return recipe.icons; end
		
		local function _get_icons(item)
			if not item then return nil; end
			if item.icon then return {{icon = item.icon}}; end
			if item.icons then return item.icons; end
			return nil
		end
		
		local possible_results = _M.get_possible_results(recipe)
		for _, type in pairs(config.DATA.RESULT_TYPES) do
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
	
	function _M.get_recipe_locale(recipe)
	--- Try to get the best localised_name for a recipe.
	--* Due to the way the localization works, it is possible that a different name will be returned.
	--@ VanillaPrototype recipe: The recipe to get locale for
	--: LocalisedString: The best guess for a locale for this recipe
		local item, result_item
		local results = _M.get_possible_results(recipe)
		for _, type in pairs(config.DATA.RESULT_TYPES) do
			item = data.raw[type][recipe.name]
			result_item = data.raw[type][results[1]]
			if item or result_item then break; end
		end
		
		if recipe.localised_name then return recipe.localised_name; end
		if item and item.localised_name then return item.localised_name; end
		if result_item then
			if result_item.localised_name then return result_item.localised_name; end
			if result_item.type == "fluid" then return {"fluid-name."..result_item.name}; end
			return {"item-name."..result_item.name}
		end
		if item then
			if item.place_result then return {"entity-name."..item.place_result}; end
			if item.placed_as_equipment_result then return {"equipment-name."..item.placed_as_equipment_result}; end
		end
		return {"recipe-name."..recipe.name}
	end
end)
