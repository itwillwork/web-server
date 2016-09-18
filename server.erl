-module(server).
-export([listen/0]).

listen() ->
    case gen_tcp:listen(3000, [binary, {packet, 0}, {active, false}]) of 
        {ok, _socket} -> 
            io:format("server run   ヽ(ﾟ〇ﾟ)ﾉ~n", []),
            accept_loop(_socket);
        {error, _message} ->
            io:format("server not run   (*-_-)~n", [])
    end.

accept_loop(_socket) ->
    {ok, _workerSocket} = gen_tcp:accept(_socket),
    _pid = spawn(server_worker, loop, [_workerSocket]),
    gen_tcp:controlling_process(_workerSocket, _pid),
    accept_loop(_socket).
