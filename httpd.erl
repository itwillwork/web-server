-module(httpd).
-export([run/2, run/1, listener/0]).

run(ROOTDIR, NCPU) ->
    erlang:system_flag(schedulers_online, list_to_integer(NCPU, 10)), 
    run(ROOTDIR).

run(ROOTDIR) -> 
    ets:new(settings, [named_table, public, set, {keypos, 1}]),
    ets:insert(settings, {"root", ROOTDIR}),
    listener().

listener() ->
    case gen_tcp:listen(80, [binary, {backlog, 128}, {active, false}, {buffer, 65536}, {keepalive, true}, {send_timeout, 0}, {reuseaddr, true}]) of 
        {ok, _listenSocket} -> 
            io:format("server run   (O_O ) ~n", []),
            accept(_listenSocket);
        _ ->
            io:format("server not run   (*-_-)~n", [])
    end.

accept(_listenSocket) ->
    case gen_tcp:accept(_listenSocket) of
        {ok, _socket} -> 
            _pid = erlang:spawn(server_worker, loop, [_socket]), 
            gen_tcp:controlling_process(_socket, _pid),
            accept(_listenSocket);
        {error, closed} -> 
            ok
    end.
