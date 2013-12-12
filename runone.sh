i=$1
(cd /tmp/PROXY/jboss-nio2-client
nohup bash /tmp/PROXY/jboss-nio2-client/run.sh http://172.16.10.8:8080/jboss-nio2-servlet/ 1500 $i 1000000 7500 &
)
# run.sh
# 1: url
# 2: number of client
# 3: day in ms.
# 4: total number of tests per client.
# 5: total number of clients.
