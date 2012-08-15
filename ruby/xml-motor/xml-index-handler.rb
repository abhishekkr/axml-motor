module XMLIndexHandler
  def self.get_tag_indexes(xml_motor, tag)
   xml_idx_to_find = []
   begin
    xml_motor.xmltags[tag.split(".")[0]].each_value {|val| xml_idx_to_find.push val }
    xml_idx_to_find = xml_idx_to_find.flatten

    tag.split(".")[1..-1].each do |tag_i|
      outer_idx = xml_idx_to_find
      x_curr = []
      xml_motor.xmltags[tag_i].each_value {|val|  x_curr.push val }
      x_curr = x_curr.flatten

      xml_idx_to_find = expand_node_indexes outer_idx, x_curr
    end
   rescue
    XMLStdout._err "Finding index for tag:#{tag}.\nLook if it's actually present in the provided XML."
    return []
   end
   xml_idx_to_find
  end

  def self.expand_node_indexes(outer_idx, x_curr)
    osize = outer_idx.size/2 -1
    xsize = x_curr.size/2 -1
    expanded_node_indexes = []
    0.upto osize do |o|
      o1 = outer_idx[o*2]
      o2 = outer_idx[o*2 +1]
      0.upto xsize do |x|
        x1 = x_curr[x*2]
        x2 = x_curr[x*2 +1]
        unless o1>x1 or o2<x2
          expanded_node_indexes.push x1
          expanded_node_indexes.push x2
        end
      end
    end
    expanded_node_indexes.flatten
  end
end
