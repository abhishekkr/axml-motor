#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), "xml-motor.rb")

##
# just a direct_execute method
# UnComment METHOD CALL below for using it as a TOOL
## 

module XMLMotorAsTool
  def self.if_no_args(argv=[])
    if argv.size==0
      puts <<-eof
      XMLMotor got no OIL to run :)   

      No Arguments Provided.

      [As A Ruby Gem] How To Use:
        Loading:
         + $ gem install xml-motor
         + 'require' the 'xml-motor'

      [As A Code Library] How To Use:
        Loading:
         + 'require' the 'xml-motor.rb'

        Usage:
           [[ To Search Just One QUERY ]]
             nodes_array = XMLMotor.get_node_from_file "_XML_FILE_"
             nodes_array = XMLMotor.get_node_from_file "_XML_FILE_", "ATTRIB_KEY=ATTRIB_VALUE"
             nodes_array = XMLMotor.get_node_from_content "_XML_DATA_"
             nodes_array = XMLMotor.get_node_from_content "_XML_DATA_", "ATTRIB_KEY=ATTRIB_VALUE"
           [[ To Search More Than One QUERIES ]]
             str = {XML_DATA}
             nodes_ = XMLMotorEngine._splitter_ str
             tags_ = XMLMotorEngine._indexify_ nodes_
             nodes_array = XMLMotorEngine.pre_processed_content nodes_, tags_, "_TAG_"
             nodes_array = XMLMotorEngine.pre_processed_content nodes_, tags_, "_TAG_", "ATTRIB_KEY=ATTRIB_VALUE"

        Example Calls As Code:
         + XMLMotor.new.get_node_from_content "<A>a</A><B><A>ba</A></B>", "A"
             RETURNS: ["a", "ba"]
         + XMLMotor.new.get_node_from_content "<A>a</A><B><A>ba</A></B>", "B.A"
             RETURNS: ["ba"]
         + XMLMotor.new.get_node_from_content "<A i='1'>a</A><B><A i='2'>ba</A></B>", "A", "i='1'"
             RETURNS: ["a"]

      [Directly As a Tool] How To Use:
        Syntax:
         + To find values of an xml node from an xml file
           $ ruby run_as_tool.rb -f <xml_file> -n <node_to_find>
         + To find values of an xml node from an xml string
           $ ruby run_as_tool.rb -s <xml_string> -n <node_to_find>
         + To find values of an xml node from an xml file & string, both
           $ ruby run_as_tool.rb -f <xml_file> -s <xml_string> -n <node_to_find>
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

  def self.get_file_str_node(argv)
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
end

def if_direct_exec
  return false unless XMLMotorAsTool.if_no_args ARGV
  file_str_node = XMLMotorAsTool.get_file_str_node ARGV
  return false unless file_str_node

  node_from_file = XMLMotor.get_node_from_file file_str_node["file"], file_str_node["my_node"]
  node_from_content = XMLMotor.get_node_from_content file_str_node["content"], file_str_node["my_node"]
 
  my_node = []
  my_node.push node_from_file unless node_from_file.empty?
  my_node.push node_from_content unless node_from_content.empty?
  puts my_node
  true
end

unless ARGV.empty?
  if ARGV[0].match("-eg")
    puts "+"*100
    puts "XML: 'XML <div>parsing <span>is</span> revived</div> now. ~=ABK=~'", "NODE: span"
    puts XMLMotor.get_node_from_content "XML <div>parsing <span>is</span> revived</div> now. ~=ABK=~", "span"
    puts "+"*100
    puts "XML: 'XML <div>parsing <span>is</span> revived</div> now. ~=ABK=~'", "NODE: div"
    puts XMLMotor.get_node_from_content "XML <div>parsing <span>is</span> revived</div> now. ~=ABK=~", "div" 
    puts "+"*100
    exit 0
  end
end

unless if_direct_exec
  puts <<-noArgs
       
       Could run in Example Mode, if have nothing in mind.....
         $ ruby run_as_tool.rb -eg
       
        noArgs
end
