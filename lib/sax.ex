defmodule Sax do
  import MultiDef

  @debug false

  # TODO: currently works well with individual values and structs, however cannot handle nested
  # structs, or lists etc. Currently we use a stack, and know to either remove the whole stack 
  # (one value) on /param, or the two last values on /struct. However, lists do not have a bounded
  # length, and anyway doesn't work for nested structs. 
  # Currently the nested fsm works well, probably needs to be coupled with a nested wait -
  # so that struct can just pop the last layer off, without worrying about other values, etc.

  def parse(str) do
    case :erlsom.parse_sax(str, [], &(respond_tr/2), []) do
      {:ok, {[x], _, _}, _} -> {:ok, x}
      {:ok, {x, _, _}, _}   -> {:ok, Enum.reverse(x)}
    end
  end

  def respond_tr(:startDocument, _) do 
    if @debug, do: IO.puts("\n\n#{String.duplicate("#", 50)}\n")
    {[], [], []}
  end

  def respond_tr(args, state) do
    if @debug, do: IO.inspect([args, state])
    respond(args, state)
  end

  def trace(trace, return) do
    IO.inspect([trace, return])
    return
  end

  mdef respond do 
    :startDocument,_                                   -> {:wait, []}
    {:startElement, [], elem, [], []}, state           -> startElem(elem, state)
    {:endElement, [], elem, []}, state                 -> endElem(elem, state)
    :endDocument, {_, result}                          -> result
    
    {:characters, str}, {acc, wait, [hd | tl] = state} -> {acc, [value(hd, str) | wait], state}
    _, state                                           -> state
  end

  def startElem(elem, {acc, wait, state}), do: {acc, wait, [elem|state]}

  def endElem(elem, {acc, wait, [elem | tl]}) do
    {acc, wait} = proc_end(elem, acc, wait)
    {acc, wait, tl}
  end

  mdef proc_end do
    'member', acc, [v, k | wait] -> {acc, [ Map.put(%{}, k, v) | wait ]}
    'struct', acc, wait          -> { [ map_merge(wait) | acc ],  [] }
    'param', acc, []          -> { acc,  [] }
    'param', acc, [wait]          -> { [ wait | acc ],  [] }
    _, acc, wait                 -> {acc, wait}
  end


  def map_merge(x), do: Enum.reduce(x, fn(x, acc) -> Map.merge(acc, x) end)

  mdef value do 
    'value', str         -> List.to_string(str)
    'string', str        -> List.to_string(str)
    'int', str           -> List.to_integer(str)
    'i4', str           -> List.to_integer(str)
    'float', str         -> List.to_float(str)
    'boolean', str       -> to_boolean(str)
    'name', str          -> List.to_string(str)
  end

  mdef to_boolean do
    '0' -> false
    '1' -> true
  end
end
