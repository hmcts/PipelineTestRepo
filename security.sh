#!/bin/bash
if [ $UID -eq 0 ]; then
  user=$1
  dir=$2
  shift 2 
  cd "$dir"
  exec su "zap" "$0" "$@"
fi
echo "This will be run from user $UID"
echo "${SECURITYCONTEXT}" > /zap/security.context
cd /zap
zap-x.sh -d -host 0.0.0.0 -port 1001 -config api.disablekey=true -config scanner.attackOnStart=true -config view.mode=attack -config connection.dnsTtlSuccessfulQueries=-1 -config api.addrs.addr.name=.* -config api.addrs.addr.regex=true /dev/null 2>&1 &
i=0
while !(curl -s http://0.0.0.0:1001) > /dev/null
do
     i=$(( (i+1) %4 ))
     sleep .1
done
 echo "ZAP has successfully started"
 zap-cli --zap-url http://0.0.0.0 -p 1001 status -t 120
 zap-cli --zap-url http://0.0.0.0 -p 1001 open-url "${TEST_URL}"
 zap-cli --zap-url http://0.0.0.0 -p 1001 context import /zap/security.context
 zap-cli --zap-url http://0.0.0.0 -p 1001 spider ${TEST_URL}
 zap-cli --zap-url http://0.0.0.0 -p 1001 active-scan --scanners all --recursive "${TEST_URL}"
 zap-cli --zap-url http://0.0.0.0 -p 1001 report -o activescan.html -f html
 # zap-cli --zap-url http://0.0.0.0 -p 1001 ajax-spider ${TEST_URL}
 # zap-cli --zap-url http://0.0.0.0 -p 1001 report -o ajaxspider.html -f html
 echo 'Changing owner from $(id -u):$(id -g) to $(id -u):$(id -u)'
 chown -R $(id -u):$(id -u) activescan.html
 cp *.html functional-output/
 zap-cli -p 1001 alerts -l Informational

