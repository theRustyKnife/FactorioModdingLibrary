return {
	-- If true, errors from module loading will not be ignored
	FORCE_LOAD_MODULES = true,
	-- If true, errors in module loading will be logged
	LOG_MODULE_ERRORS = true,
	
	MODULES_TO_LOAD = {
		log = "modules.log",
		remote = "modules.remote",
	},
	
	
	LOG = {
		IN_CONSOLE = true,
		
		E = true,
		D = true,
	},
}
