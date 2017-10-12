local module = require 'script.module'
local safe_require = require 'script.safe_require'


module.import{path='script.FML-main', stage='SETTINGS', load_func=safe_require}
