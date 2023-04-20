local plantuml = pandoc.system.environment().PLANTUML_BIN or "plantuml"
local filetypes = { html = { "svg", "image/svg+xml" }, latex = { "svg", "image/svg+xml" } }
local filetype = filetypes[FORMAT][1] or "png"
local mimetype = filetypes[FORMAT][2] or "image/png"

function CodeBlock(block)
	if block.classes[1] == "plantuml" then
		local code = block.text
		local image = None
		pandoc.system.with_working_directory("/tmp", function()
			image = pandoc.pipe(plantuml, { "-t" .. filetype, "-pipe" }, code)
		end)
		local file_name = pandoc.sha1(image) .. "." .. filetype
		pandoc.mediabag.insert(file_name, mimetype, image)
		return pandoc.Para { pandoc.Image({}, file_name, None, block.attr) }
	end
end
