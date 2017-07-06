return function(_M)
	local FML = therustyknife.FML
	local config = therustyknife.FML.config

	local table = FML.table
	
	
	if FML.STAGE == "data" then
		FML.data.make{
			{
				type = "custom-input",
				name = config.GUI.NAMES.OPEN_KEY,
				key_sequence = "mouse-button-1",
				consuming = "none",
			},
			{
				type = "custom-input",
				name = config.GUI.NAMES.CLOSE_KEY,
				key_sequence = "E",
				consuming = "none",
			},
		}
		
		return nil, true

	elseif FML.STAGE == "runtime" then
		local global
		
		FML.events.on_load(function()
			global = FML.get_fml_global("GUI")
			global.to_close = table(global.to_close)
			global.watched_entities = table(global.watched_entities)
			global.watched_entities.names = table(global.watched_entities.names)
			global.watched_entities.instances = table(global.watched_entities.instances)
		end)
		
		
		local _M = {}
		local _DOC = FML.make_doc(_M, {
			type = "module",
			name = "GUI",
			desc = [[ Allows creating more complex GUI structures easily. ]],
		})

		
		--TODO: rethink this, possibly define some gui prototypes in the data stage and associate them with entities there?
		function _M.watch_entity(entity)
			if type(entity) == "string" then
				global.watched_entities.names:insert(entity)
			elseif type(entity) == "table" and entity.__self then
				global.watched_entities.instances:insert(entity)
			else error("Wrong argument to watch_entity (expected string or entity, got "..type(entity)); end
		end
	else return nil; end
end