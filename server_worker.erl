-module(server_worker).
-export([loop/1, getSrc/1]).

-define(INDEX, "index.html").

loop(_socket) ->
    case gen_tcp:recv(_socket, 0) of
        {ok, _data} ->
            {_method,  _url} = format_http:parse(_data),
            {_codeStatus, _src, _contentType, _date, _hasBody, _contentLength} = getResponce(_method, _url),
            _header = format_http:getHeader(_codeStatus, _contentType, _date, _contentLength),
            %io:fwrite("HEADER ~n ~p ~n~n", [list_to_binary(_header)]),
            %io:fwrite("SRC ~n ~p ~n~n", [list_to_binary(_src)]),
            gen_tcp:send(_socket, _header),
            case _hasBody of 
                true -> 
                    {ok, _} = file:sendfile(list_to_binary(_src), _socket);
                false ->
                    ok
            end,
            gen_tcp:close(_socket);
        {error, closed} ->
            ok
    end.

getResponce(_method, _url) ->
	case _method of
        <<"GET">> ->
            {_codeStatus, _src, _contentType, _date, _contentLength} = format_http:getInfo(_url),
            case _codeStatus of 
            	200 -> 
            		_hasBody = true;
        		_ -> 
        			_hasBody = false
			end;
        <<"HEAD">> ->
            {_codeStatus, _src, _contentType, _date, _contentLength} = format_http:getInfo(_url),
			_hasBody = false;
        _ ->
            {_codeStatus, _hasBody, _date, _contentType, _src, _contentLength} = {405, false, null, null, null, null}
    end,
	{_codeStatus, _src, _contentType, _date, _hasBody, _contentLength}.

getSrc(_url) ->
	[{_, ROOTDIR}] = ets:lookup(settings, "root"),
	_validUrl = "/" ++ getValidUrl(_url),
	case binary:last(_url) of
	    $/ ->
	       	_src = ROOTDIR ++ _validUrl ++ ?INDEX,
	       	_path = ROOTDIR ++ _validUrl;
	    _ ->
	        _src = ROOTDIR ++ _validUrl,
	        %это будет путь до файла несмотря на то что по идеи должен быть путь к папке
	        _path = _src
	end,
	case filelib:is_file(_src) of
	    true ->
	       	{200, _src};
	    false ->
	    	case filelib:is_dir(_path) of 
	    		true ->
	        		{403, _src};
        		false -> 
        			{404, _src}
    			end
	end.


getValidUrl(_url) ->
	_urlBits = string:tokens(binary_to_list(_url), "/"),
	_validBits = lists:delete("..", _urlBits),
	string:join(_validBits, "/").
