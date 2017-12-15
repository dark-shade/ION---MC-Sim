#! /bin/sh

/etc/init.d/ssh start

echo "172.17.0.2 master" >> /etc/hosts

ssh -tt master << EOT

exit
EOT

cd /usr/local/

echo "starting hadoop" ###

hadoop/sbin/start-all.sh

echo "starting spark" ###

spark/sbin/start-all.sh

rm -r ./Output/*

$(./spark/bin/spark-submit --class com.hortonworks.example.Main --master yarn --deploy-mode cluster --jars ./spark/lib/datanucleus-api-jdo-3.2.6.jar,./spark/lib/datanucleus-core-3.2.10.jar,./spark/lib/datanucleus-rdbms-3.2.9.jar,spark/lib/spark-1.6.3-yarn-shuffle.jar --name monte-carlo ./MyMonte/monte-carlo-var-1.0-SNAPSHOT.jar ./Companies/* ./Finance/* ./Output)

$(./hadoop/bin/hdfs dfs -get ./Output/* /usr/local/Output/)

cat ./Output/*
