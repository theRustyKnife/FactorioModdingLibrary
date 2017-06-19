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
		log = ".modules.log",
		remote = ".modules.remote", -- The remote module is essential for FML to function and thus, it has to be present
		table = ".modules.table",
		format = ".modules.format",
	},
}
