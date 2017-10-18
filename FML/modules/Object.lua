--/ Object
--% type: class
--- A base class for objects in Lua.
--- Supports all the basic operations such as creating new objets of a type and inheritance.  
--- Additionally, also allows for simple loading of objects after serialization, where metatables get lost.
--* The load function has to be called for every object, that is to be used, after game load. Ideally, this would be done in the `load` event.
--* Any class derived from Object can be instantiated using the __call metamethod. This may not be mentioned in the documentation, as it is the same as the `new` method.
--* A lot of the functionality of this module uses metatables, so be careful with setting/resetting them.


return function(_M)
	local FML = therustyknife.FML
	local table = FML.table
	local log = FML.log
	
	
	--TODO: allow explicitly adding objects to the global table via a method to compensate for the inability to properly
	-- create objects before load
	local classes = table()
	local global
	if FML.STAGE == "RUNTIME" or FML.STAGE == "RUNTIME_SHARED" then
		local function init()
			global = table(FML.get_fml_global("Object"))
			for _, object in ipairs(global) do
				if classes[object.__class_name] then classes[object.__class_name]:load(object)
				else log.w("Couldn't find class '"..object.__class_name.."' to load an object."); end
			end
		end
		FML.events.on_post_load(init)
		FML.events.on_pre_config_change(init)
	end
	
	
	local function mt(type) return {__index = type}; end
	
	function _M:new()
	--- Create a new Object.
	--: Object: The newly created object
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
	
	function _M:load(object)
	--- Re-setup an Object after load.
	--@ Object object: The Object to load
	--: Object: The loaded object (the same reference as passed in)
		if not object.__class_name then object.__type_name = tostring(self):sub(("table: "):len()+1, -1); end
		return setmetatable(object, mt(self))
	end
	
	--TODO: make a naming convention wiki page explaining the formats (author.mod-name.ObjectName in this case)
	function _M:extend(name, constructor)
	--- Create a subclass of this class.
	--- Handles all the necessary technicalities of setting up the metatables and allows to override the cosntructor of
	--- the parent class.  
	--- The constructor is the function that will be responsible for creating the new objects. If a call to the
	--- superconstructor without parameters succeeds, the result will be passed as the first argument, otherwise it will
	--- be false. In such case, the constructor must call the superconstructor explicitly.  
	--- Additionally, the super field is created, which allows easy access to the superclass.  
	---
	--- Either of the parameters may be omitted:
	--- - If name is omitted, objects will have to be loaded manually. Also, instantiating any named objects before
	--- global is accessible for writing will cause them to not be saved for loading.
	--- - If constructor is omitted, the superclass's constructor will be used.  
	--@ string name: The name of the new class, will be used for loading - has to be unique
	--@ function construtor: The constructor for the new class
	--: Subclass: The new subclass
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
	
	function _M:destroy()
	--- A method for cleanup of objects.
	--- In Object, the method is empty. Any class that defines a destroy method, should call the destroy from it's
	--- superclass in it.
		if self.__class_name and global then global:remove_v(self); end
	end
	
	
	function _M.typeof(o)
	--% static
	--- Get the type of the given object.
	--- If name was specified when creating the class it is used as the type, otherwise, the parent class's adress will
	--- be used.
	--* Comparing types when name wasn't specified might not be 100% reliable through save/load - use with caution.
	--* This is in no way related to the built-in `type` function, the type here is the class the object was created from.
	--* Can also be used as a method on any Object.
	--@ Object o: The object to get the type of
	--: string: The type of the object
		return o.__type_name
	end
	
	
	function _M:abstract(name, err)
	--- Make a method to be implement by subclasses.
	--- Throws an error if the method is called on a class that doesn't implement it.
	--@ string name: The name of the method
	--@ string err=A message: The message to display when an attempting to call this method
	--: function: The dummy function
		self[name] = function(self)
			error(err and tostring(err) or 'The abstract method "'..name..'" is not implemented in '..self.__type_name)
		end
	end
	
	
	setmetatable(_M, {__call = _M.new})
end
