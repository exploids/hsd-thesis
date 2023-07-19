function Div(block)
	if block.identifier == "end" then
		return {
			pandoc.Div({}, { id = "bibliography" }),
			pandoc.Div({}, { id = "lof" }),
			pandoc.Div({}, { id = "lot" }),
			pandoc.Div({}, { id = "lol" }),
			pandoc.Div({}, { id = "acronyms" }),
			pandoc.Div({}, { id = "appendix" })
		}
	end
end
