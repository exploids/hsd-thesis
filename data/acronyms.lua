local meta_before
local vars = {}

local function load_acronyms(meta)
	local acronyms = meta.acronyms
	if acronyms ~= nil then
		for _, acronym in ipairs(acronyms) do
			vars[pandoc.utils.stringify(acronym.short)] = { table.unpack(acronym.long) }
		end
	end
	meta_before = meta
end

local function replace(el)
	local text = el.text
	local prefix = nil
	local suffix = nil
	if text:sub(1, 1) == '(' then
		text = text:sub(2)
		prefix = '('
	end
	if text:sub(-1) == ')' then
		text = text:sub(1, -2)
		suffix = ')'
	end
	if vars[text] then
		local result = {}
		if prefix then
			table.insert(result, prefix)
		end
		table.insert(result, pandoc.RawInline("latex", "\\ac{" .. text .. "}"))
		if suffix then
			table.insert(result, suffix)
		end
		return result
	else
		return el
	end
end

local function restore_vars()
	return meta_before
end

return { { Meta = load_acronyms }, { Str = replace }, { Meta = restore_vars } }
