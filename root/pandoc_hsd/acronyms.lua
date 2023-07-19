local meta_before
local acronyms = {}

local function compare_acronyms(a, b)
	return pandoc.utils.stringify(a.short):upper() < pandoc.utils.stringify(b.short):upper()
end

local function load_acronyms(meta)
	local meta_acronyms = meta.acronyms
	if meta_acronyms ~= nil then
		local longest = ""
		local used_names = {}
		for _, acronym in ipairs(meta_acronyms) do
			local short = pandoc.utils.stringify(acronym.short)
			local base_name = acronym.name or short:gsub("%W", ""):lower()
			local name, counter = base_name, 1
			while used_names[name] do
				name, counter = base_name .. counter, counter + 1
			end
			used_names[name] = true
			acronym.name = name
			acronyms[short] = { name = name, plural = false }
			if acronym["short-plural"] then
				acronyms[pandoc.utils.stringify(acronym["short-plural"])] = { name = name, plural = true }
			end
			if #short > #longest then
				longest = short
			end
		end
		if not meta["acronyms-longest"] then
			meta["acronyms-longest"] = longest
		end
		table.sort(meta_acronyms, compare_acronyms)
	end
	meta_before = meta
end

local function replace(el)
	local prefix, text, suffix = el.text:match "^(%p*)(%w+)(%p*)$"
	local acronym = acronyms[text]
	if acronym and FORMAT:match "latex" then
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

local function list_of_acronyms(block)
	if meta_before.acronyms and block.identifier == "acronyms" and FORMAT:match "latex" then
		local content = ""
		local title = meta_before["acronyms-title"] and pandoc.utils.stringify(meta_before["acronyms-title"])
		local longest = pandoc.utils.stringify(meta_before["acronyms-longest"])
		if title then
			content = content .. "\\chapter*{" .. title .. "}" ..
				"\n\\addcontentsline{toc}{chapter}{" .. title .. "}\n"
		end
		content = content .. "\\begin{acronym}[" .. longest .. "]"
		for _, acronym in ipairs(meta_before.acronyms) do
			local name = pandoc.utils.stringify(acronym.name)
			local short = pandoc.utils.stringify(acronym.short)
			local long = pandoc.utils.stringify(acronym.long)
			local short_plural = acronym["short-plural"] and pandoc.utils.stringify(acronym["short-plural"])
			local long_plural = acronym["long-plural"] and pandoc.utils.stringify(acronym["long-plural"])
			content = content .. "\\acro{" .. name .. "}[" .. short .. "]{" .. long .. "}\n"
			if short_plural then
				long_plural = long_plural or long
				content = content .. "\\acroplural{" .. name .. "}[" .. short_plural .. "]{" .. long_plural .. "}\n"
			end
		end
		content = content .. "\\end{acronym}"
		return pandoc.Div({ pandoc.RawBlock("latex", content) }, { id = "acronyms" })
	end
end

local function restore_vars()
	return meta_before
end

return {
	{ Meta = load_acronyms },
	{ Str = replace, Div = list_of_acronyms },
	{ Meta = restore_vars }
}
