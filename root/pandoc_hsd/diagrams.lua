local mermaid = pandoc.system.environment().MERMAID_BIN or "mmdc"
local plantuml = pandoc.system.environment().PLANTUML_BIN or "plantuml"
local cache_directory = pandoc.system.environment().FILTER_CACHE or ".cache"
local verbose = pandoc.system.environment().FILTER_VERBOSE

local content_type = {
	png = {
		mime = "image/png",
		extension = "png"
	},
	svg = {
		mime = "image/svg+xml",
		extension = "svg"
	},
	pdf = {
		mime = "application/pdf",
		extension = "pdf"
	},
}

local function render_plantuml(plantuml_arguments, code)
	local image
	pandoc.system.with_working_directory("/tmp", function()
		image = pandoc.pipe(plantuml, { "-tsvg", "-pipe", table.unpack(plantuml_arguments) }, code)
	end)
	return image
end

local function render_mermaid(arguments, code)
	local path_svg = "/tmp/mermaid.svg"
	local path = "/tmp/mermaid.pdf"
	-- pandoc.pipe(mermaid, { "-p", "/pandoc_hsd/puppeteer-config.json", "-i", "-", "-e", "svg", "-o", path_svg, "-s", "4.1667" }, code)
	pandoc.pipe(mermaid, { "-p", "/pandoc_hsd/puppeteer-config.json", "-i", "-", "-e", "svg", "-o", path_svg }, code)
	os.execute(("/pandoc_hsd/svg2pdf %s %s"):format(path_svg, path))
	local file = io.open(path, "rb")
	if not file then return nil end
	local content = file:read "*a"
	file:close()
	return content
end

local diagram_engines = {
	plantuml = {
		arguments = {},
		content_type = content_type.svg,
		render = render_plantuml
	},
	mermaid = {
		arguments = {},
		-- the latex svg package does not work properly with mermaid svgs
		content_type = content_type.pdf,
		render = render_mermaid
	},
}

local function read_metadata(meta)
	-- read options for plantuml
	local plantuml_arguments = diagram_engines.plantuml.arguments
	local skinparams = meta["plantuml-skinparams"]
	if skinparams then
		for key, value in pairs(skinparams) do
			table.insert(plantuml_arguments, "-S" .. key .. "=" .. pandoc.utils.stringify(value))
		end
	end
	local theme = meta["plantuml-theme"]
	if theme then
		table.insert(plantuml_arguments, "-theme")
		table.insert(plantuml_arguments, pandoc.utils.stringify(theme))
	end
end

local function render_diagrams(block)
	local engine_name = block.classes[1]
	local engine = diagram_engines[engine_name]
	if engine then
		local code = block.text
		local hash = pandoc.sha1(engine_name .. table.concat(engine.arguments) .. code)
		local type = engine.content_type
		local file_name = hash .. "." .. type.extension
		local cache_name = pandoc.path.join({ cache_directory, file_name })
		local file = io.open(cache_name, "rb")
		if file then
			file:close()
			if verbose then
				io.stderr:write(("pandoc diagrams filter: using cached diagram for %s from %s\n"):format(block.identifier, cache_name))
			end
		else
			local image = engine.render(engine.arguments, code)
			pandoc.system.make_directory(cache_directory, true)
			file = io.open(cache_name, "wb")
			if file then
				file:write(image)
				file:close()
			else
				io.stderr:write(("pandoc diagrams filter: failed to create diagram cache file for %s to %s\n"):format(block.identifier, cache_name))
				pandoc.mediabag.insert(cache_name, type.mime, image)
			end
			if verbose then
				io.stderr:write(("pandoc diagrams filter: generated diagram %s to %s\n"):format(block.identifier, cache_name))
			end
		end
		local node
		if type == content_type.pdf then
			node = pandoc.RawInline("latex", ("\\includegraphics{%s}"):format(cache_name))
		else
			node = pandoc.Image({}, cache_name, nil, block.attr)
		end
		return pandoc.Figure(node, block.attributes.caption and { pandoc.Str(block.attributes.caption) }, block.attr)
	end
end

return { { Meta = read_metadata }, { CodeBlock = render_diagrams } }
