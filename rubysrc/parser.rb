#!/usr/bin/env ruby

def _splitter_ (xmldata)
  xmlnodes=[xmldata.split(/</)[0]]
  xmldata.split(/</)[1..-1].each do |x1|
    xmlnodes.push x1.split(/>/)
  end
  xmlnodes
end

def _indexify_ (xmlnodes)
  xmltags ||= {}
  idx = 1
  depth = 0
  xmlnodes[1..-1].each do |xnode|
    unless xnode[0].match(/^\/.*/) then
      xmltags[xnode[0]] ||= {}
      xmltags[xnode[0]][depth] ||= []
      xmltags[xnode[0]][depth].push idx
      depth += 1
    else
      depth -= 1
      xmltags[xnode[0][1..-1]][depth] ||= []
      xmltags[xnode[0][1..-1]][depth].push idx
    end
    idx +=1
  end
  xmltags
end

def _grab_my_node_ (xmldata, xmltags, tag)
  puts " :grab: " + xmltags.to_s
  puts "|"*10
  xml_to_find = []
  xmltags[tag.split(".")[0]].each_value do |v|
    xml_to_find.push v
  end
  xml_to_find = xml_to_find.flatten
  tag.split(".")[1..-1].each do |tag_i|
    inner_idx = []
    outer_idx = xml_to_find
    osize=outer_idx.size/2 -1
    x_curr=[]
    xmltags[tag_i].each_value do |v|
      x_curr.push v
    end
    x_curr = x_curr.flatten
    xsize=x_curr.size/2 -1

puts "+)(+" + xml_to_find.to_s + " + " + outer_idx.to_s + ":" + osize.to_s + " + " + x_curr.to_s + ":" + xsize.to_s
return
    xml_to_find.push = []
    0.upto osize do |o|
      o1=outer_idx[o*2]
      o2=outer_idx[o*2 +1]
      0.upto xsize do |x|
        x1=x_curr[o*2]
        x2=x_curr[o*2 +1]
        unless o1>x1 or o2<x2
          xml_to_find.push x1
          xml_to_find.push x2
        end
      end
    end
    xml_to_find = xml_to_find.flatten

puts "+!+" + xml_to_find.to_s + " + " + outer_idx.to_s + ":" + osize.to_s + " + " + x_curr.to_s + ":" + xsize.to_s
  end
puts xml_to_find
return
  xmltags[tag].each_key do |depth|
      puts ">"+ xmltags[tag][depth].to_s
  end
  puts "|"*10
end

def xml_handler(xmldata, tag_to_find)
  xmlnodes = _splitter_ xmldata
  xmlobjects = _indexify_ xmlnodes
  puts _grab_my_node_(xmlnodes, xmlobjects, tag_to_find)
  return
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

#xml_handler "<html> <head> <title> top bar </title> </head> <body> here is <h1>BODY</h1> a tag to <h1>work</h1> with.</body> </html>" if ARGV.length==0
puts "+"*100
xml_handler "<html> <head><title>top bar</title></head> <body> <div><span>axml-motor</span><span>work</span></div> <div><span>ruby</span></div>  </body> </html>", "span" if ARGV.length==0
puts "+"*100
xml_handler "<html> <head><title>top bar</title></head> <body> <div><span>axml-motor</span><span>work</span></div> <b><span>ruby</span></b>  </body> </html>", "div.span" if ARGV.length==0
puts "+"*100
