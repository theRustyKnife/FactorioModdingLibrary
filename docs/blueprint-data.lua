return {
	BlueprintData = {_DOC = {
		type = "concept",
		name = "BlueprintData",
		short_desc = "An object representing data persistent in blueprints.",
		desc = [[
		An object representing data persistent in blueprints.  
		A BlueprintData object only allows one blueprint data group to be used, that is settings defined in one
		prototype, defined in the data stage.  
		The data may be accessed like regular table data - using the `[]` operator (dot notation) to get and set values.
		]],
		funcs = {
			_reset = {
				type = "method",
				short_desc = "Reset this BlueprintData to the default values.",
				desc = [[
				Reset this BlueprintData to the default values. This also destroys the proxy entity and thus should be
				called when you're done with this BlueprintData.
				]],
			},
			_copy = {
				type = "method",
				short_desc = "Copy values from another BlueprintData object.",
				desc = [[ Copy values from another BlueprintData object. The objects have to be the same group. ]],
				params = {
					{
						type = "BlueprintData",
						name = "from",
						desc = "The BlueprintData to copy from",
					},
				},
			},
		},
		metamethods = {
			__index = {
				desc = [[ Accesses the data stored in this object. ]],
			},
			__newindex = {
				desc = [[ Sets data to the object. ]],
			},
		},
	}},
	BlueprintDataPrototype = {_DOC = {
		type = "concept",
		name = "BlueprintDataPrototype",
		short_desc = "A definition of settings to be stored in a blueprint.",
		desc = [[
		A definition of settings to be stored in a blueprint.  
		The format is a table with two fields:  
		 - name - The name of this prototype  
		 - settings - A dictionary of setting names mapped to the setting definitions
		Settings are tables in the following format:  
		``{
		``	type = string, -- One of "int", "bool", "float" (float is not yet implemented). Determines what type of data can be stored in this setting.
		``	index = int, -- The index is equivalent to the signal slot it is going to be stored in - has to be unique.
		``	default = Any, -- The default value of this setting, nil if not specified.
		``	exponent_index = int, -- Only for float, determines the slot to store the exponent in - has to be unique.
		``}
		]],
		notes = {[[ Setting names should not start with an underscore, as such names could clash with the methods of
		BlueprintData and other internal things.]]},
	}},
}