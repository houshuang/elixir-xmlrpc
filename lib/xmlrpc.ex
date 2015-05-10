defmodule Xmlrpc do

  import SweetXml

  def call(url, method, params) do
    case HTTPoison.post url, xmlrequest(method, params) do
      {:error, error} -> {:error, :http, error}
      {:ok, %HTTPoison.Response{body: body}} -> parse_response(body)
    end
  end
  
  def parse_response(body) do
    if xpath(body, ~x"//methodResponse/fault") do
      {:error, :remote_fault, xpath(body, ~x"//value/text()")}
    else
      {:ok, xpath(body, ~x"//value/text()")}
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
