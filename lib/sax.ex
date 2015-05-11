defmodule Sax do
  import MultiDef

  def parse(str) do
    case :erlsom.parse_sax(str, [], &(respond/2), []) do
      {:ok, [x], []} -> {:ok, x}
      {:ok, list, []} -> {:ok, Enum.reverse(list)}
    end
  end

  def trace(args, state) do
    IO.inspect(args)
    state
  end

  # TODO: right now handles structs as individual params OK, but cannot merge structs with multiple members, 
  # see how the state transition happens, maybe explicitly leave struct, or use merge...
  # also need to add lists - hopefully can be done without copying all struct members again

  mdef respond do 
    :startDocument,_                          -> {:wait, []}
    {:startElement, [], elem, [], []}, state  -> trace(elem, startElem(elem, state))
    :endDocument, {_, result}                 -> result
    
    {:characters, str}, {:value, acc}         -> trace(str,{:wait, [List.to_string(str) | acc] })
    {:characters, str}, {:string, acc}        -> trace(str, {:wait, [List.to_string(str) | acc] })
    {:characters, str}, {:int, acc}           -> trace(str, {:wait, [List.to_integer(str) | acc] })
    {:characters, str}, {:float, acc}         -> trace(str, {:wait, [List.to_float(str) | acc] })
    {:characters, str}, {:boolean, acc}       -> trace(str, {:wait, [to_boolean(str) | acc] })
    {:characters, str}, {:name, acc}          -> trace(str, {:struct_val, List.to_string(str), acc })

    # for struct values
    {:characters, str}, {:value, name, acc}   -> {:wait, [Map.put(%{}, name, List.to_string(str)) | acc] }
    {:characters, str}, {:string, name, acc}  -> {:wait, [Map.put(%{}, name, List.to_string(str)) | acc] }
    {:characters, str}, {:int, name, acc}     -> {:wait, [Map.put(%{}, name, List.to_integer(str)) | acc] }
    {:characters, str}, {:float, name, acc}   -> {:wait, [Map.put(%{}, name, List.to_float(str)) | acc] }
    {:characters, str}, {:boolean, name, acc} -> {:wait, [Map.put(%{}, name, to_boolean(str)) | acc] }

    x, state                                  -> trace({:respond_missing, x, state}, state)
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
    str, state = {fsm, _}              -> trace({str,fsm}, state)
  end

  mdef to_boolean do
    '0' -> false
    '1' -> true
  end
end
