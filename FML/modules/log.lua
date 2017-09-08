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


	local _DOC, _MT = FML.make_doc(_M, {
		type = "module",
		name = "log",
		short_desc = "Utility for logging.",
		desc = [[
		Utility for logging. Can print log messages to the console as well, according to the configuration from config.
		]],
	})
	--TODO: buffer messages
	--TODO: print the messages during loading to console once game is available


	_DOC.get_location = {
		type = "function",
		desc = [[ Get a string designating the current execution location of the script. ]],
		notes = {"If the info can't be obtained (too high stack level), \"unknown\" will be printed."},
		params = {
			{
				type = "uint",
				name = "level",
				desc = "Which level of the stack to consider",
				default = "2",
			},
		},
		returns = {
			{
				type = "string",
				desc = "The location with line number",
			},
		},
	}
	function _M.get_location(level)
		local info = debug.getinfo(level or 2)
		if not info then return "unknown"; end
		local res = info.name
		if res == nil or res == "" then res = info.short_src; end
		return res..":"..info.currentline
	end


	_DOC.d = {
		type = "function",
		desc = [[ Print a debug level message to the log. ]],
		params = {
			{
				type = "Any",
				name = "message",
				desc = "The message to be printed. Non-string messages are converted with tostring.",
			},
		},
	}
	if config.LOG.D then
		function _M.d(message, level)
			print(_M.get_location(level or 3)..":Debug: "..tostring(message))
		end
	else _M.d = empty; end

	_DOC.w = {
		type = "function",
		desc = [[ Print a warning level message to the log. ]],
		params = {
			{
				type = "Any",
				name = "message",
				desc = "The message to be printed. Non-string messages are converted with tostring.",
			},
		},
	}
	if config.LOG.W then
		function _M.w(message, level)
			print(_M.get_location(level or 3)..":Warning: "..tostring(message))
		end
	else _M.w = empty; end

	_DOC.e = {
		type = "function",
		desc = [[ Print an error level message to the log. ]],
		params = {
			{
				type = "Any",
				name = "message",
				desc = "The message to be printed. Non-string messages are converted with tostring.",
			},
		},
	}
	if config.LOG.E then
		function _M.e(message, level)
			print(_M.get_location(level or 3)..":Error: "..tostring(message))
		end
	else _M.e = empty; end
	
	_DOC.dump = {
		type = "function",
		short_desc = "Dump some values into the log.",
		desc = [[
		Dump some values into the log using the ser_func function. It is assumed to be a debug level message.
		]],
		params = {
			{
				type = {"string", "Any"},
				name = "message",
				desc = [[
				If this is string, it gets printed straight away, otherwise it is considered to be one of the values
				]],
			},
			{
				type = "Any",
				name = "...",
				desc = "The values to be dumped",
			},
		},
	}
	_DOC.set_ser_func = {
		type = "function",
		short_desc = "Set the function that dump will use for conversion to string.",
		desc = [[
		Set the function that dump will use for conversion to string. This function has to take the value as argument
		and return a string representing the value. This is set to serpent.line by default.
		]],
		params = {
			{
				type = "function",
				name = "func",
				desc = "The function to use",
			},
		},
	}
	if config.LOG.D then
		local ser_func = serpent.line
		function _M.set_ser_func(func) ser_func = func; end
		
		function _M.dump(message, ...)
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
	
	
	_MT.__call = {
		desc = [[ Same as `log.d`. ]],
		notes = {"Mainly exists for compatibility with the built-in log function. It's recommended to use `log.d` instead."},
		params = _DOC.d.params,
	}
	if config.LOG.D then setmetatable(_M, {__call = function(_, message) _M.d(message); end})
	else setmetatable(_M, {__call = empty}); end
end
