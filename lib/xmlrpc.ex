defmodule Xmlrpc do

  import SweetXml

  def call(url, method, params) do
    case HTTPoison.post url, xmlrequest(method, params) do
      {:error, error} -> {:error, :network_request, error}
      # {:ok, %HTTPoison.Response{body: body}} -> parse_response(body)
      {:ok, %HTTPoison.Response{body: body}} -> :xmlrpc_decode.payload(String.to_char_list(body))
    end
  end
  
  def parse_response(body) do
    IO.inspect(body)
    if xpath(body, ~x"//methodResponse/fault") do
      {:error, :remote_fault, List.to_string(xpath(body, ~x"//string/text()"))}
    else
      {:ok, parse_success(body)}
    end
  end

  def parse_success(body) do
    xp = (body |> xpath(~x"//params/param/value/*"))
    if xp do
      case elem(xp, 1) do
        :i4 -> List.to_integer(body |> xpath(~x"//params/param/value/i4/text()"))
        :string -> List.to_string(body |> xpath(~x"//params/param/value/string/text()"))
      end
    else
      List.to_string(body |> xpath(~x"//params/param/value/text()"))
    end

  end

  def xmlrequest(method, params) do
    ["<?xml version=\"1.0\"?><methodCall><methodName>", method, "</methodName><params>", 
      wrap_params(params), "</params></methodCall>"] |> IO.iodata_to_binary
  end

  defp wrap_params(params) do 
    params |> Enum.map( 
      fn(x) -> ["<param><value>", wrap_param(x), "</value></param>"] end)
  end

  defp wrap_param(param) do 
    case wrapper(param) do
      {str, val} -> ["<", str, ">", val, "</", str, ">"]
      str -> ["<", str, ">", param, "</", str, ">"]
    end
  end

  defp wrapper(param) when is_binary(param), do: { "string", escape param }
  defp wrapper({:base64, payload}) when is_binary(payload), do: { "base64", payload }
  defp wrapper(true),  do: { "boolean", "1" }
  defp wrapper(false), do: { "boolean", "0" }
  defp wrapper(param) when is_integer(param), do: { "int", Integer.to_string(param) }
  defp wrapper(param) when is_float(param), do: { "double", Float.to_string(param,
    [compact: true, decimals: 10]) }

  defp escape(str), do: str |> String.replace("&", "&amp;") |> String.replace("<", "&lt;") 
end
