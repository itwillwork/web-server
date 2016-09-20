-module(server_worker).
-export([loop/1, getSrc/1]).

-define(INDEX, "index.html").
-define(SLASH, "/").
-define(Timeout, 5000).

loop(_socket) ->
    case gen_tcp:recv(_socket, 0, ?Timeout) of
        {ok, _data} ->
            {_method,  _url} = format_http:parse(_data),
            case isNotValidUrl(_url) of 
            	false ->
            		{_codeStatus, _src, _contentType, _date, _hasBody, _contentLength} = getResponce(_method, _url);
        		true ->
        			{_codeStatus, _src, _contentType, _date, _hasBody, _contentLength} = {403, null, null, null, false, null}
			end,
            _header = format_http:getHeader(_codeStatus, _contentType, _date, _contentLength),
            gen_tcp:send(_socket, _header),
            case _hasBody of 
                true -> 
                    file:sendfile(list_to_binary(_src), _socket);
                false ->
                    ok
            end,
            gen_tcp:close(_socket);
        _ ->
            gen_tcp:close(_socket),
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
	_baseUrl = ROOTDIR ++ ?SLASH ++ http_uri:decode(binary_to_list(_url)),
	case binary:last(_url) of
	    $/ ->
	       	_src = _baseUrl ++ ?SLASH ++ ?INDEX,
	       	_path = _baseUrl;
	    _ ->
	        _src = _baseUrl,
	        %это будет путь до файла несмотря на то что по идеи должен быть путь к папке
	        _path = _baseUrl
	end,
	_validSrc = getValidUrl(_src),
	_validSrcPath = getValidUrl(_path),
	case filelib:is_file(_validSrc) of
	    true ->
	       	{200, _validSrc};
	    false ->
	    	case filelib:is_dir(_validSrcPath) of 
	    		true ->
	        		{403, _validSrc};
        		false -> 
        			{404, _validSrc}
    			end
	end.

getValidUrl(_url) ->
	_urlBits = string:tokens(_url, "/"),
	string:join(_urlBits, "/").

isNotValidUrl(_url) ->
	_urlBits = string:tokens(binary_to_list(_url), "/"),
	lists:member("..", _urlBits).
