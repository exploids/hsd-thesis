local plantuml = pandoc.system.environment().PLANTUML_BIN or "plantuml"
-- latex/latex:nopreamble output currently has problems with shapes not fitting text dimensions, therfore using svg for latex instead
local filetypes = { html = { "svg", "image/svg+xml" }, latex = { "svg", "image/svg+xml" } }
local filetype = filetypes[FORMAT] and filetypes[FORMAT][1] or "png"
local mimetype = filetypes[FORMAT] and filetypes[FORMAT][2] or "image/png"

local plantuml_arguments = {}

local function read_metadata(meta)
	local skinparams = meta["plantuml-skinparams"]
	local theme = meta["plantuml-theme"]
	if skinparams then
		for key, value in pairs(skinparams) do
			table.insert(plantuml_arguments, "-S" .. key .. "=" .. pandoc.utils.stringify(value))
		end
	end
	if theme then
		table.insert(plantuml_arguments, "-theme")
		table.insert(plantuml_arguments, pandoc.utils.stringify(theme))
	end
end

local function render_plantuml(block)
	if block.classes[1] == "plantuml" then
		local code = block.text
		local image, node
		-- plantuml seems to create temporary files in the working directory
		pandoc.system.with_working_directory("/tmp", function()
			image = pandoc.pipe(plantuml, { "-t" .. filetype, "-pipe", table.unpack(plantuml_arguments) }, code)
		end)
		if filetype == "latex:nopreamble" then
			node = pandoc.RawBlock("latex", image)
		else
			local file_name = "plantuml-" .. pandoc.sha1(code) .. "." .. filetype
			pandoc.mediabag.insert(file_name, mimetype, image)
			node = pandoc.Image({}, file_name, nil, block.attr)
		end
		return pandoc.Figure(node, block.attributes.caption and { pandoc.Str(block.attributes.caption) }, block.attr)
	end
end

return { { Meta = read_metadata }, { CodeBlock = render_plantuml } }
