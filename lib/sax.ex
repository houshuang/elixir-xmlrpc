defmodule Sax do
  import MultiDef

  def parse(str) do
    case :erlsom.parse_sax(str, [], &(respond_tr/2), []) do
      {:ok, [x], []} -> {:ok, x}
      {:ok, list, []} -> {:ok, Enum.reverse(list)}
    end
  end

  def respond_tr(:startDocument, _) do 
    IO.puts("\n\n#{String.duplicate("#", 50)}\n")
    {:wait, []}
  end

  def respond_tr(args, state) do
    IO.inspect([args, state])
    respond(args, state)
  end

  # TODO: right now handles structs as individual params OK, but cannot merge structs with multiple members, 
  # see how the state transition happens, maybe explicitly leave struct, or use merge...
  # also need to add lists - hopefully can be done without copying all struct members again

  mdef respond do 
    :startDocument,_                          -> {:wait, []}
    {:startElement, [], elem, [], []}, state  -> startElem(elem, state)
    :endDocument, {_, result}                 -> result
    
    {:characters, str}, {:value, acc}         -> {:wait, [List.to_string(str) | acc] }
    {:characters, str}, {:string, acc}        -> {:wait, [List.to_string(str) | acc] }
    {:characters, str}, {:int, acc}           -> {:wait, [List.to_integer(str) | acc] }
    {:characters, str}, {:float, acc}         -> {:wait, [List.to_float(str) | acc] }
    {:characters, str}, {:boolean, acc}       -> {:wait, [to_boolean(str) | acc] }
    {:characters, str}, {:name, acc}          -> {:struct_val, List.to_string(str), acc }

    # for struct values
    {:characters, str}, {:value, name, acc}   -> {:wait, [Map.put(%{}, name, List.to_string(str)) | acc] }
    {:characters, str}, {:string, name, acc}  -> {:wait, [Map.put(%{}, name, List.to_string(str)) | acc] }
    {:characters, str}, {:int, name, acc}     -> {:wait, [Map.put(%{}, name, List.to_integer(str)) | acc] }
    {:characters, str}, {:float, name, acc}   -> {:wait, [Map.put(%{}, name, List.to_float(str)) | acc] }
    {:characters, str}, {:boolean, name, acc} -> {:wait, [Map.put(%{}, name, to_boolean(str)) | acc] }

    x, state                                  -> state
  end

  mdef startElem do
    'param',  {:wait, acc}             -> {:param, acc}
    'struct', {_, acc}                 -> {:struct, acc}
    'member', {:struct, acc}           -> {:member, acc}
    'name', {:member, acc}             -> {:name, acc}

    'value',  {:param, acc}            -> {:value, acc}
    'value',  {:struct_val, acc}       -> {:value, acc}
    'string', {:value, acc}            -> {:string, acc}
    'int',    {:value, acc}            -> {:int, acc}
    'i4',    {:value, acc}             -> {:int, acc}
    'boolean',    {:value, acc}        -> {:boolean, acc}
    'float',    {:value, acc}          -> {:float, acc}

    'value',  {:param, name, acc}      -> {:value, name, acc}
    'value',  {:struct_val, name, acc} -> {:value, name, acc}
    'string', {:value, name, acc}      -> {:string, name, acc}
    'int',    {:value, name, acc}      -> {:int, name, acc}
    'i4',    {:value, name, acc}       -> {:int, name, acc}
    'boolean',    {:value, name, acc}  -> {:boolean, name, acc}
    'float',    {:value, name, acc}    -> {:float, name, acc}
    _, state                           -> state
  end

  mdef to_boolean do
    '0' -> false
    '1' -> true
  end
end
