if not script then return nil; end -- requires script to load


local config = require "therustyknife.FML.config"
local FML = require "therustyknife.FML"


local global = FML.global.get("events")
global.handlers = global.handlers or {}
global.registered_events = global.registered_events or {}


local M = {}


if not config.USE_NORMAL_HANDLERS then
	local function register_event(event_id) -- add our custom event handler
		global.handlers[event_id] = global.handlers[event_id] or {}
		script.on_event(event_id, function(event)
			for _, f in pairs(global.handlers[event_id]) do f(event); end
		end)
		global.registered_events[event_id] = true
	end
	
	for event_id, v in pairs(global.registered_events) do -- re-register events on load
		if v then register_event(event_id); end
	end
	
	function M.add_handler(event_id, f, name)
		name = name or FML.table.get_next_index(global.handlers)
		
		-- check function and name validity
		assert(type(f) == "function", "Expected function for event handler, got " .. type(f) .. ".")
		assert(global.handlers[event_id][name] == nil, "A handler with name " .. tostring(name) .. " is already registered for event_id " .. tostring(event_id) .. ".")
		
		if not global.registered_events[event_id] then register_event(event_id) end -- register event if not already registered
		
		global.handlers[event_id][name] = f -- add the handler
		
		return name -- for eventual future reference / removal of the handler
	end
	
	function M.remove_handler(event_id, name)
		global.handlers[event_id][name] = nil
	end
end


function M.batch_set_handler(events, f) -- set a bunch of events to the same function
	for _, event_id in pairs(events) do
		if config.USE_NORMAL_HANDLERS then script.on_event(event_id, f)
		else M.add_handler(event_id, f)
		end
	end
end

function M.set_on_built(f)
	M.batch_set_handler({defines.events.on_built_entity, defines.events.on_robot_built_entity}, f)
end

function M.set_on_destroyed(f)
	M.batch_set_handler({defines.events.on_entity_died, defines.events.on_preplayer_mined_item, defines.events.on_robot_pre_mined}, f)
end


return M
