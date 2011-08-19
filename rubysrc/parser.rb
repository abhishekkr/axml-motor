#!/usr/bin/env ruby

def _splitter_ (xmldata, pattern)
end

def get_nodes (node)
  xml=[]
  if node.first.class==String then
    p node.first #xml[:"#{node.first}"]=" "
    xml.push get_nodes(node[1..-1]) unless node.length==1
  elsif node.first.first.include?('/') then
    #xml[:"#{node.first}"]= parse(node[1..-1].to_s) unless node==nil
    xml.push get_nodes(node[1..-1]) unless node.length==1
  else
    p node.first.first #xml[:"#{node.first}"]=" "
    xml.push get_nodes(node[1..-1]) unless node.length==1
  end
  xml
end

def parse(xmldata)
  node=[xmldata.split(/</)[0]]
  xmldata.split(/</)[1..-1].each do |x1|
    node.push x1.split(/>/)
  end
=begin
  xmldata_=_splitter_(xmldata, '<')
  node=[xmldata_[0]]
  xmldata_(/</)[1..-1].each do |x1|
    node.push _splitter_(x1, '>')
  end
=end
p node
#return
  xml=get_nodes node
  p xml
end

ARGV.each do |args|
  content = "HTML Eg <html> <head> <title>top bar </title></head><body> here is<h1>BODY</h1></body> </html>"
  begin
    content = File.read(args)
  rescue
    p args + " can't be read... using deafult content here"
  end

  parse content
end

parse "HTML Eg <html> <head> <title>top bar </title></head><body> here is<h1>BODY</h1> tag</body> </html>" if ARGV.length==0
