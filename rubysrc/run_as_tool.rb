#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), "parser.rb")

##
# just a direct_execute method
# UnComment METHOD CALL below for using it as a TOOL
## 

def if_direct_exec
  return false unless XMLMotor.if_no_args ARGV
  file_str_node = XMLMotor.get_file_str_node ARGV

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
