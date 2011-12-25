#!/usr/bin/env ruby

require 'test/unit'
require '../parser.rb'

class TestXMLJoiner < Test::Unit::TestCase
  def test_dejavu_attributes
    assert_equal XMLJoiner.dejavu_attributes(nil), nil
    assert_equal XMLJoiner.dejavu_attributes({"id"=>"'3'"}), " id='3'"
    assert_equal XMLJoiner.dejavu_attributes({"id"=>"'3'", "ic"=>"3"}), " id='3' ic=3"
  end
end

