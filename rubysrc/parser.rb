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

class XML_MOTOR
  def _splitter_(xmldata)
    @xmlnodes=[xmldata.split(/</)[0]]
    xmldata.split(/</)[1..-1].each do |x1|
      @xmlnodes.push x1.split(/>/)
    end
  end

  def _indexify_
    @xmltags = {}
    idx = 1
    depth = 0
    @xmlnodes[1..-1].each do |xnode|
        unless xnode[0].match(/^\/.*/) then
            @xmltags[xnode[0]] ||= {}
            @xmltags[xnode[0]][depth] ||= []
            @xmltags[xnode[0]][depth].push idx
            depth += 1
        else
            depth -= 1
            @xmltags[xnode[0][1..-1]][depth] ||= []
            @xmltags[xnode[0][1..-1]][depth].push idx
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
                nodes[ncount] += "<" + @xmlnodes[node_idx][0] + ">"
                nodes[ncount] += @xmlnodes[node_idx][1] unless @xmlnodes[node_idx][1].nil?
            end
    end
    nodes
  end

  def xml_handler(xmldata, tag_to_find)
    puts "~"*10,xmldata,"~"*10,tag_to_find,"~"*10
    _splitter_ xmldata
    _indexify_
    my_nodes = _grab_my_node_ tag_to_find
    p my_nodes
    return
  end

  def xmlnodes
    @xmlnodes
  end

  def xmltags
    @xmltags
  end
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
XML_MOTOR.new.xml_handler "<html> <head><title>top bar</title></head> <body> <div><b>a</b><span>axml-motor</span><span>work</span></div> <div><span>ruby</span></div>   <div><span>again</span></div>  </body> </html>", "span" if ARGV.length==0
puts "","+"*100
XML_MOTOR.new.xml_handler "<html> <head><title>top bar</title></head> <body> <div><b>a</b><span>axml-motor</span><span>work</span></div> <b><span>ruby</span></b> <div><span>again</span></div>  </body> </html>", "div.span" if ARGV.length==0
puts "","+"*100
XML_MOTOR.new.xml_handler "<html> <head><title>top bar</title></head> <body> <div><b>a</b><span>axml-motor</span><span>work</span></div> <b><span>ruby</span></b>  <div><span>again</span></div>  </body> </html>", "div" if ARGV.length==0
puts "","+"*100
XML_MOTOR.new.xml_handler "<html> <head><title>top bar</title></head> <body> <div><b>a</b><span>axml-motor</span><span>work</span></div> <b><span>ruby</span></b>  <div><span>again</span></div>   </body> </html>", "body" if ARGV.length==0
puts "","+"*100
XML_MOTOR.new.xml_handler "<html> <head><title>top bar</title></head> <body> <div><b>a</b><span>axml-motor</span><span>work</span></div> <b><span>ruby</span></b> <div><span>again</span></div>   </body> </html>", "div.span" if ARGV.length==0
puts "","+"*100
XML_MOTOR.new.xml_handler "<html> <head><title>top bar</title></head> <body> <div><b>a</b><span>axml-motor</span><span>work</span></div> <b><span>ruby</span></b> <div><span>again</span></div>   </body> </html>", "b" if ARGV.length==0
puts "","+"*100
