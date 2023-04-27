if FORMAT:match 'latex' then
    function CodeBlock(block)
        if block.classes[1] == "tikzpicture" then
            return pandoc.Figure(
                pandoc.RawBlock("latex", "\\begin{tikzpicture}\n" .. block.text .. "\n\\end{tikzpicture}"),
                block.attributes.caption and { pandoc.Str(block.attributes.caption) },
                block.attr)
        end
    end
end
