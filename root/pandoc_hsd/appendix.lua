if FORMAT:match 'latex' then
	function Div(block)
		if block.identifier == "appendix" then
			return pandoc.Div({ pandoc.RawBlock("latex", "\\appendix") }, { id = "appendix" })
		end
	end
end
