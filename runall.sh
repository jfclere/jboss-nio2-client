for i in 5000 2500 2000 1000 833 666 500 416 384 357 333 294 263 250
do
  # stop AS7
  ssh cluster09 ps -ef | grep -v grep | grep jfclere | grep java 2>&1 1> $$.tmp
  grep java $$.tmp > /dev/null
  if [ $? -eq 0 ]; then
    pid=`grep java $$.tmp | awk ' { print $2 } '`
    echo $pid
    ssh cluster09 kill -9 $pid
    sleep 10
  fi
  # start AS7
  ssh cluster09 /tmp/PROXY/jboss-nio2-client/runAS7.sh &

  sleep 10
  curl -v http://172.17.40.254:8080/jboss-nio2-servlet/TestServlet
  if [ $? -ne 0 ]; then
    echo "AS broken?..."
    exit 1
  fi
  
  for node in cluster01 cluster02 cluster03 cluster04 cluster06
  do
    echo $i $node
    ssh $node /tmp/PROXY/jboss-nio2-client/runone.sh $i &
  done

  isdone=false
  while ! $isdone
  do
    isdone=true
    for node in cluster01 cluster02 cluster03 cluster04 cluster06
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
done
