local FML_stdlib = require "script.FML-stdlib"
local module_loader = FML_stdlib.safe_require("script.module-loader", true)

local config = FML_stdlib.safe_require(".config", true)


local _M = module_loader.load_std(FML_stdlib, nil, "runtime")
package.loaded["therustyknife.FML"] = _M
package.loaded["therustyknife.FML.config"] = config


assert(config.MODULES_TO_LOAD["remote"], "FML couldn't find the remote module.")
 

--TODO: check if FML versions match

--TODO: load all the other modules installed locally
--TODO: load all the modules not installed locally, but available remotely


return _M
