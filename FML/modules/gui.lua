local FML = require "therustyknife.FML"
local config = require "therustyknife.FML.config"


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
	
	return nil

elseif FML.STAGE == "runtime" then
	--TODO: move to on_init/load
	local global = FML.get_fml_global("GUI")
	global.to_close = FML.table.enrich(global.to_close or {})
	global.watched_entities = FML.table.enrich(global.watched_entities or {})
	
	local _M = {}
	local _DOC = FML.make_doc(_M, {
		type = "module",
		name = "GUI",
		desc = [[ Allows creating more complex GUI structures easily. ]],
	})


	function _M.watch_entity(entity)
		--TODO: implement
		--global.watched_entities
	end


	return _M

else return nil; end
