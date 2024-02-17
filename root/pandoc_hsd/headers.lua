local function get_author(meta)
	local author
	if pandoc.utils.type(meta.author) == "List" then
		author = meta.author[1]
	else
		author = meta.author
	end
	return pandoc.utils.stringify(author)
end

function Meta(meta)
	if not meta["header-includes"] then
		meta["header-includes"] = {}
	end
	if not meta["date-meta"] then
		meta["date-meta"] = os.date("%Y-%m-%d")
	end
	if not meta.date and meta.months then
		local month = pandoc.utils.stringify(meta.months[os.date("*t").month])
		meta.date = month .. " " .. os.date("%Y")
	end
	local includes = meta["header-includes"]
	if FORMAT:match 'latex' then
		-- add package to prevent widows
		table.insert(includes, pandoc.RawBlock("latex", "\\usepackage[all,defaultlines=3]{nowidow}"))
		-- add package to allow inclusion of external PDFs
		table.insert(includes, pandoc.RawBlock("latex", "\\usepackage{pdfpages}"))
		-- add emoji support
		if meta.emoji then
			table.insert(includes, pandoc.RawBlock("latex", [[
				\directlua{luaotfload.add_fallback(
					"emojifallback",
					{"NotoColorEmoji:mode=harf;"}
				)}
				\setmainfont[RawFeature={fallback=emojifallback}]{LatinModernRoman}
				\setmonofont[RawFeature={fallback=emojifallback}]{LatinModernMono}
			]]))
		end
		-- configure code block style
		local listing_style = meta["listing-style"] and pandoc.utils.stringify(meta["listing-style"])
		if listing_style then
			table.insert(includes, pandoc.RawBlock("latex", "\\AtEndPreamble{%\n\\floatstyle{" ..
				listing_style .. "}\n\\restylefloat{codelisting}\n}"))
		end
		-- configure custom page header and footer
		local title = pandoc.utils.stringify(meta["title-head"] or meta.title)
		local foot_left_items = {}
		for _, key in ipairs({ "thesis-type", "thesis-university", "thesis-faculty", "thesis-area" }) do
			if meta[key] then
				table.insert(foot_left_items, pandoc.utils.stringify(meta[key]))
			end
		end
		local date_text = pandoc.utils.stringify(meta.date)
		local foot_right = get_author(meta) .. ", " .. date_text
		local foot_left = table.concat(foot_left_items, ", ")
		table.insert(includes, pandoc.RawBlock("latex", [[
			\usepackage{fancyhdr}
			\fancyhead{}
			\fancyhead[L]{\textbf{]] .. title .. [[}}
			\fancyhead[R]{\thepage}
			\fancyfoot{}
			\fancyfoot[C]{\footnotesize{]] .. foot_left .. "\\\\" .. foot_right .. [[}}
			\pagestyle{fancy}
			\makeatletter
			\renewcommand\chapter{\if@openright\cleardoublepage\else\clearpage\fi
				\thispagestyle{fancy}
				\global\@topnum\z@
				\@afterindentfalse
				\secdef\@chapter\@schapter}
			\makeatother

		]]))
	end
	return meta
end
