local config = {}


-- GENRAL --
-- The name of the mod FML is installed in - will be used for checking on_configuration_changed
config.MOD_NAME = "FML-test"

-- If set to true modules won't be loaded using pcall, therefore crashing if there are errors - good for debugging
config.FORCE_LOAD_MODULES = true

-- The module names with paths that init will attempt to load
config.MODULES_TO_LOAD = {
	--Object = ".modules.Object",
	--surface = ".modules.surface",
	table = ".modules.table",
	events = ".modules.events",
	--data = ".modules.data",
	--format = ".modules.format",
	--gui = ".modules.gui.init",
}

-- The name of the global table FML will use. You shouldn't need to change this unless you have a global table with my name for some reason...
-- Changing this will likely break backwards compatibility.
config.GLOBAL_NAME = "therustyknife"


return config
