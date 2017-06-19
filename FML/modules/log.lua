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
local _DOC = FML.make_doc(_M, {
	type = "module",
	name = "log",
	desc = [[
	Utility for logging. Can print log messages to the console as well, according to the configuration from config.
	]],
})
--TODO: buffer messages
--TODO: print the messages during loading to console once game is available


_DOC.get_location = {
	type = "function",
	desc = [[ Get a string designating the current execution location of the script. ]],
	returns = {
		{
			type = "string",
			desc = "The location with line number",
		},
	},
}
function _M.get_location(level)
	local info = debug.getinfo(level or 2)
	if not info then return "remote"; end
	local res = info.name
	if res == nil or res == "" then res = info.short_src; end
	return res..":"..info.currentline
end


_DOC.D = {
	type = "function",
	desc = [[ Print a debug level message to the log. ]],
	params = {
		message = {
			type = "Any",
			desc = "The message to be printed. Non-string messages are converted with tostring.",
		},
	},
}
if config.LOG.D then
	function _M.d(message)
		print(_M.get_location(3)..":Debug: "..tostring(message))
	end
else _M.d = empty; end

_DOC.W = {
	type = "function",
	desc = [[ Print a warning level message to the log. ]],
	params = {
		message = {
			type = "Any",
			desc = "The message to be printed. Non-string messages are converted with tostring.",
		},
	},
}
if config.LOG.W then
	function _M.w(message)
		print(_M.get_location(3)..":Warning: "..tostring(message))
	end
else _M.w = empty; end

_DOC.E = {
	type = "function",
	desc = [[ Print an error level message to the log. ]],
	params = {
		message = {
			type = "Any",
			desc = "The message to be printed. Non-string messages are converted with tostring.",
		},
	},
}
if config.LOG.E then
	function _M.e(message)
		print(_M.get_location(3)..":Error: "..tostring(message))
	end
else _M.e = empty; end


return _M
