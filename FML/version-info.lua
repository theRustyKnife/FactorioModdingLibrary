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
	--[[
	{
		code = 13,
		name = "",
	},
	--]]
}
