for node in cluster01 cluster02 cluster03 cluster04 cluster06
do
  ssh $node ps -ef | grep -v grep | grep jfclere | grep java 2>&1 1> $$.tmp
  grep java $$.tmp > /dev/null
  if [ $? -eq 0 ]; then
    pid=`grep java $$.tmp | awk ' { print $2 } '`
    echo $pid
    ssh $node kill $pid
  fi
  rm $$.tmp
done
