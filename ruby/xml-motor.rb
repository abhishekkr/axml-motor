#!/usr/bin/env ruby
#
# XMLMotor_EXECUTIONER ;)
xml_motor_libs = File.join(File.dirname(File.expand_path __FILE__), 'xml-motor', '*.rb')
Dir.glob(xml_motor_libs).each do |lib|
  require lib
end


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

  def self.splitter(xmldata)
    XMLMotorEngine._splitter_ xmldata
  end
  def self.indexify(nodes=nil)
    XMLMotorEngine._indexify_ nodes
  end
  def self.xmldata(nodes, tags=nil, tag_to_find=nil, attrib_to_find=nil, with_tag=false)
    XMLMotorEngine.pre_processed_content nodes, tags, tag_to_find, attrib_to_find, with_tag
  end
end
