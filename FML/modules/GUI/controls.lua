return function(_M)
	local FML = therustyknife.FML
	local table = therustyknife.FML.table
	local log = therustyknife.FML.log
	
	
	local global
	FML.events.on_load(function()
		local function mk_tabs(parent) parent:mk"elems"; parent:mk"objects"; end
		
		global = table.mk(FML.get_fml_global("GUI"), "controls")
		global:mk"checkbox_group"; mk_tabs(global.checkbox_group)
		global:mk"radiobutton_group"; mk_tabs(global.radiobutton_group)
		global:mk"number_selctor"; mk_tabs(global.number_selctor)
	end)
	
	function _M.prune()
		for _, v in pairs(_M) do
			if type(v) == "table" and v.prune then v.prune(); end
		end
	end
	
	
	------- CheckboxGroup -------
	
	-- Contructor args: parent, name, direction, options (Array[table{name, state, caption}]), on_change, meta
	_M.CheckboxGroup = FML.Object:extend("therustyknife.FML.GUI.controls.CheckboxGroup", function(self, args)
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
		
		return self
	end)
	
	function _M.CheckboxGroup:destroy()
		if self.root.valid then self.root.destroy(); end
		if self.id then
			global.checkbox_group.elems[self.id] = nil
			global.checkbox_group.objects[self.id] = nil
		end
		
		_M.CheckboxGroup.super.destroy(self)
	end
	
	function _M.CheckboxGroup:read_values()
		self.values = table()
		for _, name in ipairs(self.option_names) do self.values[name] = self.root[name].state; end
	end
	
	function _M.CheckboxGroup:changed()
		if self.on_change then
			self:read_values()
			FML.handlers.call(self.on_change, self)
		end
	end
	
	function _M.CheckboxGroup.prune()
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
	_M.RadiobuttonGroup = FML.Object:extend("therustyknife.FML.GUI.controls.RadiobuttonGroup", function(self, args)
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
		
		return self
	end)
	
	function _M.RadiobuttonGroup:destroy()
		if self.root.valid then self.root.destroy(); end
		if self.id then
			global.radiobutton_group.elems[self.id] = nil
			global.radiobutton_group.objects[self.id] = nil
		end
		
		_M.RadiobuttonGroup.super.destroy(self)
	end
	
	function _M.RadiobuttonGroup:select(option)
		for _, name in ipairs(self.option_names) do
			if name ~= option then self.root[name].state = false; end
		end
		self.value = option
		
		if self.on_change then FML.handlers.call(self.on_change, self); end
	end
	
	function _M.RadiobuttonGroup:prune()
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
	
	
	------- NumberSelector -------
	
	-- Constructor args: parent, name, caption, value, on_change, meta, min, max
	_M.NumberSelector = FML.Object:extend("therustyknife.FML.GUI.controls.NumberSelector", function(self, args)
		self.name = args.name
		self.on_change = args.on_change
		self.meta = args.meta
		self.value = tonumber(args.value or 0)
		self.min = args.min
		self.max = args.max
		
		self.root = args.parent.add{
			type = "flow",
			name = args.name,
			direction = "horizontal",
		}
		
		if args.caption then
			self.root.add{
				type = "label",
				caption = args.caption,
			}
		end
		
		self.root.add{
			type = "textfield",
			text = self.value,
		}
		
		self.id = global.number_selctor.elems:insert_at_next_index(self.root)
		global.number_selctor.objects[self.id] = self
		
		return self
	end)
	
	function _M.NumberSelector:destroy()
		if self.root.valid then self.root.destroy(); end
		if self.id then
			global.number_selctor.elems[self.id] = nil
			global.number_selctor.objects[self.id] = nil
		end
		
		_M.NumberSelector.super.destroy(self)
	end
	
	FML.events.on_gui_text_changed(function(event)
		local id = global.number_selctor.elems:index_of(event.element.parent)
		if id then
			local self = global.number_selctor.objects[id]
			
			local new_value = tonumber(event.element.text) or self.value
			if self.min and new_value < self.min then new_value = self.min; end
			if self.max and new_value > self.max then new_value = self.max; end
			
			event.element.text = new_value
			self.value = new_value
			
			if self.on_change then FML.handlers.call(self.on_change, self); end
		end
	end)
end
