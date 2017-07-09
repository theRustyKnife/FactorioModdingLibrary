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
		concepts = require "concepts",
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
		blueprint_data = require "blueprint-data",
	},
}
