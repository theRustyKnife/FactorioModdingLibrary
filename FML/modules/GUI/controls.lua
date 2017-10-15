--/ GUI.controls
--- A collection of user control elements.

--TODO: refactor the classes here to share as much code as possible so there aren't the exact same methods three times


return function(_M)
	local FML = therustyknife.FML
	local table = therustyknife.FML.table
	local log = therustyknife.FML.log
	
	
	local global
	FML.events.on_load(function()
		local function mk_tabs(parent) parent:mk"elems"; parent:mk"objects"; parent:mk"linked"; end
		
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
	--@ kw string link_name=nil: All CheckboxGroups with the same link_name will be kept synchronized
	--@ kw bool on_change_on_sync=false: If true, the on_change handler will be called even when syncing from a linked instance
	--: CheckboxGroup: The new object
		self.name = args.name
		self.on_change = args.on_change
		self.meta = args.meta
		self.link_name = args.link_name
		self.on_change_on_sync = args.on_change_on_sync
		
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
		
		-- Save for syncing
		if self.link_name then global.checkbox_group.linked:mk(self.link_name):insert(self); end
		
		self:read_values()
		return self
	end)
	
	function _M.CheckboxGroup:destroy()
	--- Destroy this object and the gui elements it's attached to.
		self.invalid = true
		if self.root.valid then self.root.destroy(); end
		if self.id then
			global.checkbox_group.elems[self.id] = nil
			global.checkbox_group.objects[self.id] = nil
		end
		
		_M.CheckboxGroup.super.destroy(self)
	end
	
	function _M.CheckboxGroup:read_values()
	--- Update the `values` field to reflect the current state.
	--: Dictionary[string, bool]: Reference to the values field just read
		self.values = table()
		for _, name in ipairs(self.option_names) do self.values[name] = self.root[name].state; end
		return self.values
	end
	
	function _M.CheckboxGroup:changed(sync)
	--% private
	--- This is what is called by the event handler on change.
	--- Calls the handler function if possible.
	--@ bool sync=true: If false, linked CheckboxGroups will not be synced
		if self.on_change and (not sync or self.on_change_on_sync) then
			self:read_values()
			FML.handlers.call(self.on_change, self)
		end
		
		if self.link_name and sync ~= false then
			for i, checkbox_group in pairs(global.checkbox_group.linked[self.link_name]) do
				if not checkbox_group.root.valid or self.invalid then
					global.checkbox_group.linked[self.link_name][i] = nil
				else
					for name, state in pairs(self.values) do
						assert(checkbox_group.root[name], "CheckboxGroups with different structure can't be synced.")
						checkbox_group.root[name].state = state
					end
					checkbox_group:changed(false)
				end
			end
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
	--@ kw string link_name=nil: All RadiobuttonGroups with the same link_name will be kept synchronized
	--@ kw bool on_change_on_sync=false: If true, the on_change handler will be called even when syncing from a linked instance
	--: RadiobuttonGroup: The new object
		self.name = args.name
		self.on_change = args.on_change
		self.meta = args.meta
		self.value = args.value
		self.link_name = args.link_name
		self.on_change_on_sync = args.on_change_on_sync
		
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
		
		-- Save for syncing
		if self.link_name then global.radiobutton_group.linked:mk(self.link_name):insert(self); end
		
		return self
	end)
	
	function _M.RadiobuttonGroup:destroy()
	--- Destroy this object and the gui elements it's attached to.
		self.invalid = true
		if self.root.valid then self.root.destroy(); end
		if self.id then
			global.radiobutton_group.elems[self.id] = nil
			global.radiobutton_group.objects[self.id] = nil
		end
		
		_M.RadiobuttonGroup.super.destroy(self)
	end
	
	function _M.RadiobuttonGroup:select(option, sync)
	--% private
	--- Make sure only the given radiobutton is selected.
	--- Also calls the handler if possible.
	--@ string option: The name of the radiobutton that is selected
	--@ bool sync=true: If false, the linked RadiobuttonGroups will not be synced
		sync = sync ~= false
		for _, name in ipairs(self.option_names) do
			self.root[name].state = name == option
		end
		self.value = option
		
		if self.on_change and (not sync or self.on_change_on_sync) then FML.handlers.call(self.on_change, self); end
		
		if self.link_name and sync then
			for i, radiobutton_group in pairs(global.radiobutton_group.linked[self.link_name]) do
				if not radiobutton_group.root.valid or self.invalid then
					global.radiobutton_group.linked[self.link_name][i] = nil
				else
					radiobutton_group:select(option, false)
				end
			end
		end
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
	--@ kw bool overflow=true: If true, overflow will be calculated for values outside the range, only works if both min and max are specified
	--@ kw string link_name=nil: All NumberSelectors with the same link_name will be kept synchronized
	--@ kw bool on_change_on_sync=false: If true, the on_change handler will be called even when syncing from a linked instance
	--: NumberSelector: The new object
		self.name = args.name
		self.on_change = args.on_change
		self.meta = args.meta
		self.value = tonumber(args.value or 0)
		self.min = args.min
		self.max = args.max
		self.overflow = args.overflow
		self.link_name = args.link_name
		self.on_change_on_sync = args.on_change_on_sync
		self.format_func = args.format_func or tonumber
		
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
		
		self.textfield = self.root.add{
			type = "textfield",
			text = self.value,
		}
		
		self.id = global.number_selctor.elems:insert_at_next_index(self.root)
		global.number_selctor.objects[self.id] = self
		
		-- Save for syncing
		if self.link_name then global.number_selctor.linked:mk(self.link_name):insert(self); end
		
		return self
	end)
	
	function _M.NumberSelector:destroy()
	--- Destroy this object and the gui elements it's attached to.
		self.invalid = true
		if self.root.valid then self.root.destroy(); end
		if self.id then
			global.number_selctor.elems[self.id] = nil
			global.number_selctor.objects[self.id] = nil
		end
		
		_M.NumberSelector.super.destroy(self)
	end
	
	function _M.NumberSelector:is_in_range(value)
	--% private
	--- Check if the given value is a valid input.
	--@ float value: The value to check
	--: bool: true if valid
		return (not self.min or value >= self.min) and (not self.max or value <= self.max)
	end
	
	function _M.NumberSelector:changed(text, sync)
	--% private
	--- Handle text changes.
	--@ string text: The new text value
	--@ bool sync=true: If false, the linked NumberSelectors will not be synced
		sync = sync ~= false
		
		local from_text = tonumber(text)
		local in_range = from_text and self:is_in_range(from_text)
		if from_text and not in_range and self.min and self.max then
			from_text = FML.random_util.calculate_overflow(from_text, {min=self.min, max=self.max})
			in_range = true
		end
		self.value = (in_range and from_text) or self.value
		
		if self.on_change and (sync or self.on_change_on_sync) then FML.handlers.call(self.on_change, self); end
		
		if self.link_name and sync then
			for i, number_selctor in pairs(global.number_selctor.linked[self.link_name]) do
				if not number_selctor.root.valid or self.invalid then
					global.number_selctor.linked[self.link_name][i] = nil
				elseif number_selctor ~= self then
					number_selctor.textfield.text = self.format_func(self.value)
					number_selctor:changed(text, false)
				end
			end
		end
	end
	
	FML.events.on_gui_text_changed(function(event)
		local id = global.number_selctor.elems:index_of(event.element.parent)
		if id then global.number_selctor.objects[id]:changed(event.element.text); end
	end)
	--\
end
