-- The function bellow will be serialized and run in the console environment when called. It uses the same config as the
-- main FML mod, so go edit that to change it.
-- Usage: /c loadstring(remote.call("therustyknife.FML.console", "get"))()()
-- Running that command will load FML into a global variable named FML. The statement also returns the FML instance if
-- that's what you want.
return function()
	-- Load FML from the serialized interface - Pretty much the same as the local FML loading script
	local FML_import = next(remote.interfaces['therustyknife.FML.serialized']); FML_import = loadstring(FML_import)()
	FML_import.module{}.init{module=FML_import.FML, stage='RUNTIME', args={local_config={MOD={NAME='console'}}}}
	FML = therustyknife.FML
	
	-- Simulate the initialization events
	--TODO: perhaps implement the config_change event?
	--TODO: figure out what the hell did I mean by the above...
	-- - Update: It was probably to migrate the global table structure and stuff
	local global = FML.get_fml_global("console")
	if not global.__VERSION then
		FML.events.run_init(true)
		global.__VERSION = FML.VERSION
	end
	FML.events.run_load(true)
	
	FML.log.d("FML console loaded successfully.")
	
	return FML
end
