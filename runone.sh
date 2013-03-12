i=$1
(cd /tmp/PROXY/jboss-nio2-client
nohup bash /tmp/PROXY/jboss-nio2-client/run.sh http://172.17.40.254:8080/jboss-nio2-servlet/TestServlet 1000 $i 1000000 5000 &
)
