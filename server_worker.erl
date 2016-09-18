-module(server_worker).
-export([loop/1, getSrc/1]).

-define(TURN_ON_LOG, true).
-define(INDEX, "index.html").
-define(DOCUMENT_ROOT, "/Users/edgarnurullin/dev/projects/web-server/www").

loop(_socket) ->
    case gen_tcp:recv(_socket, 0) of
        {ok, _data} ->
            {_method,  _url} = format_http:parse(_data),
            case ?TURN_ON_LOG of 
                true -> 
                    io:fwrite("~n~nmethod ~p ~nurl ~p ~n", [_method, _url]);
                false ->
                    ok
            end, 
            {_codeStatus, _src, _contentType, _date, _hasBody, _contentLength} = getResponce(_method, _url),
            case ?TURN_ON_LOG of 
                true -> 
                    io:fwrite(
                        "code status ~p ~ndate ~p ~ncontent-type ~p ~nneed body in responce  ~p ~ncontent-length ~p ~nsrc  ~p ~n", 
                        [_codeStatus, _date, _contentType, _hasBody, _contentLength, _src]
                    );
                false ->
                    ok
            end, 
            _header = format_http:getHeader(_codeStatus, _contentType, _date, _contentLength),
            case ?TURN_ON_LOG of 
                true -> 
                    io:fwrite("HEADER ~n ~p", [list_to_binary(_header)]);
                false ->
                    ok
            end, 
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
	case binary:last(_url) of
	    $/ ->
	       	_src = ?DOCUMENT_ROOT ++ binary_to_list(_url) ++ ?INDEX,
	       	_path = ?DOCUMENT_ROOT ++ binary_to_list(_url);
	    _ ->
	        _src = ?DOCUMENT_ROOT ++ _url,
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
