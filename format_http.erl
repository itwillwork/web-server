-module(format_http).
-export([parse/1, getHeader/4, getInfo/1]).

parse(_url) ->
	[_method, _path| _] = binary:split(_url, [<<" ">>, <<"?">>, <<"\r\n">>], [global]),
	{_method, _path}.

getHeader(_codeStatus, _contentType, _date, _contentLength) -> 
	case _codeStatus of
        200 ->    
        	_extra = "Content-Type: " ++ _contentType ++ "\r\nContent-Length: " ++ _contentLength ++ "\r\nDate: " ++ _date ++ "\r\n";
        404 ->
        	_extra = "Date: " ++ _date ++ "\r\n";
        403 ->
        	_extra = "";
        405 ->
        	_extra = ""
    end,
	"HTTP/1.1 "++ integer_to_list(_codeStatus) ++" OK\r\nServer: noname\r\nX-Powered-By: Erlang\r\n" ++ _extra ++ "Connection: close\r\n\r\n".

getInfo(_url) -> 
	{_codeStatus, _src} = server_worker:getSrc(_url),
	case _codeStatus of
		403 -> 
			{_contentType, _date, _contentLength} = {null, null, null};
		404 ->
			{_contentType, _date, _contentLength} = {null, getDate(), null}; 
		200 ->
			{_contentType, _date, _contentLength} = {getContentType(_src), getDate(), getContentLength(_src)}
		end,
	{_codeStatus, _src, _contentType, _date, _contentLength}.

getDate() -> 
	{Date, {Hours, Minutes, Seconds}} = calendar:universal_time(),
    DayOfWeek = element(calendar:day_of_the_week(Date), {"Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"}),
    {Year, MonthNumber, Day} = Date,
    Month = element(MonthNumber, {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}),
    io_lib:format("~s, ~B ~s ~B ~2..0B:~2..0B:~2..0B GMT", [DayOfWeek, Day, Month, Year, Hours, Minutes, Seconds]).

getContentType(_src) ->
    case lists:last(string:tokens(_src, ".")) of
        "js" ->
            "application/javascript";
        "html" ->
            "text/html";
        "htm" -> 
        	"text/html";
        "css" ->
            "text/css";
        "jpg" ->
        	"image/jpeg"; 
        "jpeg" ->
            "image/jpeg";
        "png" ->
            "image/png";
        "gif" ->
            "image/gif";
        "swf" ->
            "application/x-shockwave-flash";
        _ ->
            "application/octet-stream"
    end.

getContentLength(_src)->
    {_, _fullFileInfo} = file:read_file_info(_src),
  	integer_to_list(element(2, _fullFileInfo)).
