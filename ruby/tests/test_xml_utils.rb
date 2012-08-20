#!/usr/bin/env ruby

require 'test/unit'
require '../xml-motor.rb'

class TestXMLUtils < Test::Unit::TestCase
  def test_dbqot_string
    assert_equal XMLUtils.dbqot_string(nil), nil
    assert_equal XMLUtils.dbqot_string(""), ""
    assert_equal XMLUtils.dbqot_string("\'\'"), "\"\""
    assert_equal XMLUtils.dbqot_string("\"\""), "\"\""
    assert_equal XMLUtils.dbqot_string("\'any var\'"), "\"any var\""
    assert_equal XMLUtils.dbqot_string("\'any\"var\'"), "\"any\\\"var\""
    assert_equal XMLUtils.dbqot_string("\"any'var\""), "\"any'var\""
  end
end

