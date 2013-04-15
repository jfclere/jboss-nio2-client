#for i in 5000 2500 2000 1000 833 666 500 416 384 357 333 294 263 250
#for i in 225 220 180 150 130 100
for i in 5000 2000 1000 833 666 500 416 384 357 333 294 263 250 225 220 180 150 130 100 95 90 85 80 75 70 65 60 55 50
do
  # stop AS7
  ssh cluster08 ps -ef | grep -v grep | grep jfclere | grep java 2>&1 1> $$.tmp
  grep java $$.tmp > /dev/null
  if [ $? -eq 0 ]; then
    pid=`grep java $$.tmp | awk ' { print $2 } '`
    echo $pid
    ssh cluster08 kill -9 $pid
    sleep 10
  fi
  # start AS7
  ssh cluster08 /tmp/PROXY/jboss-nio2-client/runAS7.sh &
  sleep 10

  #curl -v http://172.17.40.254:8080/jboss-nio2-servlet/TestServlet
  curl -v http://172.17.7.254:8080/jboss-nio2-servlet/TestServlet
  if [ $? -ne 0 ]; then
    echo "AS broken?..."
    exit 1
  fi
  
  # find the java and top it.
  ssh cluster08 ps -ef | grep -v grep | grep jfclere | grep java 2>&1 1> $$.tmp
  grep java $$.tmp > /dev/null
  if [ $? -eq 0 ]; then
    pid=`grep java $$.tmp | awk ' { print $2 } '`
    echo $pid
  fi
  ssh cluster08 top -b -p $pid 2>&1 1> $$.top &
  
  for node in cluster01 cluster02 cluster03 cluster04 cluster07
  do
    echo $i $node
    ssh $node /tmp/PROXY/jboss-nio2-client/runone.sh $i &
  done

  isdone=false
  while ! $isdone
  do
    isdone=true
    for node in cluster01 cluster02 cluster03 cluster04 cluster07
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
  ssh cluster08 ps -ef | grep -v grep | grep jfclere | grep top 2>&1 1> $$.tmp
  grep top $$.tmp > /dev/null
  if [ $? -eq 0 ]; then
    pid=`grep top $$.tmp | awk ' { print $2 } '`
    echo $pid
    ssh cluster08 kill -15 $pid
  fi
  grep java $$.top > $HOME/1000-$i-1000000-top-log.txt
  grep Cpu $$.top > $HOME/1000-$i-1000000-Cpu-log.txt

done
