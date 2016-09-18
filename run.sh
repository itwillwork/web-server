#!/bin/bash

for i in "$@"
do
case $i in
    -c=*)
    CPUS="${i#*=}"
    ;;
    -r=*)
    RES="${i#*=}"
    ;;
esac
done

if [ -z "$RES" ]
then
    echo "require -r param, default -r='www'"
    RES="www"
    erl <<< "httpd:run(\"${RES}\")."
else
	if [ -z "$CPUS" ]
	then
	    erl <<< "httpd:run(\"${RES}\")."  
	else
	    erl <<< "httpd:run(\"${RES}\",\"${CPUS}\")." 
	fi
fi