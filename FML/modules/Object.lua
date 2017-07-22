return function(_M)
	local FML = therustyknife.FML
	local table = FML.table
	local log = FML.log
	
	
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
	
	
	--TODO: allow explicitly adding objects to the global table via a method to compensate for the inability to properly
	-- create objects before load
	local classes = table()
	local global
	if FML.STAGE == "runtime" then
		FML.events.on_delayed_load(function()
			global = table(FML.get_fml_global("Object"))
			for _, object in ipairs(global) do
				if classes[object.__class_name] then classes[object.__class_name]:load(object)
				else log.w("Couldn't find class '"..object.__class_name.."' to load an object."); end
			end
		end)
	end
	
	
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
	function _M:new()
		local res = {}
		if self.__class_name then
			if global then
				res.__class_name = self.__class_name
				global:insert(res)
			else log.w("Creating an object of type '"..self.__class_name.."' before global is accessible"); end
		end
		res.__type_name = res.__class_name or tostring(self)
		return setmetatable(res, mt(self))
	end
	
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
	function _M:load(object)
		if not object.__class_name then object.__type_name = tostring(self):sub(("table: "):len()+1, -1); end
		return setmetatable(object, mt(self))
	end
	
	_DOC.extend = {
		type = "method",
		short_desc = "Create a subclass of this class.",
		desc = [[
		Create a subclass of this class. Handles all the necessary technicalities of setting up the metatables and
		allows to override the cosntructor of the parent class.  
		The constructor is the function that will be responsible for creating the new objects. If a call to the
		superconstructor without parameters succeeds, the result will be passed as the first argument, otherwise it will
		be false. In such case, the constructor must call the superconstructor explicitly.  
		Additionally, the super field is created, which allows easy access to the superclass.  
		
		Either of the parameters may be omitted:  
		 - If name is omitted, objects will have to be loaded manually. Also, instantiating any named objects before
		 global is accessible for writing will cause them to not be saved for loading.  
		 - If constructor is omitted, the superclass's constructor will be used.  
		]],
		params = {
			{
				type = "string",
				name = "name",
				desc = "The name of the new class, will be used for loading - has to be unique", --TODO: make a naming convention wiki page explaining the formats (author.mod-name.ObjectName in this case)
			},
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
	function _M:extend(name, constructor)
		if type(name) == "function" then
			name = nil
			constructor = name
		end
		local const
		if constructor ~= nil then
			const = function(type, ...)
				local ok, res = pcall(self.new, type)
				return constructor(ok and res or type, ...)
			end
		else const = self.new; end
		local res = setmetatable({
				super = setmetatable({}, mt(self)),
				new = const,
			}, {
				__index = self,
				__call = const,
			})
		
		if name then
			res.__class_name = name
			classes[name] = res
		end
		res.__type_name = res.__class_name or tostring(res):sub(("table: "):len()+1, -1) -- Use the table address if name was not specified
		return res
	end
	
	_DOC.destroy = {
		type = "method",
		short_desc = "A method for cleanup of objects.",
		desc = [[
		A method intended for cleanup of objects. In Object, the method is empty.  
		Any class that defines a destroy method, should call the destroy from it's superclass in it.
		]],
	}
	function _M:destroy()
		if self.__class_name and global then global:remove_v(self); end
	end
	
	
	_DOC.typeof = {
		type = "method",
		short_desc = "Get the type of the given object.",
		desc = [[
		Get a string designating the type of the given object. If name was specified when creating the class it is used
		as the type, otherwise, the parent class's adress will be used.
		]],
		notes = {
			"Comparing types when name wasn't specified might not be 100% reliable through save/load - use with caution.",
			"This is in no way related to the built-in `type` function, the type here is the class the object was created from.",
		},
		params = {
			{
				type = "Object",
				name = "o",
				desc = "The object to get the type of",
			},
		},
		returns = {
			{
				type = "string",
				desc = "The type of this object",
			},
		},
	}
	function _M:typeof(o) return o.__type_name; end
	
	
	setmetatable(_M, {__call = _M.new})
end
