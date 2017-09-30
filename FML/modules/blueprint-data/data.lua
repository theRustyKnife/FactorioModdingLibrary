--/ blueprint-data


return function(_M)
	local FML = therustyknife.FML
	local config = therustyknife.FML.config
	local log = therustyknife.FML.log
	
	
	local PROTOTYPE_BASE = FML.data.inherit("constant-combinator")
	
	FML.data.make{
		type = "item",
		name = config.BLUEPRINT_DATA.ITEM_NAME,
		flags = {"hidden"},
		icon = config.BLUEPRINT_DATA.ICON,
		stack_size = 1,
	}
	
	local function parse_settings(settings)
	--% private
	--- Fill in all the required info and figure out the slot count along the way.
	--@ table settings: The table of settings, indexed by names
	--: table: The processed settings
	--: uint: The required number of slots for these settings
		local res = {}
		local slots = 0
		for name, setting in pairs(settings) do
			if setting.index > slots then slots = setting.index; end
			res[name] = {
				name = name,
				type = setting.type,
				index = setting.index,
				default = setting.default,
			}
			if setting.type == "float" then
				res[name].exponent_index = setting.exponent_index or setting.index+1
				if res[name].exponent_index > slots then slots = res[name].exponent_index; end
			end
			if setting.type == "enum" then
				res[name].options = setting.options
				res[name].lookup = {}
				local first
				local ok = false
				for option, i in pairs(setting.options) do
					res[name].lookup[i] = option
					first = first or i
					ok = ok or res[name].default == i
				end
				if not ok then res[name].default = first; end
			end
		end
		
		return res, slots
	end
	
	
	function _M.add_prototype(prototype, collision_box, localised_name)
	--% stage: DATA, SETTINGS
	--- Add a new blueprint data prototype.
	--- collision_box is the size of the proxy entity that will be used and is recommended to be set to the same size as
	--- the entity it's used for. This is mainly to prevent players from creating blueprints without the proxy included.
	--@ BlueprintDataPrototype prototype: The prototype to add
	--@ BoundingBox collision_box={{0, 0}, {0, 0}}: The bounding box to use for this blueprint data group
	--@ LocalisedString localised_name={"entity-name.blueprint-data-entity"}: The localized name of the proxy entity/item, nil if false is passed
		collision_box = collision_box or config.BLUEPRINT_DATA.DEFAULT_COLLISION_BOX
		if type(prototype) == "table" and not prototype.name then
			for _, p in pairs(prototype) do _M.add_prototype(p, collision_box, localised_name); end
			return
		end
		
		local settings, slots = parse_settings(prototype.settings)
		log.dump('Make blueprint-data-entity "'.._M._entity_name(prototype.name)..'" with collision_box ', collision_box)
		FML.data.make{
			base = PROTOTYPE_BASE,
			properties = {
				name = _M._entity_name(prototype.name),
				localised_name = (localised_name == nil and {"entity-name.blueprint-data-entity"})
						or localised_name or nil, -- We don't want false ending up in the name...
				icon = config.BLUEPRINT_DATA.ICON,
				flags = {"placeable-off-grid", "placeable-neutral", "player-creation"},
				collision_mask = {},
				collision_box = collision_box,
				selection_box = {{0, 0}, {0, 0}},
				item_slot_count = slots,
				order = "zzz",
				hidden = true,
				sprites = {
					_for = {names = {"north", "east", "south", "west"}, set = {
						filename = config.DATA.PATH.TRANS,
						x = 0, y = 0, width = 0, height = 0,
					}},
				},
				localised_description = {serpent.dump{name = prototype.name, settings = settings}}, -- This is where the data is stored
			},
			generate = {item = {properties = {flags = {"hidden"}}}},
		}
	end
	
	--TODO: a way to alter already added prototypes?
end