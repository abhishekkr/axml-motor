module XMLMotorEngine
  def self._splitter_(xmldata)
    start_splits = xmldata.split(/</)
    @xmlnodes = [start_splits[0]]
    start_splits[1..-1].each do |val|
      tag_attr = XMLChopper.get_tag_attrib_value(val.gsub('/>','>'))
      if val.match(/\/>/)
        post_attr = tag_attr[1]
        tag_attr[1] = ''
        @xmlnodes.push tag_attr
        @xmlnodes.push [["/#{tag_attr[0][0]}", nil], post_attr]
      else
        @xmlnodes.push tag_attr
      end
    end
    @xmlnodes
  end

  def self._indexify_(_nodes=nil)
    xmlnodes _nodes unless _nodes.nil?
    @xmltags = {}
    idx = 1
    depth = 0
    @xmlnodes[1..-1].each do |xnode|
      tag_name = xnode[0][0].strip.downcase
      if tag_name.match(/^\/.*/) then
        depth -= 1
        @xmltags[tag_name[1..-1]][depth] ||= []
        @xmltags[tag_name[1..-1]][depth].push idx
      elsif tag_name.chomp.match(/^\/$/) then
        @xmltags[tag_name] ||= {}
        @xmltags[tag_name][depth] ||= []
        @xmltags[tag_name][depth].push idx
        @xmltags[tag_name][depth].push idx
      else
        @xmltags[tag_name] ||= {}
        @xmltags[tag_name][depth] ||= []
        @xmltags[tag_name][depth].push idx
        depth += 1
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

  def self._grab_my_node_ (index_to_find, attrib_to_find=nil, with_tag=false)
    unless attrib_to_find.nil? or attrib_to_find.empty?
      attrib_keyval = [attrib_to_find].flatten.collect{|keyval| _get_attrib_key_val_ keyval }
      attrib_justkey = attrib_keyval.select{|attr| attr[1].empty?}
      attrib_justval = attrib_keyval.select{|attr| attr[0].empty?}
      attrib_keyval  -= (attrib_justkey + attrib_justval)
    end
    nodes = []
    node_count = index_to_find.size/2 - 1
    0.upto node_count do |ncount|
      node_start = index_to_find[ncount*2]
      node_stop = index_to_find[ncount*2 +1]
      unless attrib_to_find.nil? or attrib_to_find.empty?
      	next if @xmlnodes[node_start][0][1].nil?
        check_keyval = attrib_keyval.collect{|keyval| @xmlnodes[node_start][0][1][keyval.first] == keyval.last}.include? false
        check_key = attrib_justkey.collect{|key| @xmlnodes[node_start][0][1][key.first].nil? }.include? true
        check_val = attrib_justval.collect{|val| @xmlnodes[node_start][0][1].each_value.include? val[1] }.include? false
        next if check_keyval or check_key or check_val
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
    index_to_find = []
    if attrib_to_find.nil? and tag_to_find.nil?
      return nil
    elsif tag_to_find.nil?
      index_to_find = @xmltags.collect {|xtag| xtag[1].collect {|val| val[1] }}.flatten
    else
      index_to_find = XMLIndexHandler.get_tag_indexes self, tag_to_find.downcase
    end
    _grab_my_node_ index_to_find, attrib_to_find, with_tag
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
