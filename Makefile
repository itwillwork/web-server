all:
	@ erlc httpd.erl;
	@ erlc format_http.erl;
	@ erlc server_worker.erl;

clean:
	@ rm -f httpd.beam;
	@ rm -f format_http.beam;
	@ rm -f server_worker.beam;
	@ rm -f erl_crash.dump;