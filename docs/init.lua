return {
	JUNCTION = {
		NAME = "Modules",
		HEADER_TEXT = "This is a list of all the modules and concepts in FML.",
		CATEGORIES = {
			{
				name = "module",
				title = "Modules",
			},
			{
				name = "class",
				title = "Classes",
			},
			{
				name = "type",
				title = "Types",
			},
			{
				name = "concept",
				title = "Concepts",
			},
		},
	},
	DOCS = {
		RichTable = {_DOC = {
			type = "concept",
			name = "RichTable",
			short_desc = "A table that has various methods for it's manipulation.",
			desc = [[
			A table that has various methods for it's manipulation. It is basically a table with it's metatable set to
			the table module. This allows you to use all the functions from there as methods of `RichTable`s
			using the colon syntax.
			]],
			notes = {"You can find the functions usable from `RichTable`s on the tabletable module page."},
		}},
		VanillaPrototype = {_DOC = {
			type = "concept",
			name = "VanillaPrototype",
			short_desc = "A prototype in the same format as vanilla Factorio uses them.",
			desc = [[
			A prototype in the same format as vanilla Factorio uses them. In some places in FML, VanillaPrototype can be
			specified as incomplete, for example when specifying base for data.make.
			]],
		}},
		RichPrototype = {_DOC = {
			type = "concept",
			name = "RichPrototype",
			short_desc = "A prototype definition with special abilities.",
			desc = [[
				A prototype that can contain special fields for easier definition. The format is the same as in
				VanillaPrototype, with these two differences:  
				#### Special Funtions ####  
				In any prototype definition, you can put functions in some fields, which will then get called when
				appropriate. The special fields are:  
				* `_each` - gets called for every field in the table this field is in (non-recursive)  
				* `_tabs` - gets called for every table-type field in the table this field is in (non-recursive)  
				* `_vals` - gets called for every non-table-type fild in the table this field is in (non-recursive)  
				Additionally, if a function is specified in place of any other attribute, it will be called for that
				attribute.  
				The functions are called with the following parameters:  
				* *Any* val - the original value of the attribute (nil if not present)  
				* *string* name - the name of the attribute AKA the index in the table  
				* *function* set - a function that sets the parameter it was called with to the attribute  
				If the function did not call set, any non-nil return value will be set to the attribute. Therefore,
				using the set function is really only necessary if you want to set nil to the attribute. If the function
				did not set the attribute value in any of the above ways, the original value will be preserved.  
				
				#### Special Attributes ####
				In any prototype definition you can put a special table in the `_for` field. The table has the following
				structure:  
				``{
				``	names = Array[string], -- The attribute names to use
				``	set = Any, -- The value to set to the above attributes
				``}  
				This sets every attribute from the names Array in the table this _for is contained in to the value of
				set. This is useful when setting multiple attributes to the same value.
			]],
		}},
		SimpleRecipePrototype = {_DOC = {
			type = "concept",
			name = "SimpleRecipePrototype",
			short_desc = "A shortened recipe prototype definition.",
			desc = [[
			A recipe prototype expressed in the following format:  
			``{
			``	base = VanillaPrototype, -- Same as in Prototype
			``	properties = RichPrototype, -- Same as in Prototype
			``	unlock_with = string, -- The technology name to add this recipe to, default nil
			``}  
			]],
		}},
		SimpleItemPrototype = {_DOC = {
			type = "concept",
			name = "SimpleItemPrototype",
			short_desc = "A shortened item prototype definition.",
			desc = [[
			An item prototype expressed in the following format:  
			``{
			``	base = VanillaPrototype, -- Same as in Prototype
			``	properties = RichPrototype, -- Same as in Prototype
			``	set_minable_result = bool, -- If true, the entity's minable will have this item as result
			``}
			]],
		}},
		Prototype = {_DOC = {
			type = "concept",
			name = "Prototype",
			short_desc = "FML's extended prototype definition.",
			desc = [[
			An extended prototype definition format used by FML. The format is as follows:
			``{
			``	base = VanillaPrototype, -- The prototype to use as base, can be nil if properties defines a full prototype
			``	properties = RichPrototype, -- The properties of this prototype, if nil, the same exact prototype as base will be generated
			``	generate = table, -- This is an optional table that allows you to tell FML to generate certain things for you
			``}  
			The generate table can contain either strings denoting what to generate (i.e. "item" or "recipe") or
			SimpleItemPrototype or SimpleRecipePrototype on the respective indices.
			]],
		}},
		Array = {_DOC = {
			type = "concept",
			name = "Array",
			short_desc = "A numerically indexed table.",
			desc = [[
			A table, indexed by ascending indices starting from 1. The `#` operator can be used to get the length of such
			array. The length operator merely returns the value of the `n` field, which can be changed by the user, but
			is mostly handled by the table functions.
			]],
		}},
		bool = {_DOC = {
			type = "type",
			name = "bool",
			short_desc = "A truth value, `true` or `false`.",
			desc = [[
			A truth value, `true` or `false`. Usually, anything that can be tested for truthiness, can be used as a bool
			value. This means anything except `nil` and `false` is `true`.
			]],
		}},
		Semver = require "Semver",
	},
}
