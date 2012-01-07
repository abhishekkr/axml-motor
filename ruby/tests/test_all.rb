#!/usr/bin/env ruby

Dir.glob("#{File.dirname(__FILE__)}/*").each do |_test|
  puts %x{ruby #{_test}} if _test.match(/test_xml_/)
end
