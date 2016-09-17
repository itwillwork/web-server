-module(format_http).
-export([parse/1]).

parse(_url) ->
	[_method, _path| _] = binary:split(_url, [<<" ">>, <<"?">>, <<"\r\n">>], [global]),
	{_method, _path}.

format() -> 
	<<"dfdf">>.
