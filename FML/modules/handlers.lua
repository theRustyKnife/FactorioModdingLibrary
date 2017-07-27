return function(_M)
	local FML = therustyknife.FML
	
	
	if FML.STAGE ~= "runtime" then return nil, true; end
	
	
	--TODO: find a better name for this module - handlers is dumb and misleading
	local _DOC = FML.make_doc(_M, {
		type = "module",
		name = "handlers",
		short_desc = "Allows defining functions that code can rely on existing through save/load.",
		desc = [[
		Allows defining functions that code can rely on existing through save/load.
		
		The functions are defined somewhat like prototypes - only during the initial phase of the runtime stage. This is
		to prevent desync issues caused by the the mods persisting state in other places than the global table. Functions
		can't be (easily) serialized, so this module aims to provide some compromise for passing functions around.
		]],
		notes = {[[
		It is a responsibility of the function author to ensure any functions passed to other code are accessible when
		they're needed. If they're not, the return call is just going to be ignored.
		]],
		[[
		Be careful when reusing function names, as code that got the previous function passed, might call the new function
		in inapropriate situations. For this reason, it is advised to use unique names for any functions within the mod.
		]],
		[[
		Since FML can also use this module to store functions, it is recommended to use the standard naming scheme
		(`author-name.mod-name.value-name`) to avoid clashes.
		]],
		},
	})
	
	
	local handlers = {}
	
	_DOC.add = {
		desc = [[ Add a new handler function. ]],
		params = {
			{
				type = "string",
				name = "name",
				desc = "The name of the handler function",
			},
			{
				type = "function",
				name = "func",
				desc = "The handler function",
			},
		},
		returns = {
			{
				type = "string",
				desc = "The name of the function",
			},
		},
	}
	function _M.add(name, func)
		assert(handlers[name] == nil, "A handler function with name "..tostring(name).." already exists.")
		assert(type(func) == "function", "Wrong type of argument 'func' (expected function, got "..type(func)..")")
		handlers[name] = func
		return name
	end
	
	_DOC.call = {
		desc = [[ Attempt to call a handler function. ]],
		params = {
			{
				type = "string",
				name = "name",
				desc = "The name of the function to call",
			},
			{
				type = "Any",
				name = "...",
				desc = "Any arguments to pass to the function",
			},
		},
		returns = {
			{
				type = "bool",
				desc = "Indicates the success of the call - `true` if successful, `false` if not",
			},
			{
				type = "...",
				desc = "Any values returned by the call",
			},
		},
	}
	function _M.call(name, ...)
		if handlers[name] then return true, handlers[name](...); end
		return false
	end
end
