local config = {
	-- Settings that need to be configured to reflect the mod FML is installed in
	MOD = {
		NAME = "FML-client-test",
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


------- END OF CONFIG -------


local FML_import = next(remote.interfaces["therustyknife.FML.serialized"]); FML_import = loadstring(FML_import)()
local module_loader = {}; FML_import.module_loader(module_loader)
local FML_stdlib = module_loader.init(FML_import.FML_stdlib)
config = FML_stdlib.merge_configs(config, FML_import.config)

local _M = module_loader.load_std(FML_stdlib, nil, "runtime", config, config.VERSION)
FML_stdlib.put_to_global("therustyknife", "FML", _M)
for _, module in ipairs(config.MODULES_TO_LOAD) do
	if FML_import.modules[module.name] then _M[module.name] = module_loader.init(FML_import.modules[module.name]); end
end
return _M
