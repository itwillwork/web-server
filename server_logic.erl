-module(server_logic).
-export([getResponce/0]).

getResponce() ->
	_codeStatus = 0,
	_date = 0,
	_contentType = 0, 
	_needBody = 0, 
	_src = 0,
	{_codeStatus, _date, _contentType, _needBody, _src}.