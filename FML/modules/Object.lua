return function(_M)
	local FML = therustyknife.FML
	
	
	local _DOC = FML.make_doc(_M, {
		type = "class",
		name = "Object",
		short_desc = "A base class for objects in Lua.",
		desc = [[
		A base class for objects in Lua. Supports all the basic operations such as creating new objets of a type and
		inheritance.  
		Additionally, also allows for simple loading of objects after serialization, where metatables get lost.
		]],
		notes = {
		[[
		The load function has to be called for every object, that is to be used, after game load. Ideally, this would be
		done in the `load` event.
		]],
		[[
		Any class derived from Object can be instantiated using the __call metamethod. This may not be mentioned in the
		documentation, as it is the same as the `new` method.
		]],
		"A lot of the functionality of this module uses metatables, so be careful with setting/resetting them.",
		},
	})
	
	local function mt(type) return {__index = type}; end
	
	_DOC.new = {
		type = "method",
		desc = [[ Create a new object. ]],
		returns = {
			{
				type = "Object",
				desc = "The newly created object",
			},
		},
	}
	function _M:new() return setmetatable({}, mt(self)); end
	
	_DOC.load = {
		type = "method",
		desc = [[ Re-setup an Object after load. ]],
		params = {
			{
				type = "Object",
				name = "object",
				desc = "The Object to load",
			},
		},
		returns = {
			{
				type = "Object",
				desc = "The loaded object (the same reference as passed in)",
			},
		},
	}
	function _M:load(object) return setmetatable(object, mt(self)); end
	
	_DOC.extend = {
		type = "method",
		short_desc = "Create a subcless of this class.",
		desc = [[
		Create a subclass of this class. Handles all the necessary technicalities of setting up the metatables and
		allows to override the cosntructor of the parent class.  
		The constructor is the function that will be responsible for creating the new objects. If a call to the
		superconstructor without parameters succeeds, the result will be passed as the first argument, otherwise it will
		be false. In such case, the constructor must call the superconstructor explicitly.  
		Additionally, the super field is created, which allows easy access to the superclass.
		]],
		params = {
			{
				type = "function",
				name = "constructor",
				desc = "The constructor for the new class",
			},
		},
		returns = {
			{
				type = "Subclass",
				desc = "The new subclass",
			},
		},
	}
	function _M:extend(constructor)
		local const
		if constructor ~= nil then
			const = function(type, ...)
				local ok, res = pcall(self.new, type)
				return constructor(ok and res or type, ...)
			end
		else const = self.new; end
		return setmetatable({
				super = setmetatable({}, mt(self)),
				new = const,
			}, {
				__index = self,
				__call = const,
			})
	end
	
	_DOC.destroy = {
		type = "method",
		short_desc = "A method for cleanup of objects.",
		desc = [[
		A method intended for cleanup of objects. In Object, the method is empty.  
		Any class that defines a destroy method, should call the destroy from it's superclass in it.
		]],
	}
	function _M:destroy() end
	
	setmetatable(_M, {__call = _M.new})
end
