--/ FML


return function(_M, STAGE, args)
	_M.STAGE = STAGE -- This is only for legacy purposes - I'm just too lazy to change it everywhere in the code
	_M.VERSION = _M.config.VERSION
	
	
	-- If we're loading from the FML mod, copy the version to config.MOD.VERSION
	if STAGE == 'DATA' or STAGE == 'RUNTIME_SHARED' then
		-- We have to get rid of all the extra stuff after the actual version numbers
		local function strip(s, char) return s:sub(1, (s:find(char) or 0)-1); end
		_M.config.MOD.VERSION = strip(strip(_M.VERSION.NAME, '-'), '+')
	end
	
	
	function _M.override_table(override, original)
	--- Override a table's values with a different table without modifying the original.
	--- This is done recursively using a metatable. The tables will go out of sync if nested tables are added/removed.
	--@ table override: The overriding values
	--@ table original: The values to override
	--: table: A reference to the `override` table which now inherits `original`s values
		for k, v in pairs(override) do
			if type(v) == 'table' and original[k] then _M.override_table(v, original[k]); end
		end
		return setmetatable(override, {__index=original})
	end
	
	-- If a local config has been defined, override the remote config with it
	if STAGE == 'RUNTIME' and args.local_config then _M.config = _M.override_table(args.local_config, _M.config); end
	
	function _M.put_to_global(namespace, package_name, package)
	--- Put a value into the global scope.
	--@ string namespace: The top level namespace - should be the author's name
	--@ string package_name: The name of the package - probably name of mod
	--@ Any package: The thing to put into the global
		_G[namespace] = _G[namespace] or {}
		_G[namespace][package_name] = package
	end
	
	-- Use the handy function right away to give global access to FML - this is the prefered way
	_M.put_to_global(_M.config.GLOBAL.NAMESPACE, _M.config.GLOBAL.PACKAGE, _M)
	
	function _M.get_global(namespace, package_name, name, create, default)
	--- Get a table inside the global serialized table.
	--@ string namespace: The top level namespace - should be the author's name
	--@ string package_name: The name of the package - probably name of mod
	--@ string name: The name of the new table
	--@ bool create=true: If true, non-existent tables are going to be created
	--@ Any default=nil: If create is false and some of the tables does not exist, this is going to be returned
	--: {table, Any}: The new table or the default value
		if create == false then
			return (global[namespace] and global[namespace][package_name] and global[namespace][package_name][name])
				or default
		end
		global[namespace] = global[namespace] or {}
		global[namespace][package_name] = global[namespace][package_name] or {}
		global[namespace][package_name][name] = global[namespace][package_name][name] or {}
		return global[namespace][package_name][name]
	end
	
	--TODO: make this only load in the runtime stages and maybe only be available when global is available
	function _M.get_fml_global(name, create, default)
	--% private
	--- Get a table stored in the global serialized table.
	--@ string name: The key for the table to be stored at
	--@ bool create=true: If true, non-existent tables are going to be created
	--@ Any default=nil: If create is false and some of the tables does not exist, this is going to be returned
	--: {table, Any}: The table or the default value
		return _M.get_global(_M.config.GLOBAL.NAMESPACE, _M.config.GLOBAL.PACKAGE, name, create, default)
	end
end
