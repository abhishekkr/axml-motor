#!/usr/bin/env ruby

def _splitter_ (xmldata, pattern)
end

def xml_correct? (node)
  correct=true
  xml={}
  node.each do |n|
    if n.class==String then
      next
    elsif n.first.include?('/') then
      tag=n.first.split('/')[1].strip
      if xml[tag]==tag
        xml[tag]="<#{tag}/>"
      else
	xml[tag]=tag
      end
    else
      tag=n.first.strip.split(' ')[0]
      xml[tag]=tag
    end
  end
  xml.each do |key, value|
    if key==value
      puts key + " node is faulty..."
      correct=false
    end
  end
  correct
end

def get_nodes (node)
  return unless xml_correct? node
  xml={}
  node.each do |n|
    if n.class==String then
      xml["~"]=n
    elsif n.first.include?('/') then
      tag=n.first.split('/')[1].strip
      xml[tag]+="</#{tag}>" 
    else
      tag=n.first.strip.split(' ')[0]
      xml[tag]="<#{tag}>"
      xml[tag]+=n[1..-1].to_s unless n.length==1
    end
  end
  xml
end

def xml_handler(xmldata)
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
  puts "|"*25
  puts "for xml:\n" +  xmldata
  puts "~"*25
  xml=get_nodes node
  p xml
  puts "|"*25
end

ARGV.each do |args|
  content = "HTML Eg <html> <head> <title>top bar </title></head><body> here is<h1>BODY</h1></body> </html>"
  begin
    content = File.read(args)
  rescue
    p args + " can't be read... using deafult content here"
  end
  xml_handler content
end

xml_handler "HTML Eg <html> <head> <title>top bar </title></head><body style=\"color:green;\"> here is<h1>BODY</h1> tag</body> </html>" if ARGV.length==0
xml_handler "HTML Eg <html> <head> <title>top bar </title><body style=\"color:green;\"> here is BODY</h1> tag</body> </html>" if ARGV.length==0
