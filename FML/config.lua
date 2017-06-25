return {
	-- FML version info
	VERSION = {
		NAME = "0.1.0-alpha.4.1",
		CODE = 6,
	},
	
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
		{name = "data_container", path = ".modules.data_container"},
		{name = "events", path = ".modules.events"},
		{name = "GUI", path = ".modules.GUI"},
		{name = "Semver", path = ".modules.Semver"},
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
		},
		
		-- The default minable values
		DEFAULT_MINABLE = {hardness = 0.2, mining_time = 0.5},
		
		-- The default recipe base with some default ingredients
		RECIPE_BASE = {
			type = "recipe",
			ingredients = {{"iron-plate", 20}},
		},
	},
	
	
	GUI = {
		NAMES = {
			OPEN_KEY = "FML_open-entity-gui",
			CLOSE_KEY = "FML_close-entity-gui",
		},
	},
	
	
	DATA_CONTAINER = {
		PROTOTYPE_NAME = "FML_data-container-item",
	},
}
