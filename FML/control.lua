-- Load FML for other mods
local FML_stdlib = {}; require("script.FML-stdlib")(FML_stdlib)
local module_loader = {}; FML_stdlib.safe_require("script.module-loader", true)(module_loader)

local config = FML_stdlib.safe_require("config", true)


local load_func = FML_stdlib.safe_require
if config.FORCE_LOAD_MODULES then
	load_func = function(path) return FML_stdlib.safe_require(path, config.FORCE_LOAD_MODULES); end
end

local to_export = {
	config = config,
	FML_stdlib = FML_stdlib.safe_require("script.FML-stdlib"),
	module_loader = FML_stdlib.safe_require("script.module-loader"),
	console = serpent.dump(FML_stdlib.safe_require("script.console")),
	modules = {},
}
module_loader.load_from_files(config.MODULES_TO_LOAD, to_export.modules, load_func, false, log_func)
local serialized = serpent.dump(to_export)

-- Hacky interface data pass :|
remote.add_interface("therustyknife.FML.serialized", {[serpent.dump(to_export)] = function()end})


-- Load FML for the shared part
local FML_import = next(remote.interfaces["therustyknife.FML.serialized"]); FML_import = loadstring(FML_import)()


local module_loader = {}; FML_import.module_loader(module_loader)
local FML_stdlib = module_loader.init(FML_import.FML_stdlib, nil, "RUNTIME_SHARED")
local config = FML_stdlib.safe_require(".config")


local FML = module_loader.load_std(FML_stdlib, {}, "RUNTIME_SHARED", config, config.VERSION)
FML_stdlib.put_to_global("therustyknife", "FML", FML) -- Give global access to the library


module_loader.init_all(FML, FML_import.modules, config.MODULES_TO_LOAD, "RUNTIME_SHARED")


--[[
A function to allow for simple loading of FML. Intended for use in the console.
Usage: /c loadstring(remote.call("therustyknife.FML.console", "get"))()
--]]
FML.remote.add_interface("therustyknife.FML.console", {get = function() return FML_import.console; end})
