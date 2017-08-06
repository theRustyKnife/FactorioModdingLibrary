return function(_M)
	local FML = therustyknife.FML
	if FML.STAGE ~= "runtime" then return; end
	local table = FML.table
	local log = FML.log
	
	_M.controls = {};
	
	local global
	FML.events.on_load(function()
		global = table.mk(FML.get_fml_global("GUI"), "controls")
		global:mk"checkbox_group"; global.checkbox_group:mk"objects"; global.checkbox_group:mk"elems"
		global:mk"radiobutton_group"; global.radiobutton_group:mk"objects"; global.radiobutton_group:mk"elems"
	end)
	
	function _M.controls.prune()
		for _, v in pairs(_M.controls) do
			if type(v) == "table" and v.prune then v.prune(); end
		end
	end
	
	
	------- CheckboxGroup -------
	
	-- Contructor args: parent, name, direction, options (Array[table{name, state, caption}]), on_change, meta
	_M.controls.CheckboxGroup = FML.Object:extend("therustyknife.FML.GUI.controls.CheckboxGroup", function(self, args)
		self.name = args.name
		self.on_change = args.on_change
		self.meta = args.meta
		
		self.root = args.parent.add{
			type = "flow",
			name = args.name,
			direction = args.direction or "vertical",
		}
		
		self.option_names = table()
		for _, value in ipairs(args.options) do
			value.state = FML.cast.bool(value.state)
			value.caption = value.caption or {value.name}
			self.option_names:insert(value.name)
			self.root.add{
				type = "checkbox",
				name = value.name,
				state = value.state,
				caption = value.caption,
			}
		end
		
		if self.on_change then
			self.id = global.checkbox_group.elems:insert_at_next_index(self.root)
			global.checkbox_group.objects[self.id] = self
		end
	end)
	
	function _M.controls.CheckboxGroup:destroy()
		if self.root.valid then self.root.destroy(); end
		if self.id then
			global.checkbox_group.elems[self.id] = nil
			global.checkbox_group.objects[self.id] = nil
		end
		
		_M.controls.CheckboxGroup.super.destroy(self)
	end
	
	function _M.controls.CheckboxGroup:read_values()
		self.values = table()
		for _, name in ipairs(self.option_names) do self.values[name] = self.root[name].state; end
	end
	
	function _M.controls.CheckboxGroup:changed()
		if self.on_change then
			self:read_values()
			FML.handlers.call(self.on_change, self)
		end
	end
	
	function _M.controls.CheckboxGroup.prune()
		for id, elem in pairs(global.checkbox_group.elems) do
			if not elem.valid then global.checkbox_group.objects[id]:destroy(); end
		end
	end
	
	FML.events.on_gui_checked_state_changed(function(event)
		if event.element.type == "checkbox" then
			local parent = event.element.parent
			local id = global.checkbox_group.elems:index_of(parent)
			if id then global.checkbox_group.objects[id]:changed(); end
		end
	end)
	
	
	------- RadiobuttonGroup -------
	
	-- Constructor args: parent, name, direction, options (Array[table{name, caption}]), selected, on_change, meta
	_M.controls.RadiobuttonGroup = FML.Object:extend("therustyknife.FML.GUI.controls.RadiobuttonGroup", function(self, args)
		self.name = args.name
		self.on_change = args.on_change
		self.meta = args.meta
		
		self.root = args.parent.add{
			type = "flow",
			name = args.name,
			direction = args.direction or "vertical",
		}
		
		self.option_names = table()
		for _, value in ipairs(args.options) do
			local state = value.name == args.selected
			value.caption = value.caption or {value.name}
			self.option_names:insert(tostring(value.name))
			self.root.add{
				type = "radiobutton",
				name = value.name,
				state = state,
				caption = value.caption,
			}
		end
		
		self.id = global.radiobutton_group.elems:insert_at_next_index(self.root)
		global.radiobutton_group.objects[self.id] = self
	end)
	
	function _M.controls.RadiobuttonGroup:destroy()
		if self.root.valid then self.root.destroy(); end
		if self.id then
			global.radiobutton_group.elems[self.id] = nil
			global.radiobutton_group.objects[self.id] = nil
		end
		
		_M.controls.RadiobuttonGroup.super.destroy(self)
	end
	
	function _M.controls.RadiobuttonGroup:select(option)
		for _, name in ipairs(self.option_names) do
			if name ~= option then self.root[name].state = false; end
		end
		self.value = option
		
		if self.on_change then FML.handlers.call(self.on_change, self); end
	end
	
	function _M.controls.RadiobuttonGroup:prune()
		for id, elem in pairs(global.radiobutton_group.elems) do
			if not elem.valid then global.radiobutton_group.objects[id]:destroy(); end
		end
	end
	
	FML.events.on_gui_checked_state_changed(function(event)
		if event.element.type == "radiobutton" and event.element.state then
			local parent = event.element.parent
			local id = global.radiobutton_group.elems:index_of(parent)
			if id then global.radiobutton_group.objects[id]:select(event.element.name); end
		end
	end)
end
