--/ log
--- Utility for logging.
--- Can print log messages to the console as well, according to the configuration from config.

return function(_M)
	local FML = therustyknife.FML
	local config = therustyknife.FML.config


	--TODO: allow using mod name as tag automatically
	--TODO: logging to file (named 'tag'.log to allow individual files for each mod)
	--TODO: add tickstamp to logs
	--TODO: log loading saves or clear log on load?
	--TODO: log to file/console only for certain players?

	
	local log = _G.log -- Save the vanilla log function to prevent inifinite recursion issues
	local function empty() end

	local print
	if config.LOG.IN_CONSOLE then
		print = function(message)
			if game and game.print then game.print(message); end
			log(message)
		end
	else print = log; end


	--TODO: buffer messages
	--TODO: print the messages during loading to console once game is available


	function _M.get_location(level)
	--- Get a string designating the current execution location of the script.
	--* If the info can't be obtained (too high stack level), "unknown" will be printed.
	--@ uint level=2: Which level of the stack to consider
	--: string: The location with line number
		local info = debug.getinfo(level or 2)
		if not info then return "unknown"; end
		local res = info.name
		if res == nil or res == "" then res = info.short_src; end
		return res..":"..info.currentline
	end


	if config.LOG.D then
		function _M.d(message, level)
		--- Print a debug level message to the log.
		--@ Any message: The message to be printed. Non-string messages are converted with tostring.
			print(_M.get_location(level or 3)..":Debug: "..tostring(message))
		end
	else _M.d = empty; end

	if config.LOG.W then
		function _M.w(message, level)
		--- Print a warning level message to the log.
		--@ Any message: The message to be printed. Non-string messages are converted with tostring.
			print(_M.get_location(level or 3)..":Warning: "..tostring(message))
		end
	else _M.w = empty; end

	if config.LOG.E then
		function _M.e(message, level)
		--- Print an error level message to the log.
		--@ Any message: The message to be printed. Non-string messages are converted with tostring.
			print(_M.get_location(level or 3)..":Error: "..tostring(message))
		end
	else _M.e = empty; end
	
	if config.LOG.D then
		local ser_func = serpent.line
		function _M.set_ser_func(func)
		--- Set the function that dump will use for conversion to string.
		--- This function has to take the value as argument and return a string representing the value. This is set to
		--- serpent.line by default.
		--@ function func: The function to use
			ser_func = func
		end
		
		function _M.dump(message, ...)
		--- Dump some values into the log.
		--- The function set by set_ser_func will be used for converting to string. It is considered to be a debug level
		--- message.
		--@ {string, Any} message: If string, it gets printed straight away, otherwise it's considered one of the values
		--@ Any ...: The values to be dumped
			local args = FML.table.pack(...)
			local res = (args.n > 0 and type(message) == "string" and message)
					or (ser_func(message)..(args.n > 0 and ", " or ""))
			local first = true
			for i = 1, args.n do
				res = res..(not first and ", " or "")..ser_func(args[i])
				first = false
			end
			_M.d(res, 4)
		end
	else _M.dump = empty; _M.set_ser_func = empty; end
	
	
	--f __call
	--% type: metamethod
	--- Same as `log.d`.
	--* Mainly exists for compatibility with the built-in log function. It's recommended to use `log.d` instead.
	--@ Any message: The message to be printed. Non-string messages are converted with tostring.
	if config.LOG.D then setmetatable(_M, {__call = function(_, message) _M.d(message); end})
	else setmetatable(_M, {__call = empty}); end
end
