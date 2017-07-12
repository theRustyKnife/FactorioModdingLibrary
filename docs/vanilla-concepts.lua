return {
	BoundingBox = {_DOC = {
		type = "concept",
		name = "BoundingBox",
		short_desc = "Defines a rectangular area with two positions.",
		desc = [=[
			Two positions, specifying the top-left and bottom-right corner of the box, respectively. Like with Position,
			the names of the members may be omitted.  
			Members:  
			 - left_top - [[Position|Position]]  
			 - right_bottom - [[Position|Position]]  
		]=],
	}},
	LuaEntity = {_DOC = {
		type = "concept",
		name = "LuaEntity",
		desc = [[ An object representing an entity in the game. ]],
		notes = {"See [API documentation](http://lua-api.factorio.com/latest/LuaEntity.html) for details."},
	}},
	Position = {_DOC = {
		type = "concept",
		name = "Position",
		short_desc = "A position in the world.",
		desc = [[
		Coordinates of a tile in a map. Positions may be specified either as a dictionary with x, y as keys, or simply
		as an array with two elements.
		]],
		notes = {"See [API documentation](http://lua-api.factorio.com/latest/Concepts.html#Position) for details."},
	}},
	EventID = {_DOC = {
		type = "concept",
		name = "EventID",
		short_desc = "An event id.",
		desc = [[
		Either an event id as defined in efines.events or a string describing an input action.
		]],
	}},
	LocalisedString = {_DOC = {
		type = "concept",
		name = "LocalisedString",
		desc = [[
		Localised strings are a way to support translation of in-game text. It is an array where the first element is the key and the remaining elements are parameters that will be substituted for placeholders in the template designated by the key.  
		The key identifies the string template. For example, "gui-alert-tooltip.attack" (for the template "__1__ objects are being damaged"; see the file data/core/locale/en.cfg).  
		The template can contain placeholders such as __1__ or __2__. These will be replaced by the respective parameter in the LocalisedString. The parameters themselves can be other localised strings, which will be processed recursively in the same fashion.  
		As a special case, when the key is just the empty string, the first parameter will be used as is.  
		Furthermore, when an API function expects a localised string, it will also accept a regular string (i.e. not a table) which will not be translated, or number which will be converted to its textual representation.  
		]],
		notes = {"See [API  documentation](http://lua-api.factorio.com/latest/Concepts.html#LocalisedString) for details."},
	}},
}
