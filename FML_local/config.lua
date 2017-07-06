return {
	-- FML version info
	VERSION = {
		NAME = "0.1.0-alpha.4.1",
		CODE = 6,
	},
	
	
	-- Settings that need to be configured to reflect the mod FML is installed in
	MOD = {
		NAME = "FML-client-test",
	},
	
	
	-- Modules with their paths that FML will attempt to load
	MODULES_TO_LOAD = {
		{name = "log", path = ".modules.log"},
		{name = "remote", path = ".modules.remote"},
		{name = "table", path = ".modules.table"},
		{name = "format", path = ".modules.format"},
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
}
