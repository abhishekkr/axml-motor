#!/usr/bin/env ruby

require 'test/unit'
require '../xml-motor.rb'

class TestXMLJoiner < Test::Unit::TestCase
  def test_dejavu_attributes
    assert_equal XMLJoiner.dejavu_attributes(nil), nil
    assert_equal XMLJoiner.dejavu_attributes({"id"=>"'3'"}), " id='3'"
    assert_equal XMLJoiner.dejavu_attributes({"id"=>"'3'", "ic"=>"3"}), " id='3' ic=3"
  end

  def test_dejavu_attributes
    assert_equal XMLJoiner.dejavu_node(nil), nil
    assert_equal XMLJoiner.dejavu_node(["a", {"id"=>"\"3\""}]), ["<a id=\"3\">","</a>"]
    assert_equal XMLJoiner.dejavu_node(["a", nil]), ["<a>","</a>"]
  end
end

