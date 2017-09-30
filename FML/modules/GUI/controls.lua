--/ GUI.controls
--- A collection of user control elements.


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
	--- Force clearing dead entries in the global table.
	--- This *should* be done automatically when needed.
		for _, v in pairs(_M) do
			if type(v) == "table" and v.prune then v.prune(); end
		end
	end
	
	
	--/ GUI.controls.CheckboxGroup
	--% type: class
	--% super: Object
	--- A group of linked checkboxes, acting as a single element.
	--+ r string name: The name of this element
	--+ r Dictionary[string, bool] values: The current state of the checkboxes
	--+ string on_change: The handler function to be called when the state changes
	--+ Any meta: The data passed into the constructor, can be used for identification in the user's code
	
	_M.CheckboxGroup = FML.Object:extend("therustyknife.FML.GUI.controls.CheckboxGroup", function(self, args)
	--f __call
	--% type: metamethod
	--- Create a new |:CheckboxGroup:|.
	--- The options tables can have the following keys:  
	---  - |:string:| name: The name of this checkbox  
	---  - |:bool:| state=`false`: The initial state of this checkbox  
	---  - |:LocalisedString:| caption=`{name}`: The caption used for this checkbox  
	--@ kw LuaGuiElement parent: The element to root this group into
	--@ kw Array[table] options: The checkboxes that will be displayed in this group
	--@ kw string name=nil: The name that will be used for this element
	--@ kw string direction="vertical": One of `"vertical"` or `"horizontal"`
	--@ kw string on_change=nil: The on_change value
	--@ kw Any meta=nil: The meta value
	--: CheckboxGroup: The new object
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
	--- Destroy this object and the gui elements it's attached to.
		if self.root.valid then self.root.destroy(); end
		if self.id then
			global.checkbox_group.elems[self.id] = nil
			global.checkbox_group.objects[self.id] = nil
		end
		
		_M.CheckboxGroup.super.destroy(self)
	end
	
	function _M.CheckboxGroup:read_values()
	--- Update the `values` field to reflect the current state.
		self.values = table()
		for _, name in ipairs(self.option_names) do self.values[name] = self.root[name].state; end
	end
	
	function _M.CheckboxGroup:changed()
	--% private
	--- This is what is called by the event handler on change.
	--- Calls the handler function if possible.
		if self.on_change then
			self:read_values()
			FML.handlers.call(self.on_change, self)
		end
	end
	
	function _M.CheckboxGroup.prune()
	--% private static
	--- Prune all the invalid elements from the global table.
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
	--\
	
	
	--/ GUI.controls.RadiobuttonGroup
	--% type: class
	--% super: Object
	--- A group of linked radiobuttons, where only one can be selected at a time.
	--+ r string name: The name of this element
	--+ r string value: Name of the currently selected radiobutton
	--+ string on_change: The handler function to be called when the state changes
	--+ Any meta: The data passed into the constructor, can be used for identification in the user's code
	
	
	-- Constructor args: parent, name, direction, options (Array[table{name, caption}]), selected, on_change, meta
	_M.RadiobuttonGroup = FML.Object:extend("therustyknife.FML.GUI.controls.RadiobuttonGroup", function(self, args)
	--f __call
	--% type: metamethod
	--- Create a new |:RadiobuttonGroup:|.
	--- The options tables can have the following keys:  
	---  - |:string:| name: The name of this radiobutton  
	---  - |:LocalisedString:| caption=`{name}`: The caption used for this radiobutton
	--@ kw LuaGuiElement parent: The element to root this group into
	--@ kw Array[table] options: The radiobuttons that will be displayed in this group
	--@ kw string name=nil: The name that will be used for this element
	--@ kw string direction="vertical": One of `"vertical"` or `"horizontal"`
	--@ kw string selected=nil: A name of the initially selected radiobutton, none will be selected if nil is passed
	--@ kw string on_change=nil: The on_change value
	--@ kw Any meta=nil: The meta value
	--: RadiobuttonGroup: The new object
		self.name = args.name
		self.on_change = args.on_change
		self.meta = args.meta
		self.value = args.value
		
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
	--- Destroy this object and the gui elements it's attached to.
		if self.root.valid then self.root.destroy(); end
		if self.id then
			global.radiobutton_group.elems[self.id] = nil
			global.radiobutton_group.objects[self.id] = nil
		end
		
		_M.RadiobuttonGroup.super.destroy(self)
	end
	
	function _M.RadiobuttonGroup:select(option)
	--% private
	--- Make sure only the given radiobutton is selected.
	--- Also calls the handler if possible.
	--@ string option: The name of the radiobutton that is selected
		for _, name in ipairs(self.option_names) do
			if name ~= option then self.root[name].state = false; end
		end
		self.value = option
		
		if self.on_change then FML.handlers.call(self.on_change, self); end
	end
	
	function _M.RadiobuttonGroup.prune()
	--% private static
	--- Prune all the invalid elements from the global table.
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
	--\
	
	
	--/ GUI.controls.NumberSelector
	--% type: class
	--% super: Object
	--- A textfield that only accepts numbers.
	--- Optionally a range can be specified.
	--* Both limits are exclusive
	--+ r string name: The name of this element
	--+ r float value: The current value in the selector
	--+ float min: If not nil, the value will be kept greater than this
	--+ float max: If not nil, the value will be kept less than this
	--+ string on_change: The handler function to be called when the state changes
	--+ Any meta: The data passed into the constructor, can be used for identification in the user's code
	
	_M.NumberSelector = FML.Object:extend("therustyknife.FML.GUI.controls.NumberSelector", function(self, args)
	--f __call
	--% type: metamethod
	--- Create a new |:NumberSelector:|.
	--* The initial value is not subject to value limits.
	--@ kw LuaGuiElement parent: The element to root this group into
	--@ kw string name=nil: The name that will be used for this element
	--@ kw LocalisedString caption=nil: If not nil, a label will be added to the NumberSelector containing this caption
	--@ kw float value=0: The initial value for the selector
	--@ kw string on_change=nil: The on_change value
	--@ kw Any meta=nil: The meta value
	--@ kw float min=nil: The min value
	--@ kw float max=nil: The max value
	--: NumberSelector: The new object
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
	--- Destroy this object and the gui elements it's attached to.
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
	--\
end
