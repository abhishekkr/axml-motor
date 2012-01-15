#!/usr/bin/env ruby

require 'test/unit'
require '../parser.rb'

class TestXMLChopper < Test::Unit::TestCase
  def test_get_tag_attrib_value
    tag_data = "a> as you like it"
    tag_chop = XMLChopper.get_tag_attrib_value tag_data
    assert_equal tag_chop.size, 2
  end

  def test_get_attribute_hash
    attribzone = ["id='1'", 'ie="1"', 'count=10']
    attrib_key = ["id", "ie", "count"]
    attrib_val = ["\"1\"", "\"1\"", "10"]
    attribzone.each_index do |idx|
      attrib_chop = XMLChopper.get_attribute_hash attribzone[idx]
      assert_equal attrib_chop[attrib_key[idx]], attrib_val[idx]
    end
  end
end

