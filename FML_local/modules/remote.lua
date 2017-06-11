local FML = require "therustyknife.FML"


if FML.STAGE ~= "runtime" then return nil; end


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


local _M = {}
--[[
Allows easy access to functions through the remote API.
The functions returned from here are all closures, so they'renot safe for serialization. To serialize an interface
function, use the Callback concept. To serialize an interface, simply store it's name as a string.
To get a function from a Callback, use the unpack_callback function as parameter to your desired function.
]]


function _M.get_interface(interface, safe)
--[[
Returns all functions from an interface. If the interface doesn't exist, nil is returned. If safe is true, an empty
table is returned instead.
If safe is true, safe functions are returned, same as in get_function_safe. However, only functions that are currently
present in the interface are taken into account.
]]
	if not remote.interfaces[interface] then return nil; end
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
--[[
Get a function from an interface. If the interface is removed, the call will be ignored, returning nil.
Additionally, a function is returned even if the interface doesn't exist (yet), so calling it should always be safe.
]]
	return get_function_safe_internal(clbck)
end

function _M.get_function(clbck)
--[[
Get a function from an interface. If the interface is removed, calling this function will crash.
If the interface doesn't exist, nil will be returned.
]]
	if not remote.interfaces[clbck.interface] or not remote.interfaces[clbck.interface][clbck.func] then return nil; end
	
	return get_function_internal(clbck)
end


function _M.get_callback(interface, func)
--[[ Return a Callback representing the given function. It might be easier to construct the Callback yourself tho... ]]
	return {interface = interface, func = func}
end

function _M.unpack_callback(clbck)
--[[ Unpack the given Callback to the format accepted by the other functions. Might be easier to DIY again... ]]
	return clbck.interface, clbck.func
end

local function _callback_call_method(clbck, ...) return remote.call(clbck.interface, clbck.func, ...); end
local RICH_MT = {__call = _callback_call_method}
function _M.enrich_callback(clbck)
--[[
Give the callback a call method. This method is probably not serialization-safe.
The callback is also given a metatable that allows you to call it directly. This metatable is lost during serialization.
]]
	clbck.call = _callback_call_method
	setmetatable(clbck, RICH_MT)
	return clbck
end

function _M.get_rich_callback(interface, func)
--[[ Get a callback that already has the call method and the __call metamethod. ]]
	return _M.enrich_callback{interface = interface, func = func}
end

function _M.call(clbck, ...)
--[[ Call the given callback. ]]
	return _callback_call_method(clbck, ...)
end


function _M.add_interface(name, module, generate_getters, overwrite, ignore_tables)
--[[
Expose an interface through the remote API. Optionally generate getters for constants using generate_getters as prefix
if possible. If overwrite is true, existing interface with this name will be removed.
Returns true if the interface was successfully exposed, false otherwise.
Care needs to be taken with getters, as constants with nil value will not have a getter generated. Moreover, if the
getter should clash with any name already in the module, it won't be generated either.
]]
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

_M.expose_interface = _M.add_interface
--[[ Deprecated name for add_interface. ]]


--TODO: Callback handling - simple way to generate a callback from a function, where FML is going to handle exposing the
-- interface.


return _M
