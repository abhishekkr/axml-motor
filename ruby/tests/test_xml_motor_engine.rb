#!/usr/bin/env ruby

require 'test/unit'
require  File.expand_path(File.join(File.dirname(__FILE__), "../parser.rb"))

class TestXMLMotorEngine < Test::Unit::TestCase
  def setup
    @content = <<-xmldata
	<dummy>
	 <mmy> <y id=\"3\"\nclass="yada"> <z>300</z> </y> <y class="yada">5</y> </mmy>
	</dummy>
       xmldata
  end
  def teardown
    XMLMotorEngine.instance_variable_set "@xmlnodes", nil
    XMLMotorEngine.instance_variable_set "@xmltags", nil
  end

  def test__splitter_
    XMLMotorEngine._splitter_ @content
    xml_nodes = XMLMotorEngine.xmlnodes

    assert_equal xml_nodes[1][0], ["dummy", nil]
    assert_equal xml_nodes[2][0], ["mmy", nil]
    assert_equal xml_nodes[3][0], ["y", {"id"=>"\"3\"", "class"=>"\"yada\""}]
    assert_equal xml_nodes[4], [["z", nil], "300"]
    assert_equal xml_nodes[5][0], ["/z", nil]
    assert_equal xml_nodes[6][0], ["/y", nil]
    assert_equal xml_nodes[7], [["y", {"class"=>"\"yada\""}], "5"]
    assert_equal xml_nodes[8][0], ["/y", nil]
    assert_equal xml_nodes[9][0], ["/mmy", nil]
    assert_equal xml_nodes[10][0], ["/dummy", nil]
  end

  def test__indexify_
    XMLMotorEngine._splitter_ @content
    XMLMotorEngine._indexify_ XMLMotorEngine.xmlnodes
    xml_tags = XMLMotorEngine.xmltags

    assert_equal xml_tags["dummy"], {0 => [1,10]}
    assert_equal xml_tags["mmy"], {1 => [2,9]}
    assert_equal xml_tags["y"], {2 => [3,6,7,8]}
    assert_equal xml_tags["z"], {3 => [4,5]}
    assert_equal xml_tags["a"], nil 
  end

  def test__grab_my_node_
    XMLMotorEngine._splitter_ @content
    XMLMotorEngine._indexify_ XMLMotorEngine.xmlnodes

    assert_equal XMLMotorEngine._grab_my_node_([4,5]), ["300"]
    assert_equal XMLMotorEngine._grab_my_node_([4,5], "id=\"3\""), []
    assert_equal XMLMotorEngine._grab_my_node_([3,6,4,5], "id=\"3\""), [" <z>300</z> "]
    assert_equal XMLMotorEngine._grab_my_node_([3,6,7,8], ["class='yada'"]), [" <z>300</z> ", "5"]
    assert_equal XMLMotorEngine._grab_my_node_([3,6,7,8], ["id=\"3\"","class='yada'"]), [" <z>300</z> "]
    assert_equal XMLMotorEngine._grab_my_node_([3,6,7,8], ["class='yada'","id=\"3\""]), [" <z>300</z> "]
  end

  def test__get_attrib_key_val_
    XMLMotorEngine._splitter_ @content
    XMLMotorEngine._indexify_ XMLMotorEngine.xmlnodes

    assert_equal XMLMotorEngine._get_attrib_key_val_("id = 007"), ["id", "007"]
    assert_equal XMLMotorEngine._get_attrib_key_val_("james='bond'"), ["james", "\"bond\""]
    assert_equal XMLMotorEngine._get_attrib_key_val_("james=\"bond\""), ["james", "\"bond\""]
  end

  def test_xml_extracter
    XMLMotorEngine._splitter_ @content
    XMLMotorEngine._indexify_ XMLMotorEngine.xmlnodes

    assert_equal XMLMotorEngine.xml_extracter, nil
    assert_equal XMLMotorEngine.xml_extracter("z"), ["300"]
    assert_equal XMLMotorEngine.xml_extracter("y"), [" <z>300</z> ", "5"]
    assert_equal XMLMotorEngine.xml_extracter(nil,"id=\"3\""), [" <z>300</z> "]
    assert_equal XMLMotorEngine.xml_extracter("y","id=\"3\""), [" <z>300</z> "]
  end

  def test_xml_miner
    assert_equal XMLMotorEngine.xml_miner(nil), nil 
    assert_equal XMLMotorEngine.xml_miner(@content), nil
    assert_equal XMLMotorEngine.xml_miner(@content,"z"), ["300"]
    assert_equal XMLMotorEngine.xml_miner(@content, "y"), [" <z>300</z> ", "5"]
    assert_equal XMLMotorEngine.xml_miner(@content, nil,"id=\"3\""), [" <z>300</z> "]
    assert_equal XMLMotorEngine.xml_miner(@content, "y","id=\"3\""), [" <z>300</z> "]
  end

  def test_xmlnodes
    XMLMotorEngine.xmlnodes "change" 
    assert_equal XMLMotorEngine.xmlnodes, "change"
    XMLMotorEngine._splitter_ @content
    assert_not_equal XMLMotorEngine.xmlnodes, "change"
    XMLMotorEngine.xmlnodes "change"
    assert_equal XMLMotorEngine.xmlnodes, "change"
  end

  def test_xmltags
    XMLMotorEngine.instance_variable_set "@xmltags", nil
    XMLMotorEngine.xmltags "change" 
    assert_equal XMLMotorEngine.xmltags, "change"

    XMLMotorEngine._splitter_ @content
    XMLMotorEngine._indexify_ XMLMotorEngine.xmlnodes
    XMLMotorEngine.xmltags "change"
    assert_not_equal XMLMotorEngine.xmlnodes, "change"
  end

  def test_pre_processed_content
    XMLMotorEngine._splitter_ @content
    xnodes = XMLMotorEngine.xmlnodes
    XMLMotorEngine._indexify_ xnodes
    xtags = XMLMotorEngine.xmltags

    teardown; assert_equal XMLMotorEngine.pre_processed_content(nil), nil
    teardown; assert_equal XMLMotorEngine.pre_processed_content(""), nil 
    teardown; assert_equal XMLMotorEngine.pre_processed_content("",xtags), nil 
    teardown; assert_equal XMLMotorEngine.pre_processed_content(xnodes), nil 
    teardown; assert_equal XMLMotorEngine.pre_processed_content(xnodes,xtags), nil 
    teardown; assert_equal XMLMotorEngine.pre_processed_content(xnodes,nil,"z"), ["300"]
    teardown; assert_equal XMLMotorEngine.pre_processed_content(xnodes,nil,"y","id=\"3\""), [" <z>300</z> "]
    teardown; assert_equal XMLMotorEngine.pre_processed_content(xnodes,xtags,"z"), ["300"]
    teardown; assert_equal XMLMotorEngine.pre_processed_content(xnodes,xtags,"y","id=\"3\""), [" <z>300</z> "]
  end
end

