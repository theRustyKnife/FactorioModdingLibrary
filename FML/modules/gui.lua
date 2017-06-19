local FML = require "therustyknife.FML"


if FML.STAGE ~= "runtime" then return nil; end


local _M = {}
local _DOC = FML.make_doc(_M, {
	type = "module",
	name = "gui",
	desc = [[ Allows creating more complex gui structures. ]],
})


--TODO: implement


return _M
