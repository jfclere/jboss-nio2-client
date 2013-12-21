#
# Don't forget to change httpd/ngnix/java located nearly at the end of the script.
for tc6 in 172.16.10.11 172.16.10.12 172.16.10.13 172.16.10.14 172.16.10.15
do
  JVMROUTE=`ssh ${tc6} uname -n | awk -F . '{ print $1 }'`
  ssh ${tc6} rm -rf /tmp/tc6
  ssh ${tc6} cp -r /home/jfclere/tc6 /tmp/tc6
  cat /home/jfclere/tc6/conf/server.xml | sed "s:NEO:$JVMROUTE:" > server.xml.tmp
  ssh ${tc6} /tmp/tc6/bin/shutdown.sh
  sleep 10
  scp server.xml.tmp ${USER}@${tc6}:/tmp/tc6/conf/server.xml
  ssh ${tc6} /tmp/tc6/bin/startup.sh
done
echo "Waiting for tomcats to start"
sleep 60

for tc6 in 172.16.10.11 172.16.10.12 172.16.10.13 172.16.10.14 172.16.10.15
do
  curl -v http://${tc6}:8080/jboss-nio2-servlet/ 2>&1 | grep JSESSIONID
  if [ $? -ne 0 ]; then
    echo "${tc6} not started can't test"
    exit 1
  fi
done

#for i in 5000 2500 2000 1000 833 666 500 416 384 357 333 294 263 250
#for i in 225 220 180 150 130 100
#for i in 5000 2000 1000 833 666 500 416 384 357 333 294 263 250 225 220 180 150 130 100 95 90 85 80 75 70 65 60 55 50
#for i in 5000 2000 1000 833 666 500 416 384 357 333 294 263 250 225 220 180 150 130 100 95 90 85 80 75 70 65
for i in 5000 2000 1000 833 666 500 416 384 357 333 294 263 250 225 220 180
do

  # messaging-17
  for node in messaging-23 messaging-20 messaging-19 messaging-18
  do
    echo $i $node
    ssh $node /tmp/PROXY/jboss-nio2-client/runone.sh $i &
  done

  ssh messaging-08 top -b 2>&1 1> $$.top &

  isdone=false
  while ! $isdone
  do
    sleep 1
    isdone=true
    for node in messaging-23 messaging-20 messaging-19 messaging-18
    do
      ssh $node ps -ef | grep -v grep | grep jfclere | grep java 2>&1 1> $$.tmp
      grep java $$.tmp > /dev/null
      if [ $? -eq 0 ]; then
        isdone=false
        break;
      fi
      rm $$.tmp
    done
  done

  #stop the top
  ssh messaging-08 ps -ef | grep -v grep | grep jfclere | grep top 2>&1 1> $$.tmp
  grep top $$.tmp > /dev/null
  if [ $? -eq 0 ]; then
    pid=`grep top $$.tmp | awk ' { print $2 } '`
    echo $pid
    ssh messaging-08 kill -15 $pid
  fi
  cp $$.top > $HOME/1500-$i-1000000-top-log.txt
  grep Cpu $$.top > $HOME/1500-$i-1000000-Cpu-log.txt

done
