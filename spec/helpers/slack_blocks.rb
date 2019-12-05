module SlackBlocks

  def blocks_contain?(blocks, type, text: nil)
    blocks.any? do |block|
      result = (block["type"] == type)
      if text
        result = result && block["text"] && block["text"]["text"] =~ /.*#{text}.*/i
      end
      result
    end
  end

end