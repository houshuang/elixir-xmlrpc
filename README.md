Xmlrpc
======

This is a first attempt at a very minimalistic XML-RPC client in Elixir, using HTTPoison for the transport layer. I needed a client for my own project to talk to a Confluence wiki, and could not get any of the existing Erlang solutions to work.

Right now it seems to work quite well for my limited cases. By relying on HTTPoison, HTTPS works transparently, and the code base is extremely small. 

# Caveats/todos

- Does not implement all the data types, like dates, structs and lists
- The parsing of return values is a bit sketchy - I am not very happy about the code (I'm a complete amateur at XPath), and it might not be very robust
- I'd love more test-cases, either public facing servers that we can add, or capturing the XML output and feeding it straight to the parser
- Segment tests into ones that require internet and once that don't with tags, and only run ones that don't by default
- Look into mocking of external services
- Better documentation
- 
