module XMLJoiner
  def self.dejavu_attributes(attrib_hash)
    return nil if attrib_hash.nil?
    attributes = ""
    attrib_hash.each_key do |hash_key|
      attributes += " " + hash_key + "=" + attrib_hash[hash_key]
    end
    attributes
  end

  def self.dejavu_node(node_block)
    return nil if node_block.nil?
    ["<#{node_block.first}#{dejavu_attributes(node_block.last)}>", "</#{node_block.first}>"]
  end
end
