--/ handlers
--- Allows defining functions that code can rely on existing through save/load.
--- The functions are defined somewhat like prototypes - only during the initial phase of the runtime stage. This is to
--- prevent desync issues caused by the the mods persisting state in other places than the global table. Functions can't
--- be (easily) serialized, so this module aims to provide some compromise for passing functions around.
--* It is a responsibility of the function author to ensure any functions passed to other code are accessible when they're needed.
--* Be careful when reusing function names, as code that got the previous function passed might call the new function accidentally. **Use unique names for functions.**
--* Since FML can also use this module to store functions, it is recommended to use the standard naming scheme (`author-name.mod-name.value-name`) to avoid clashes.

--TODO: link to the naming convention doc (that doesn't exist now)
--TODO: find a better name for this module - handlers is dumb and misleading

module({'RUNTIME', 'RUNTIME_SHARED'}, function(_M)
	local FML = therustyknife.FML
	
	
	local handlers = {}
	
	function _M.add(name, func)
	--- Add a new handler function.
	--@ string name: The name of the handler function
	--@ function func: The handler function
	--: string: The name of the function
		assert(handlers[name] == nil, "A handler function with name "..tostring(name).." already exists.")
		assert(type(func) == "function", "Wrong type of argument 'func' (expected function, got "..type(func)..")")
		handlers[name] = func
		return name
	end
	
	function _M.call(name, ...)
	--- Attempt to call a handler function.
	--@ string name: The name of the function to call
	--@ Any ...: Any arguments to pass to the function
	--: bool: Indicates the success of the call - `true` if successful, `false` if not
	--: ...: Any values returned from the call
		if handlers[name] then return true, handlers[name](...); end
		return false
	end
end)
