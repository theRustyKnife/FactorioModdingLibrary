--/ remote
--- Allows easy access to functions through the remote API.
--- The functions returned from here are mostly closures, so they're not safe for serialization. To serialize an
--- interface function, use the Callback concept. To serialize an interface, simply store it's name as a string.

module({name='remote', 'RUNTIME', 'RUNTIME_SHARED'}, function(_M)
	local FML = therustyknife.FML
	local table = therustyknife.FML.table


	local function get_function_internal(clbck)
	--[[ Get the interface function without checking if it exists. ]]
		return function(...) return remote.call(clbck.interface, clbck.func, ...); end
	end

	local function get_function_safe_internal(clbck)
	--[[ Get the interface function as a safe function. ]]
		return function(...)
			if remote.interfaces[interface] and remote.interfaces[interface][func] then
				return remote.call(clbck.interface, clbck.func, ...)
			end
		end
	end


	function _M.get_interface(interface, safe)
	--- Return all functions from an interface.
	--- If the interface doesn't exist, nil is returned. If safe is true, an empty table is returned instead.
	--* Only functions that are currently present in the interface are taken into account, even if safe is true.
	--@ string interface: The interface name
	--@ bool safe=false: If true, safe functions are returned
	--: Dictionary[string, function]: The interface represented by a table of functions
		if not remote.interfaces[interface] then return safe and {} or nil; end
		local res = {}
		for func, _ in pairs(remote.interfaces[interface]) do
			if safe then
				res[func] = get_function_safe_internal{interface = interface, func = func}
			else
				res[func] = get_function_internal{interface = interface, func = func}; end
		end
		return res
	end


	function _M.get_function_safe(clbck)
	--- Return a function representing the given Callback.
	--- This function is safe to call even if the interface function is not currently available. Additionally, the
	--- function is returned even if the interface doesn't exist (yet), so calling it should always be safe.
	--@ Callback clbck: The function to get
	--: function: The safe function
		return get_function_safe_internal(clbck)
	end
	
	function _M.get_function(clbck)
	--- Get a function from an interface.
	--- If the interface doesn't exist, nil will be returned.
	--* If the interface is removed, calling this function will crash.
	--@ Callback clbck: The function to get
	--: function: The function
		if not remote.interfaces[clbck.interface] or not remote.interfaces[clbck.interface][clbck.func] then return nil; end
		
		return get_function_internal(clbck)
	end


	local function _callback_call_method(clbck, ...) return remote.call(clbck.interface, clbck.func, ...); end
	local RICH_MT = {__call = _callback_call_method}
	
	function _M.enrich_callback(clbck)
	--- Give the Callback a call method.
	--- This method is probably not serialization-safe.
	--* The callback is also given a metatable that allows you to call it directly. This metatable is lost during serialization entirely.
	--@ Callback clbck: The Callback to enrich
	--: RichCallback: The enriched Callback. It is the isntance that was passed in
		clbck.call = _callback_call_method
		setmetatable(clbck, RICH_MT)
		return clbck
	end

	function _M.get_rich_callback(interface, func)
	--- Construct a Callback that is already rich.
	--@ string interface: The interface the Callback will represent
	--@ string func: The function the Callback will represent
	--: RichCallback: The constructed Callback
		return _M.enrich_callback{interface = interface, func = func}
	end

	function _M.call(clbck, ...)
	--- Call the given Callback.
	--- Any parameters except the Callback will be passed to the function.
	--@ Callback clbck: What to call
	--@ Any ...: Any parameters to be passed to the called function
	--: ...: Any values returned by the called function
		return _callback_call_method(clbck, ...)
	end
	
	function _M.add_interface(name, module, generate_getters, overwrite, ignore_tables)
	--- Expose an interface through the remote API.
	--- Care needs to be taken with getters, as constants with nil value will not have a getter generated. Moreover, if
	--- the getter should clash with any name already in the module, it won't be generated either.
	--@ string name: The name of the new interface
	--@ Module module: The module to be exposed as an interface
	--@ {bool, string} generate_getters='get_': If true, constants will have getter functions generated. If it is a string, it will be used as the prefix for the getter functions' names
	--@ bool overwrite=false: If true, existing interface will be overwritten, otherwise nothing will happen
	--@ bool ignore_tables=false: If true, only non-table constants are taken into account
	--: bool: true if the interface was successfully exposed, false otherwise
		if remote.interfaces[name] then
			if overwrite then remote.remove_interface(name)
			else return false
			end
		end
		
		generate_getters = generate_getters == nil or generate_getters
		if generate_getters and type(generate_getters) ~= "string" then generate_getters = "get_"; end
		
		local interface = {}
		for name, value in pairs(module) do
			local t = type(value)
			if t == "function" then interface[name] = value
			elseif generate_getters and not module[generate_getters..name]
					and not (ignore_tables and type(value) == "table") then
				-- Index the value from module, to support changes of the value.
				interface[generate_getters..name] = function() return module[name]; end
			end
		end
		
		remote.add_interface(name, interface)
		
		return true
	end

	
	local to_call = table()
	function _M.call_when_loaded(func, ...)
	--- Call a given remote function now or once remote calls become available.
	--* The return values of the call are discarded, as it's not guaranteed the call will run immediately.
	--@ {function, Callback} func: The function to call
	--@ Any ...: The parameters to pass to the function
		if type(func) == "table" then func = _M.get_function(func); end
		if not pcall(func, ...) then to_call:insert{func = func, args = {...}}; end
	end
	FML.events.on_load(function() for _, v in ipairs(to_call) do v.func(unpack(v.args)); end end)


	--TODO: Callback handling - simple way to generate a callback from a function, where FML is going to handle exposing the
	-- interface.
end)
