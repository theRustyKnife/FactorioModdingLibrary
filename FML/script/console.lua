return function()
	local FML_import = loadstring(settings.global["FML_FML-hack-setting"].value)()
	local module_loader = {}; FML_import.module_loader(module_loader)
	local FML_stdlib = module_loader.init(FML_import.FML_stdlib)
	local config = FML_import.config

	FML = module_loader.load_std(FML_stdlib, nil, "runtime", config, config.VERSION)
	FML_stdlib.put_to_global("therustyknife", "FML", FML)

	for _, module in ipairs(config.MODULES_TO_LOAD) do
		if FML_import.modules[module.name] then
			FML[module.name] = module_loader.init(FML_import.modules[module.name])
		end
	end

	return FML
end
