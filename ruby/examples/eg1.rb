#!/usr/bin/env ruby

require 'xml-motor'

fyl = File.join(File.expand_path(File.dirname __FILE__),'dummy.xml')
xml = File.open(fyl,'r'){|fr| fr.read }

puts xml

puts <<-BYFILE

  One-time XML-Parsing directly from file
    fyl = File.join(File.expand_path(File.dirname __FILE__),'dummy.xml')
    puts XMLMotor.get_node_from_file(fyl, 'ummy.mmy', 'class="sys"')
  BYFILE
puts "\t#{XMLMotor.get_node_from_file(fyl, 'ummy.mmy', 'class="sys"')}"

puts <<-BYXML

  One-time XML-Parsing directly from content
    fyl = File.join(File.expand_path(File.dirname __FILE__),'dummy.xml')
    xml = File.open(fyl,'r'){|fr| fr.read }
    puts XMLMotor.get_node_from_content xml, 'dummy.my', 'class="usage"'
  BYXML
puts "\t#{XMLMotor.get_node_from_content xml, 'dummy.my', 'class="usage"'}"

puts <<-XML

  Way to go for XML-Parsing for xml node searches
    xsplit = XMLMotor.splitter xml
    xtags  = XMLMotor.indexify xsplit
  XML
xsplit = XMLMotor.splitter xml
xtags  = XMLMotor.indexify xsplit
puts <<-X1
  [] just normal node name based freehand notation to search:
    puts XMLMotor.xmldata xsplit, xtags, 'dummy.my'
  X1
puts "\t#{XMLMotor.xmldata xsplit, xtags, 'dummy.my'}"
puts <<-X2
  [] searching for values of required nodes filtered by attribute:
    puts XMLMotor.xmldata xsplit, xtags, 'class="usage"'
  X2
puts "\t#{XMLMotor.xmldata xsplit, xtags, nil, 'class="usage"'}"
puts <<-X3
  [] searching for values of required nodes filtered by freehand tag-name notation & attribute:
    puts XMLMotor.xmldata xsplit, xtags, 'dummy.my', 'class="usage"'
  X3
puts "\t#{XMLMotor.xmldata xsplit, xtags, 'dummy.my', 'class="usage"'}"
puts <<-X4
  [] searching for values of required nodes filtered by freehand tag-name notation & multiple attributes:
    puts XMLMotor.xmldata xsplit, xtags, 'dummy.my', ['class="sys"', 'id="mem"']
  X4
puts "\t#{XMLMotor.xmldata xsplit, xtags, 'dummy.my', ['class="sys"', 'id="mem"']}"
