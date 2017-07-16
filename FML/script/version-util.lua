local VERSIONS = require "version-info"


local lookup = {}
local latest = 0
for _, v in pairs(VERSIONS) do
	lookup[v.code] = v
	if v.code > latest then latest = v.code; end
end


local _M = {}


function _M.config(code)
	local v = lookup[code or latest]
	return {
		CODE = v.code,
		NAME = v.name,
	}
end

function _M.name(arg)
	arg = arg or {}
	local v = lookup[arg.code or latest]
	local res = "code-"..(code or latest)
	if v then res = v.name; end
	if not arg.full then
		local pre = res:find("[-+]")
		if pre then res = res:sub(1, pre-1); end
	end
	return res
end


return _M
