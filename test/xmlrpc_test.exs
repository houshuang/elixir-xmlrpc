Code.require_file "../test_helper.exs", __ENV__.file

defmodule XmlrpcTest do
  use Amrita.Sweet

  def req(str) do
    str = "<?xml version=\"1.0\"?><methodResponse><params>" <> str <> "</params></methodResponse>"
    Sax.parse(str)
  end

  # facts "individual values" do
  #   fact "string", do: req("<param><value><string>hi</string></value></param>") |> {:ok, "hi"}
  #   fact "string wrong", do: req("<param><value><string>ho</string></value></param>") |> ! {:ok, "hi"}
  #   fact "int", do: req("<param><value><int>4</int></value></param>") |> {:ok, 4}
  #   fact "float", do: req("<param><value><float>4.0</float></value></param>") |> {:ok, 4.0}
  #   fact "boolean true", do: req("<param><value><boolean>1</boolean></value></param>") |> {:ok, true}
  #   fact "boolean false", do: req("<param><value><boolean>0</boolean></value></param>") |> {:ok, false}
  #   fact "naked value", do: req("<param><value>hi</value></param>") |> {:ok, "hi"}
  # end

  # facts "several values" do
  #   fact "string and int", do: req("<param><value><string>hi</string></value></param><param><value><int>2</int></value></param>") |> {:ok, ["hi", 2]}
  #   fact "three ints", do: req("<param><value><int>2</int></value></param><param><value><int>3</int></value></param><param><value><int>4</int></value></param>") |> {:ok, [2, 3, 4]}
  # end

  facts "structs" do
    fact "simple struct", do: req("<param><struct><member><name>task</name><value><string>clean</string></value></member></struct></param>") |> {:ok, %{"task" => "clean"}}

    fact "two structs", do: req("<param><struct><member><name>task</name><value><string>clean</string></value></member></struct></param><param><struct><member><name>age</name><value><int>21</int></value></member></struct></param>") |> {:ok, [%{"task" => "clean"}, %{"age" => 21}]}

    fact "struct with two members", do: req("<param><struct><member><name>task</name><value><string>clean</string></value></member><member><name>age</name><value><int>21</int></value></member></struct></param>") |> {:ok, [%{"task" => "clean", "age" => 21}]}
  end
end





  # test "simple method rendered correctly" do
  #   assert xmlrequest("login", []) == 
  #   "<?xml version=\"1.0\"?><methodCall><methodName>login</methodName><params></params></methodCall>"
  # end
  
  # test "various parameter types rendered correctly" do
  #   assert xmlrequest("login", ["name", true, 2, 2.0, {:base64, "Zm9vYmFy"}]) == 
  #   "<?xml version=\"1.0\"?><methodCall><methodName>login</methodName><params><param><value><string>name</string></value></param><param><value><boolean>1</boolean></value></param><param><value><int>2</int></value></param><param><value><double>2.0</double></value></param><param><value><base64>Zm9vYmFy</base64></value></param></params></methodCall>"
  # end

  # test "string escaping works" do
  #   assert xmlrequest("a", ["hi&", "this<is>", "&<"]) == 
  #   "<?xml version=\"1.0\"?><methodCall><methodName>a</methodName><params><param><value><string>hi&amp;</string></value></param><param><value><string>this&lt;is></string></value></param><param><value><string>&amp;&lt;</string></value></param></params></methodCall>"
  # end

  # test "network error is reported correctly" do
  #   assert {:error, :network_request, %HTTPoison.Error{}} = call("http://doesntexist.no", "", [])
  # end

  # test "wrong server method is reported correctly" do
  #   assert {:error, :remote_fault, "unsupported method called: math.NoExist"} = call("http://www.cookcomputing.com/xmlrpcsamples/math.rem", 
  #     "math.NoExist", [])
  # end

  # test "math method works correctly, returns integer" do
  #   assert {:ok, 4} = call("http://www.cookcomputing.com/xmlrpcsamples/math.rem", 
  #     "math.Add", [2, 2])
  # end 

  # test "state method works, returns string" do
  #   assert {:ok, "Alabama"} = call("http://www.cookcomputing.com/xmlrpcsamples/RPC2.ashx", 
  #     "examples.getStateName", [1])
  # end

