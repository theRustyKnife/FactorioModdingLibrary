return function(_M)
	local FML = therustyknife.FML
	local config = therustyknife.FML.config

	local table = FML.table


	local _DOC = FML.make_doc(_M, {
		type = "module",
		name = "data-container",
		desc = [[ Allows carrying data between the data and runtime stages. ]],
	})


	if FML.STAGE == "data" then
		local prototype = data.raw["item"][config.DATA_CONTAINER.PROTOTYPE_NAME] or FML.data.make{
			type = "item",
			name = config.DATA_CONTAINER.PROTOTYPE_NAME,
			hidden = true,
			icon = config.DATA.PATH.NO_ICON,
			stack_size = 1,
			flags = {},
			order = "{}", -- Init to empty table so we don't have to handle errors if no data was saved here
		}
		
		
		local data = table() -- Save the data here intermediately, so we don't have to load it from the prototype
		
		
		_DOC.set_value = {
			type = "function",
			short_desc = [[ Set a value into the data container. ]],
			desc = [[ Set a value into the data container. This will then be available in the runtime stage. ]],
			notes = {"Only values that can be serialized into a string can be used."},
			params = {
				{
					type = "string",
					name = "namespace",
					desc = "The top-level name in the data hierarchy, recommended to use mod author name here",
				},
				{
					type = "string",
					name = "name",
					desc = "The name of the value inside the namespace, recommended to use mod name here",
				},
				{
					type = "Any",
					name = "value",
					desc = "The value to be added, recommended to use a table with the values of the mod inside",
				},
			},
		}
		function _M.set_value(namespace, name, value)
			assert(type(namespace) == "string" and type(name) == "string", "namespace and name have to be of type string.")
			
			data[namespace][name] = value
			prototype.order = serpent.line(data)
		end
		
		function _M.get_value(namespace, name)
			if data[namespace] then return data[namespace][name]; end
			return nil
		end

	elseif FML.STAGE == "runtime" then
		local data -- Store the data here so we only have to load it once
		
		function _M.get_value(namespace, name)
			assert(game, "Can't load data before game is loaded.")
			data = data or loadstring(game.item_prototypes[config.DATA_CONTAINER.PROTOTYPE_NAME].order)()
			if data[namespace] then return data[namespace][name]; end
			return nil
		end
	end

	-- This is here because of the two different implementations above
	_DOC.get_value = {
		type = "function",
		desc = [[ Get the value from the data. ]],
		notes = {[[
		In the runtime stage, data can't be accessed before the global `game` is loaded, an attempt to do so will result in
		an error.
		]]},
		params = {
			{
				type = "string",
				name = "namespace",
				desc = "The namespace to get a value from",
			},
			{
				type = "string",
				name = "name",
				desc = "The name of the value to get",
			},
		},
		returns = {
			{
				type = "Any",
				desc = "The value stored, nil if not found",
			},
		},
	}
end
