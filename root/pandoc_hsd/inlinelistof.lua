local biblio_title, list_of_listings_title

local function load_meta(meta)
	meta.lof = false
	meta.lot = false
	biblio_title = meta["biblio-title"] and pandoc.utils.stringify(meta["biblio-title"])
	list_of_listings_title = meta["lolTitle"] and pandoc.utils.stringify(meta["lolTitle"])
	return meta
end

local function replace(block)
	if block.identifier == "biblio-title" then
		return pandoc.Header(1, biblio_title, { id = "biblio-title", class = "unnumbered" })
	-- elseif block.identifier == "refs" then
	-- 	return pandoc.Div({
	-- 		pandoc.RawBlock("latex", "\\printbibliography[heading=none]")
	-- 	}, { id = "refs" })
	elseif block.identifier == "lof" then
		if FORMAT:match "latex" then
			return pandoc.Div({
				pandoc.RawBlock("latex", "\\listoffigures\n\\addcontentsline{toc}{chapter}{\\listfigurename}")
			}, { id = "lof" })
		else
			io.stderr:write(("'lof' is omitted in the %s format [inlinelistof.lua]\n"):format(FORMAT))
		end
	elseif block.identifier == "lot" then
		if FORMAT:match "latex" then
			return pandoc.Div({
				pandoc.RawBlock("latex", "\\listoftables\n\\addcontentsline{toc}{chapter}{\\listtablename}")
			}, { id = "lot" })
		else
			io.stderr:write(("'lot' is omitted in the %s format [inlinelistof.lua]\n"):format(FORMAT))
		end
	elseif block.identifier == "lol" then
		if FORMAT:match "latex" then
			return pandoc.Div({
				pandoc.RawBlock("latex",
					"\\listoflistings\n\\addcontentsline{toc}{chapter}{" .. list_of_listings_title .. "}")
			}, { id = "lol" })
		else
			io.stderr:write(("'lol' is omitted in the %s format [inlinelistof.lua]\n"):format(FORMAT))
		end
	end
end

return { { Meta = load_meta }, { Div = replace } }
