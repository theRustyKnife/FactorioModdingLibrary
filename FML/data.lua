local module = require 'script.module'
local safe_require = require 'script.safe_require'


module.import{path='script.FML-main', stage='DATA', load_func=safe_require}

--TODO: allow mods to load separate instances using their configs?
