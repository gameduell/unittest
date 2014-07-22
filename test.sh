
cd test
haxelib run lime test html5 &
cd ..

python test_result_listener.py 8181
WEBSERVER_PROCESS_ID=`ps aux | grep http-server | grep -v grep | awk '{print $2}'`
kill $WEBSERVER_PROCESS_ID




