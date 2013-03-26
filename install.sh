for i in cluster01 cluster02 cluster03 cluster04 cluster07 cluster08
do
  ssh $i /home/jfclere/PROXY/jboss-nio2-client/install.one.sh
done
ssh cluster08 /home/jfclere/PROXY/jboss-nio2-client/install.AS7.sh
