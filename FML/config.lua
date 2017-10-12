return {
	VERSION = {
		CODE = 18,
		NAME = '0.1.0-alpha.10.0',
	},
	
	-- Mod info
	MOD = {NAME = "FML"},
	
	-- If true, errors from module loading will not be ignored
	FORCE_LOAD_MODULES = true,
	-- If true, errors in module loading will be logged
	LOG_MODULE_ERRORS = true,
	
	
	LIB_DATA_DUMP_PATH = {
		ROOT = "lib_data",
		DEFINES = "defines",
	},
	
	-- This determines where FML will store it's stuff
	GLOBAL =  {
		NAMESPACE = 'therustyknife',
		PACKAGE = 'FML',
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
			CLOSE_KEY_OVERRIDE = "FML_close-entity-gui-override",
		},
	},
	
	
	BLUEPRINT_DATA = {
		PROTOTYPE_NAME = "FML_blueprint-data_entity_",
		ICON = "__base__/graphics/icons/blueprint-book.png",
		DEFAUL_COLLISION_BOX = {{0, 0}, {0, 0}},
		ITEM_NAME = "FML_blueprint-data_item",
	},
}
