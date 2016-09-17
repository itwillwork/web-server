-module(server).
-export([listen/0]).

-define(TURN_ON_LOG, true).

listen() ->
    {ok, _socket} = gen_tcp:listen(80, [binary, {packet, 0}, {active, false}]),
    accept(_socket).

accept(_socket) ->
    {ok, _worker} = gen_tcp:accept(_socket),
    spawn(fun() -> loop(_worker) end),
    accept(_socket).

loop(_socket) ->
    case gen_tcp:recv(_socket, 0) of
        {ok, _data} ->
            % получили путь и протокол
                % method
                % url
            {_method,  _url} = format_http:parse(_data),
            case ?TURN_ON_LOG of 
                true -> 
                    io:fwrite("method ~p ~nurl ~p ~n", [_method, _url]);
                false ->
                    ok
            end, 
            % логика из параметров ответ в фомате параметров
                % code_sratus
                % date
                % contentType
                % needBody
                % src
            {_codeStatus, _date, _contentType, _needBody, _src} = server_logic:getResponce(),
            % сформировали ответ из объекта
                % header
            % отправили 
            gen_tcp:send(_socket, _data),
            loop(_socket);
        {error, closed} ->
            ok
    end.