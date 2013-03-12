for i in cluster01 cluster02 cluster03 cluster04 cluster06 cluster08 cluster09
do
  ssh $i /home/jfclere/PROXY/jboss-nio2-client/install.one.sh
done
ssh cluster09 /home/jfclere/PROXY/jboss-nio2-client/install.AS7.sh
