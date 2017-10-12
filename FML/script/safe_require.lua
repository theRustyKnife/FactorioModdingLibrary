--/ safe_require


return function(path, raise_errors)
--f safe_require
--- Require a file without taking `package.loaded` into account.
--- It's also guaranteed that `package.loaded` will not be changed by this function.
--@ string path: The path to require from
--@ bool raise_errors=true: If true, errors will be raised, but `package.path` will still be preserved
--: Any: Whatever the file returns, nil if an error occurred
--: string: The error message if one occurred and raise_errors is false
	raise_errors = raise_errors ~= false
	
	-- Save the original value
	local prev_loaded = package.loaded[path]
	package.loaded[path] = nil
	
	-- Try to require the path
	local res
	local status, err = pcall(function(path) res = require(path); end, path)
	
	-- Restore the original value
	package.loaded[path] = prev_loaded
	
	-- Handle errors
	if not status then
		err = err or 'safe_require failed to load "'..tostring(path)..'". No error message given.'
		if raise_errors then error(err, 2)
		else return nil, err; end
	end
	
	return res
end
