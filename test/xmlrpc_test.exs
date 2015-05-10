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

  test "network error is reported correctly" do
    assert {:error, :network_request, %HTTPoison.Error{}} = call("http://doesntexist.no", "", [])
  end

  test "wrong server method is reported correctly" do
    assert {:error, :remote_fault, "unsupported method called: math.NoExist"} = call("http://www.cookcomputing.com/xmlrpcsamples/math.rem", 
      "math.NoExist", [])
  end

  test "math method works correctly, returns integer" do
    assert {:ok, 4} = call("http://www.cookcomputing.com/xmlrpcsamples/math.rem", 
      "math.Add", [2, 2])
  end 

  test "state method works, returns string" do
    assert {:ok, "Alabama"} = call("http://www.cookcomputing.com/xmlrpcsamples/RPC2.ashx", 
      "examples.getStateName", [1])
  end
end
