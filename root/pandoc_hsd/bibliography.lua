function Div(block)
	if block.identifier == "bibliography" then
		return {
			pandoc.Div({}, { id = "biblio-title" }),
			pandoc.Div({}, { id = "refs" })
		}
	end
end
