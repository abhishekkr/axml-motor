#!/usr/bin/env ruby

module XMLStdout
  def self._err(mesag); puts "ERROR:: #{mesag}"; end
  def self._nfo(mesag); puts "INFORMATION:: #{mesag}"; end
end

module XMLUtils
  def self.dbqot_string(attrib_val)
    return nil if attrib_val.nil?
    matched_data = attrib_val.strip.match(/^'(.*)'$/)
    return attrib_val if matched_data.nil?
    matched_data = matched_data[0].gsub("\"","'")
    matched_data[0] = matched_data[-1] = "\""
    matched_data
  end
end

module XMLIndexHandler
  def self.get_node_indexes(xml_motor, tag)
   xml_idx_to_find = []
   begin
    xml_motor.xmltags[tag.split(".")[0]].each_value {|val|  xml_idx_to_find.push val }
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

module XMLChopper
  def self.get_tag_attrib_value(tag_value)
    tag_value_split = tag_value.split(/>/)
    in_tag = tag_value_split.first
    out_tag = tag_value_split[1..-1].join
    in_tag_split = in_tag.split
    tag_name = in_tag_split.first
    attribzone = in_tag_split[1..-1].flatten.join(' ')
    attrs = get_attribute_hash attribzone
    [[tag_name,attrs],out_tag]
  end

  def self.get_attribute_hash(attribzone)
    attribzone = attribzone.strip unless attribzone.nil?
    return nil if attribzone.nil? or attribzone==""
    attrs = {}
    broken_attrib = attribzone.split(/=/)
    attribs = broken_attrib.first.strip
    values = nil
    broken_attrib[1..-2].each do |attrib_part|
      value_n_attrib = attrib_part.split
      values = value_n_attrib[0..-2].join(' ')
      attrs[attribs] = XMLUtils.dbqot_string values
      attribs = value_n_attrib[-1].strip
    end
    values = broken_attrib.last.strip
    attrs[attribs] = XMLUtils.dbqot_string values
    attrs
  end
end

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

module XMLMotorEngine
  def self._splitter_(xmldata)
    @xmlnodes = [xmldata.split(/</)[0]]
    xmldata.split(/</)[1..-1].each do |x1|
      @xmlnodes.push  XMLChopper.get_tag_attrib_value(x1)
    end
    @xmlnodes
  end

  def self._indexify_(_nodes=nil)
    xmlnodes _nodes unless _nodes.nil?
    @xmltags = {}
    idx = 1
    depth = 0
    @xmlnodes[1..-1].each do |xnode|
      tag_name = xnode[0][0].strip
      unless tag_name.match(/^\/.*/) then
        @xmltags[tag_name] ||= {}
        @xmltags[tag_name][depth] ||= []
        @xmltags[tag_name][depth].push idx
        depth += 1
      else
        depth -= 1
        @xmltags[tag_name[1..-1]][depth] ||= []
        @xmltags[tag_name[1..-1]][depth].push idx
      end
      idx +=1
    end
    @xmltags
  end

  def self._get_attrib_key_val_ (attrib)
    attrib_key = attrib.split(/=/)[0].strip
    attrib_val = attrib.split(/=/)[1..-1].join.strip
    [attrib_key, XMLUtils.dbqot_string(attrib_val)]
  end

  def self._grab_my_node_ (xml_to_find, attrib_to_find=nil, with_tag=false)
    unless attrib_to_find.nil? or attrib_to_find.empty?
      attrib_keyval = [attrib_to_find].flatten.collect{|keyval| _get_attrib_key_val_ keyval }
    end
    nodes = []
    node_count = xml_to_find.size/2 -1
    0.upto node_count do |ncount|
      node_start = xml_to_find[ncount*2]
      node_stop = xml_to_find[ncount*2 +1]
      unless attrib_to_find.nil? or attrib_to_find.empty?
	next if @xmlnodes[node_start][0][1].nil?
        next if attrib_keyval.collect{|keyval| @xmlnodes[node_start][0][1][keyval.first] == keyval.last}.include? false
      end
      nodes[ncount] ||= ""
      nodes[ncount] += @xmlnodes[node_start][1] unless @xmlnodes[node_start][1].nil?
      (node_start+1).upto (node_stop-1) do |node_idx|
        any_attrib ||= ""
        any_attrib = XMLJoiner.dejavu_attributes(@xmlnodes[node_idx][0][1]).to_s unless @xmlnodes[node_idx][0][1].nil?
        nodes[ncount] += "<" + @xmlnodes[node_idx][0][0] + any_attrib + ">"
        nodes[ncount] += @xmlnodes[node_idx][1] unless @xmlnodes[node_idx][1].nil?
      end
      if with_tag
        tagifyd = XMLJoiner.dejavu_node @xmlnodes[node_start][0]
        nodes[ncount] = tagifyd.first + nodes[ncount] + tagifyd.last
      end
    end
    nodes.delete(nil) unless attrib_to_find.nil?
    nodes
  end

  def self.xml_extracter(tag_to_find=nil, attrib_to_find=nil, with_tag=false)
    my_nodes = nil
    if attrib_to_find.nil? and tag_to_find.nil?
    elsif attrib_to_find.nil?
      xml_to_find = XMLIndexHandler.get_node_indexes self, tag_to_find
      my_nodes = _grab_my_node_ xml_to_find, nil, with_tag
    elsif tag_to_find.nil? 
      #
      XMLStdout._nfo "Just attrib-based search to come"
      #
    else
      xml_to_find = XMLIndexHandler.get_node_indexes self, tag_to_find
      my_nodes = _grab_my_node_ xml_to_find, attrib_to_find, with_tag
    end
    my_nodes
  end  

  def self.xml_miner(xmldata, tag_to_find=nil, attrib_to_find=nil, with_tag=false)
    return nil if xmldata.nil?
    _splitter_ xmldata
    _indexify_
    xml_extracter tag_to_find, attrib_to_find, with_tag
  end 

  def self.xmlnodes(xml_nodes=nil)
    @xmlnodes = xml_nodes || @xmlnodes
  end

  def self.xmltags(xml_tags=nil)
    @xmltags = xml_tags || @xmltags
  end

  def self.pre_processed_content(_nodes, _tags=nil, tag_to_find=nil, attrib_to_find=nil, with_tag=false)
    begin
      xmlnodes _nodes
      unless _tags.nil?
        xmltags _tags
      else
        _indexify_ 
      end
      return xml_extracter tag_to_find, attrib_to_find, with_tag
    rescue
      XMLStdout._err "Parsing processed XML Nodes."
    end
    return nil 
  end
end

##
# XMLMotor_EXECUTIONER ;)

module XMLMotor
  def self.get_node_from_file(file, my_tag=nil, my_attrib=nil, with_tag=false)
    begin
      return get_node_from_content(File.read(file.to_s), my_tag, my_attrib, with_tag) if File.readable? file.to_s
    rescue
      XMLStdout._err "#{file} is not readable."
    end
    return ""
  end

  def self.get_node_from_content(content, my_tag=nil, my_attrib=nil, with_tag=false)
    begin
      return XMLMotorEngine.xml_miner content, my_tag, my_attrib, with_tag unless content.nil?
    rescue
      XMLStdout._err "Parsing String Content #{content}"
    end
    return ""
  end
end

