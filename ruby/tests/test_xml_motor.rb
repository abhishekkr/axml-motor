#!/usr/bin/env ruby

require 'test/unit'
require '../xml-motor.rb'

class TestXMLMotor < Test::Unit::TestCase
  def setup
    @fyle = File.expand_path File.join(File.dirname(__FILE__), "dummy.xml")
    @my_tag = 'mmy.y'
    @my_attrib = "id='10'"
  end
  def teardown; end

  def test_get_node_from_file
    xnodes = XMLMotor.get_node_from_file(@fyle, @my_tag)
    assert_equal xnodes.size, 3
    xnodes = XMLMotor.get_node_from_file(@fyle, @my_tag, @my_attrib)
    assert_equal xnodes.size, 1
  end

  def test_get_node_from_content
    fo = File.open(@fyle, "r")
    content = fo.read
    xnodes = XMLMotor.get_node_from_content(content, @my_tag)
    assert_equal xnodes.size, 3
    xnodes = XMLMotor.get_node_from_content(content, @my_tag, @my_attrib)
    assert_equal xnodes.size, 1
    fo.close
  end

  def test_splitter
    content = "<a>1<b>2</b>3<c>4</c>5</a>"
    xnodes = XMLMotor.splitter content
    assert_equal xnodes[0], ""
    assert_equal xnodes[1], [["a", nil], "1"]
    assert_equal xnodes[2], [["b", nil], "2"]
    assert_equal xnodes[3], [["/b", nil], "3"]
    assert_equal xnodes[4], [["c", nil], "4"]
    assert_equal xnodes[5], [["/c", nil], "5"]
    assert_equal xnodes[6], [["/a", nil], ""]
  end

  def test_indexify
    content = "<a>1<b>2</b>3<c>4</c>5</a>"
    xnodes  = XMLMotor.splitter content
    xtags   = XMLMotor.indexify xnodes
    assert_equal xtags["a"], {0=>[1, 6]} 
    assert_equal xtags["b"], {1=>[2, 3]}
    assert_equal xtags["c"], {1=>[4, 5]}
  end

  def test_xmldata
    content = "<a>1<b>2</b>3<c>4</c>5</a>"
    xnodes  = XMLMotor.splitter content
    xtags   = XMLMotor.indexify xnodes
    assert_equal XMLMotor.xmldata(xnodes, xtags, "a"), ["1<b>2</b>3<c>4</c>5"]
    assert_equal XMLMotor.xmldata(xnodes, xtags, "a.b"), ["2"]
    assert_equal XMLMotor.xmldata(xnodes, xtags, "a.b", nil, true), ["<b>2</b>"]
  end
end

