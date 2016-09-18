-module(httpd).
-export([run/2, run/1]).

run(ROOTDIR, NCPU) ->
    erlang:system_flag(schedulers_online, list_to_integer(NCPU, 10)), 
    run(ROOTDIR).

run(ROOTDIR) -> 
    ets:new(settings, [named_table, public, set, {keypos, 1}]),
    ets:insert(settings, {"root", ROOTDIR}),
    listen().

listen() ->
    case gen_tcp:listen(80, [binary, {packet, 0}, {active, false}]) of 
        {ok, _socket} -> 
            io:format("server run   (O_O ) ~n", []),
            accept_loop(_socket);
        {error, _message} ->
            io:format("server not run   (*-_-)~n", [])
    end.

accept_loop(_socket) ->
    {ok, _workerSocket} = gen_tcp:accept(_socket),
    _pid = spawn(server_worker, loop, [_workerSocket]),
    gen_tcp:controlling_process(_workerSocket, _pid),
    accept_loop(_socket).
   