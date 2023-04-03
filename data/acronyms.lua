local meta_before
local acronyms = {}

local function load_acronyms(meta)
	local meta_acronyms = meta.acronyms
	if meta_acronyms ~= nil then
		for index, acronym in ipairs(meta_acronyms) do
			local short = pandoc.utils.stringify(acronym.short)
			local name = acronym.name or short:gsub("%W", ""):lower() .. index
			acronym.name = name
			acronyms[short] = { name = name, plural = false }
			if acronym["short-plural"] then
				acronyms[pandoc.utils.stringify(acronym["short-plural"])] = { name = name, plural = true }
			end
		end
	end
	meta_before = meta
end

local function replace(el)
	local prefix, text, suffix = el.text:match "^(%p*)(%w+)(%p*)$"
	local acronym = acronyms[text]
	if acronym then
		local result = {}
		if #prefix > 0 then
			table.insert(result, prefix)
		end
		local command = (acronym.plural and "\\acp{" or "\\ac{") .. acronym.name .. "}"
		table.insert(result, pandoc.RawInline("latex", command))
		if #suffix > 0 then
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
