#!/usr/bin/env ruby

module XML_INDEX_HANDLER
  def self.get_node_indexes(xml_motor, tag)
    xml_idx_to_find = []
    xml_motor.xmltags[tag.split(".")[0]].each_value do |v|
        xml_idx_to_find.push v
    end
    xml_idx_to_find = xml_idx_to_find.flatten

    tag.split(".")[1..-1].each do |tag_i|
      outer_idx = xml_idx_to_find
      osize=outer_idx.size/2 -1
      x_curr=[]
      xml_motor.xmltags[tag_i].each_value do |v|
         x_curr.push v
      end
      x_curr = x_curr.flatten
      xsize=x_curr.size/2 -1

      xml_idx_to_find = expand_node_indexes outer_idx, osize, x_curr, xsize
    end
    xml_idx_to_find
  end

  def self.expand_node_indexes(outer_idx, osize, x_curr, xsize)
    exapnded_node_indexes = []
    0.upto osize do |o|
      o1=outer_idx[o*2]
      o2=outer_idx[o*2 +1]
      0.upto xsize do |x|
        x1=x_curr[x*2]
        x2=x_curr[x*2 +1]
        unless o1>x1 or o2<x2
          exapnded_node_indexes.push x1
          exapnded_node_indexes.push x2
        end
      end
    end
    exapnded_node_indexes.flatten
  end
end

module XML_CHOPPER
  def self.get_tag_attrib_value(tag_value)
    tag_value_split = tag_value.split(/>/)
    in_tag = tag_value_split.first
    out_tag = tag_value_split[1..-1].join
    in_tag_split = in_tag.split(/[ \t]/)
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
      value_n_attrib = attrib_part.split(/[ \t]/)
      values = value_n_attrib[0..-2].join(' ')
      attrs[attribs] = values
      attribs = value_n_attrib[-1].strip
    end
    values = broken_attrib.last.strip
    attrs[attribs] = values
    attrs
  end
end

module XML_JOINER
  def self.dejavu_attributes(attrib_hash)
    return nil if attrib_hash.nil?
    attributes=""
    attrib_hash.each_key do |hash_key|
      attributes += " " + hash_key + "=" + attrib_hash[hash_key]
    end
    attributes
  end
end

##
# main class
##

class XML_MOTOR
  def _splitter_(xmldata)
    @xmlnodes=[xmldata.split(/</)[0]]
    xmldata.split(/</)[1..-1].each do |x1|
      @xmlnodes.push  XML_CHOPPER.get_tag_attrib_value(x1)
    end
  end

  def _indexify_
    @xmltags = {}
    idx = 1
    depth = 0
    @xmlnodes[1..-1].each do |xnode|
      tag_name = xnode[0][0]
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
  end

  def _grab_my_node_ (tag)
    xml_to_find = XML_INDEX_HANDLER.get_node_indexes self, tag
    nodes = []
    node_count = xml_to_find.size/2 -1
    0.upto node_count do |ncount|
      nodes[ncount] = ""
      node_start = xml_to_find[ncount*2]
      node_stop = xml_to_find[ncount*2 +1]
      nodes[ncount] += @xmlnodes[node_start][1] unless @xmlnodes[node_start][1].nil?
      (node_start+1).upto (node_stop-1) do |node_idx|
        any_attrib ||= ""
        any_attrib =  XML_JOINER.dejavu_attributes(@xmlnodes[node_idx][0][1]).to_s unless @xmlnodes[node_idx][0][1].nil?
        nodes[ncount] += "<" + @xmlnodes[node_idx][0][0] + any_attrib + ">"
        nodes[ncount] += @xmlnodes[node_idx][1] unless @xmlnodes[node_idx][1].nil?
      end
    end
    nodes
  end

  def xml_handler(xmldata, tag_to_find)
    _splitter_ xmldata
    _indexify_
    my_nodes = _grab_my_node_ tag_to_find
    my_nodes
  end

  def xmlnodes
    @xmlnodes
  end

  def xmltags
    @xmltags
  end
end

##
# XML_MOTOR_EXECUTIONER ;)
##

class XML_MOTOR_EXEC
  def if_no_args(argv=[])
    if argv.size==0
      puts <<-eof
      XML_MOTOR got no OIL to run :)   

      No Arguments Provided.
      [As A Code Library] How To Use:
        Usage:
         + Include the 'parser.rb'
         + To find values of an xml node from an xml file
           XML_MOTOR_EXEC.new.get_node_from_file <file_with_path>, <node>
         + To find values of an xml node from an xml string
           XML_MOTOR_EXEC.new.get_node_from_content <xml_string>, <node>
        Example Calls As Code:
         + XML_MOTOR_EXEC.new.get_node_from_content "<A>a</A><B><A>ba</A></B>", "A"
             RETURNS: ["a", "ba"]
         + XML_MOTOR_EXEC.new.get_node_from_content "<A>a</A><B><A>ba</A></B>", "B.A"
             RETURNS: ["ba"]

      [Directly As a Tool] How To Use:
        Syntax:
         + To find values of an xml node from an xml file
           $ parser.rb -f <xml_file> -n <node_to_find>
         + To find values of an xml node from an xml string
           $ parser.rb -s <xml_string> -n <node_to_find>
         + To find values of an xml node from an xml file & string, both
           $ parser.rb -f <xml_file> -s <xml_string> -n <node_to_find>
        Example Run As Tool:
           $ ruby run_as_tool.rb -n "A" -s "<A>a</A><B><A>ba</A></B>"
             DISPLAYS:
             a
             ba
           $ ruby run_as_tool.rb -n "B.A" -s "<A>a</A><B><A>ba</A></B>"
             DISPLAYS:
             ba

      eof
      return false
    end
    true
  end

  def get_file_str_node(argv)
    switch=nil
    file_str_node = {}
    argv.each do |args|
      if ["-f","-s","-n"].include?(switch) and ["-f","-s","-n"].include?(args)
        puts "You provided an empty switch #{switch}, still trying to execute with rest of information provided."
        switch = args
        next
      end

      case switch
        when "-f"
          file_str_node["file"] = args
        when "-s"
          file_str_node["content"] = args
        when "-n"
          file_str_node["my_node"] = args
      end
      switch = args
    end

    if file_str_node["file"].nil? and file_str_node["content"].nil?
      puts "No xml string or file provided. Provide it with '-s|-f' switch.\n" 
      return if_no_args
    elsif file_str_node["my_node"].nil?
      puts "No node provided to search. Provide it with '-n' switch." 
      return if_no_args
    end

    file_str_node
  end

  def get_node_from_file(file, my_node)
    unless file.nil?
      if File.readable? file
        begin
          return XML_MOTOR.new.xml_handler File.read, my_node
        rescue
          puts "Error: problem parsing File Content"
        end
      else
        puts "Error: #{file} is not readable."
      end
    end
    return ""
  end

  def get_node_from_content(content, my_node)
    unless content.nil?
      begin
        return XML_MOTOR.new.xml_handler content, my_node
      rescue
        puts "Error problem parsing String Content #{content}"
      end
    end
    return ""
  end
end


##
# just a direct_execute method
# UnComment METHOD CALL below for using it as a TOOL
## 

=begin
def if_direct_exec
  return unless XML_MOTOR_EXEC.new.if_no_args ARGV
  file_str_node = XML_MOTOR_EXEC.new.get_file_str_node ARGV

  return unless file_str_node

  node_from_file = XML_MOTOR_EXEC.new.get_node_from_file file_str_node["file"], file_str_node["my_node"]
  node_from_content = XML_MOTOR_EXEC.new.get_node_from_content file_str_node["content"], file_str_node["my_node"]
 
  my_node = []
  my_node.push node_from_file unless node_from_file.empty?
  my_node.push node_from_content unless node_from_content.empty?
  puts my_node
end

if_direct_exec
=end
