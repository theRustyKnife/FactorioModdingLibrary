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
		vanilla_concepts = require "vanilla-concepts",
		types = require "types",
		Semver = require "Semver",
		blueprint_data = require "blueprint-data",
	},
}
