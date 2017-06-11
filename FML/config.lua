return {
	-- If true, errors from module loading will not be ignored
	FORCE_LOAD_MODULES = true,
	-- If true, errors in module loading will be logged
	LOG_MODULE_ERRORS = true,
	
	-- Modules with their paths that FML will attempt to load
	MODULES_TO_LOAD = {
		log = ".modules.log",
		remote = ".modules.remote", -- The remote module is essential for FML to function and thus, it has to be present.
		table = ".modules.table",
	},
	
	
	LOG = {
		-- If true, log messages will be printed to the console as well
		IN_CONSOLE = true,
		
		-- If true, the respective level messsages will be logged. If false, the functions are replaced with empty ones,
		-- so it's safe to leave the calls in, without much performance loss.
		E = true,
		D = true,
	},
}
