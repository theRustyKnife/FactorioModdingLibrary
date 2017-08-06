return {
	{
		code = 5,
		name = "0.1.0-alpha.4.0",
	},
	{
		code = 9,
		name = "0.1.0-alpha.5.2",
	},
	{
		code = 10,
		name = "0.1.0-alpha.5.3",
		changes = {"blueprint-data now handles entities on it's own"},
	},
	{
		code = 11,
		name = "0.1.0-alpha.6.0",
		added = {"New functions in surface", "Object.typeof"},
		changes = {"Various bugfixes"},
	},
	{
		code = 12,
		name = "0.1.0-alpha.6.1",
		fixes = {"Object.typeof", "BlueprintData._copy", "blueprint-data items are now hidden"},
		added = {"Some GUI functions, still not great...", "Object.abstract"},
		changes = {"events no longer throws an error on attempt to register permanent handler"}
	},
	{
		code = 13,
		name = "0.1.0-alpha.7.0",
		added = {
			'handlers module for "permanent" handler functions',
			"table.mk for easy table initialization",
			"A prototype version of GUI",
		},
		fixes = {"format.position is properly available", "insert_at_next_index is available in RichTable"},
		changes = {
			"Local config is now in embedded in the main file to allow single file install",
			"`_M_require` is now available to nested modules in the global scope for loading submodules",
		},
	},
	{
		code = 14,
		name = "0.1.0-alpha.7.1",
		changed = {"Entity GUI now works almost like vanilla"},
	},
	{
		code = 15,
		name = "0.1.0-alpha.8.0",
		added = {"remote.call_when_loaded", "GUI.controls.CheckboxGroup"},
		fixes = {
			"GUI.watch_opening now works properly before load",
			"Fixed GUI.entity_base crashing",
			"Fixed typo in GUI.entity_segment",
			"Fixed _copy crashing with non-default settings",
		},
	},
	{
		code = 16,
		name = "0.1.0-alpha.8.1",
		added = {"GUI.controls.RadiobuttonGroup"},
		fixes = {
			"Fixed GUI.entity_base segment width",
			"Entity GUI can't be opened with full cursor",
			"Fixed blueprint-data prototypes not getting loaded after save/load",
			"Fixed that unimplemented abstract methods would print the wrong type",
		},
	},
}
