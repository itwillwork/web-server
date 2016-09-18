-module(server_logic).
-export([getResponce/2, getSrc/1]).

-define(INDEX, "index.html").
-define(DOCUMENT_ROOT, "/Users/edgarnurullin/dev/projects/web-server/www").

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


