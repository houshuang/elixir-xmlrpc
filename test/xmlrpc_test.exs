defmodule XmlrpcTest do
  use ExUnit.Case, async: true
  import Xmlrpc

  test "simple method rendered correctly" do
    assert xmlrequest("login", []) == 
    "<?xml version=\"1.0\"?><methodCall><methodName>login</methodName><params></params></methodCall>"
  end
  
  test "various parameter types rendered correctly" do
    assert xmlrequest("login", ["name", true, 2, 2.0, {:base64, "Zm9vYmFy"}]) == 
    "<?xml version=\"1.0\"?><methodCall><methodName>login</methodName><params><param><value><string>name</string></value></param><param><value><boolean>1</boolean></value></param><param><value><int>2</int></value></param><param><value><double>2.0</double></value></param><param><value><base64>Zm9vYmFy</base64></value></param></params></methodCall>"
  end

  test "string escaping works" do
    assert xmlrequest("a", ["hi&", "this<is>", "&<"]) == 
    "<?xml version=\"1.0\"?><methodCall><methodName>a</methodName><params><param><value><string>hi&amp;</string></value></param><param><value><string>this&lt;is></string></value></param><param><value><string>&amp;&lt;</string></value></param></params></methodCall>"
  end

end
