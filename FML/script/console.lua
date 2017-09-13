-- The function bellow will be serialized and run in the console environment when called.
-- Usage: /c loadstring(remote.call("therustyknife.FML.console", "get"))()()
-- Running that command will load FML into a global variable named FML. The statement also returns the FML instance if
-- that's what you want.
return function()
	local FML_import = next(remote.interfaces["therustyknife.FML.serialized"]); FML_import = loadstring(FML_import)()
	local module_loader = {}; FML_import.module_loader(module_loader)
	local FML_stdlib = module_loader.init(FML_import.FML_stdlib, nil, "RUNTIME")
	local config = FML_import.config
	
	FML = module_loader.load_std(FML_stdlib, nil, "RUNTIME", config, config.VERSION)
	FML_stdlib.put_to_global("therustyknife", "FML", FML)
	
	module_loader.init_all(FML, config.MODULES_TO_LOAD, "RUNTIME")
	
	-- Simulate the initialization events
	--TODO: perhaps implement the config_change event?
	local global = FML.get_fml_global("console")
	if not global.__VERSION then
		FML.events.sim_init()
		global.__VERSION = FML.VERSION
	end
	FML.events.sim_load()
	
	FML.log.d("FML console loaded successfully.")
	
	return FML
end
