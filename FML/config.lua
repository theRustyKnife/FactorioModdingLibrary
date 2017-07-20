return {
	-- FML version info obtained from the version history file
	VERSION = require("script.version-util").config(),
	
	-- If true, errors from module loading will not be ignored
	FORCE_LOAD_MODULES = true,
	-- If true, errors in module loading will be logged
	LOG_MODULE_ERRORS = true,
	
	-- Modules with their paths that FML will attempt to load
	MODULES_TO_LOAD = {
		{name = "log", path = ".modules.log"},
		{name = "remote", path = ".modules.remote"},
		{name = "table", path = ".modules.table"},
		{name = "format", path = ".modules.format"},
		{name = "data", path = ".modules.data"},
		{name = "events", path = ".modules.events"},
		{name = "GUI", path = ".modules.GUI"},
		{name = "Semver", path = ".modules.Semver"},
		{name = "prototype_util", path = ".modules.prototype-util"},
		{name = "Object", path = ".modules.Object"},
		{name = "blueprint_data", path = ".modules.blueprint-data.init"},
		{name = "surface", path = ".modules.surface"},
		{name = "random_util", path = ".modules.random-util"},
	},
	
	-- The name of the item that's used for saving modules
	FML_SETTING_NAME = "FML_FML-hack-setting",
	
	LIB_DATA_DUMP_PATH = {
		ROOT = "lib_data",
		DEFINES = "defines",
	},
	
	
	LOG = {
		-- If true, log messages will be printed to the console as well
		IN_CONSOLE = true,
		
		-- If true, the respective level messsages will be logged. If false, the functions are replaced with empty ones,
		-- so it's safe to leave the calls in, without much performance loss.
		E = true,
		W = true,
		D = true,
	},
	
	
	DATA = {
		PATH = {
			NO_ICON = "__FML__/graphics/icons/clear.png",
			TRANS = "__FML__/graphics/util/trans.png",
		},
		
		-- The default minable values
		DEFAULT_MINABLE = {hardness = 0.2, mining_time = 0.5},
		
		-- The default recipe base with some default ingredients
		RECIPE_BASE = {
			type = "recipe",
			ingredients = {{"iron-plate", 20}},
		},
		
		-- Possible prototype types of recipe results
		RESULT_TYPES = {"item", "module", "tool", "fluid", "ammo"},
		-- Possible types of items, that is things that can be put into an inventory
		ITEM_TYPES = {"item", "module", "tool", "ammo"},
	},
	
	
	GUI = {
		NAMES = {
			OPEN_KEY = "FML_open-entity-gui",
			CLOSE_KEY = "FML_close-entity-gui",
		},
	},
	
	
	BLUEPRINT_DATA = {
		PROTOTYPE_NAME = "FML_blueprint-data_entity_",
		ICON = "__base__/graphics/icons/blueprint-book.png",
		DEFAUL_COLLISION_BOX = {{0, 0}, {0, 0}},
		ITEM_NAME = "FML_blueprint-data_item",
	},
	
	DATA_CONTAINER = {
		PROTOTYPE_NAME = "FML_data-container-item",
	},
}
