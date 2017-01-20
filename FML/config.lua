local config = {}


-- GENRAL --
-- The module names with paths that init will attempt to load
config.MODULES_TO_LOAD = {
	Object = ".modules.Object",
	surface = ".modules.surface",
	table = ".modules.table",
	events = ".modules.events",
	data = ".modules.data",
	format = ".modules.format",
	gui = ".modules.gui.init",
}

-- If set to true modules won't be loaded using pcall, therefore crashing if there are errors - good for debugging
config.FORCE_LOAD_MODULES = true

-- The name of the global table FML will use. You shouldn't need to change this unless you have a global table with my name for some reason...
config.GLOBAL_NAME = "therustyknife"


-- EVENTS --
-- Setting this to true will disable FML's event handlers. It's recommended to keep this set to false as some modules' (including events) functionality might be limited otherwise.
config.USE_NORMAL_HANDLERS = false


-- DATA --
-- Default icon to use where none was specified and it's mandatory
config.DEFAULT_ICON_PATH = "__core__/graphics/clear.png"

-- The default base for auto-generated items
config.ITEM_BASE = {
	type = "item",
	icon = DEFAULT_ICON_PATH,
	flags = {"goes-to-quickbar"},
	subgroup = "transport",
	order = "unspecified",
	stack_size = 50,
}

-- The default base for auto-generated recipes
config.RECIPE_BASE = {
	type = "recipe",
	enabled = false,
}

-- Default minable values
config.DEFAULT_MINABLE = {hardness = 0.2, mining_time = 0.5}


return config
