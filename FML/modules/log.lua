local FML = require "therustyknife.FML"
local config = require "therustyknife.FML.config"


--TODO: allow using mod name as tag automatically
--TODO: logging to file (named 'tag'.log to allow individual files for each mod)
--TODO: add tickstamp to logs
--TODO: log loading saves or clear log on load?
--TODO: log to file/console only for certain players?

local function empty() end

local print
if config.LOG.IN_CONSOLE then
	print = function(message)
		if game and game.print then game.print(message); end
		log(message)
	end
else print = log; end


_M = {}
--[[ Utility for logging. Can print log messages to the console as well, according to the configuration from config. ]]


if config.LOG.D then
	function _M.d(message, tag)
		print((tag and (tag.." - ") or "").."Debug: "..tostring(message))
	end
else _M.d = empty; end

if config.LOG.E then
	function _M.e(message, tag)
		print((tag and (tag.." - ") or "").."Error: "..tostring(message))
	end
else _M.e = empty; end


return _M
