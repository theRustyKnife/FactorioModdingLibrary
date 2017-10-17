--/ events
--* Shortcuts from defines that do not begin with `on_` will have that added before the actual name (i.e. `on_script_raised_built` instead of `script_raised_built`).

return function(_M)
	local FML = therustyknife.FML
	
	
	_M.GROUPS = {
		destroyed = {
			defines.events.on_entity_died,
			defines.events.on_preplayer_mined_item,
			defines.events.on_robot_pre_mined,
		},
		built = {
			defines.events.on_built_entity,
			defines.events.on_robot_built_entity,
		},
		revived = {_M.id'therustyknife.FML.events.entity-revived'},
	}
	
	
	-- Generate functions for events from defines
	for name, event_id in pairs(defines.events) do
		if not FML.random_util.string_starts_with(name, 'on_') then name = 'on_'..name; end
		if not _M[name] then _M[name] = function(...) _M.on(event_id, ...); end end
	end
	
	-- Generate functions for event groups
	for name, events in pairs(_M.GROUPS) do
		name = 'on_'..name
		if not _M[name] then _M[name] = function(...) _M.on(events, ...); end end
	end
end
