#!/usr/bin/env ruby

Dir.glob("#{File.dirname(__FILE__)}/*rb").each do |_test|
  next if _test.match(/test_all.rb$/)
  puts _test
  puts %x{ruby #{_test} | grep tests} if _test.match(/test_xml_/)
end
