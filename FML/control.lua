local module = require 'script.module'
local safe_require = require 'script.safe_require'


local loaded = {
	FML = module.load{path='script.FML-main', load_func=safe_require},
	module = module.load{path='script.module', load_func=safe_require}.func,
}
local FML_export = serpent.dump(loaded)
-- Hacky interface data pass :|
remote.add_interface("therustyknife.FML.serialized", {[FML_export] = function()end})

local FML = module.init{module=loaded.FML, stage='RUNTIME_SHARED'}

-- Usage: /c loadstring(remote.call("therustyknife.FML.console", "get"))()
local console = serpent.dump(module.load{path='script.console', load_func=safe_require}.func)
FML.remote.add_interface("therustyknife.FML.console", {get = function() return console; end})
