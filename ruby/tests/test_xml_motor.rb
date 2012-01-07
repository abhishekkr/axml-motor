#!/usr/bin/env ruby

require 'test/unit'
require '../parser.rb'

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
end

