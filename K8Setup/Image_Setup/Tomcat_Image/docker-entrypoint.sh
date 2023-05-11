#!/bin/bash

#echo "Importing to cacerts"
#keytool -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit -noprompt -trustcacerts -importcert -alias ntdevcert -file /certs/tls.crt


echo "Calling utility to generate config file"
java -jar ./nFlowsUtility.jar TOMCAT -app_name $APP_NAME -url $APP_URL -path $WAR_PATH -port $PORT
java -jar ./nFlowsUtility.jar NEO4JDB -host $NEO4J_HOST -port $NEO4J_PORT -user $NEO4J_USER -pass $NEO4J_PWD
java -jar ./nFlowsUtility.jar MONGODB -host $MONGODB_HOST -port $MONGODB_PORT -db $MONGODB_NAME -user $MONGODB_USER -pass $MONGODB_PWD


echo "Calling utility to encrypt URLs"
DATAENGINE_URL_ENC=`java -jar ./nFlowsUtility.jar ENCRYPT $DATAENGINE_URL`
RULEENGINE_URL_ENC=`java -jar ./nFlowsUtility.jar ENCRYPT $RULEENGINE_URL`
EXPORTAPIENGINE_URL_ENC=`java -jar ./nFlowsUtility.jar ENCRYPT $EXPORTAPIENGINE_URL`
NEO4J_PROTOCOL_ENC=`java -jar ./nFlowsUtility.jar ENCRYPT $NEO4J_PROTOCOL`
HIGHCHARTS_URL_ENC=`java -jar ./nFlowsUtility.jar ENCRYPT $HIGHCHARTS_URL`

echo "Calling utility to encrypt neo4j db name - to be removed when its included part of NOE4JDB group"
NEO4J_DBNAME_ENC=`java -jar ./nFlowsUtility.jar ENCRYPT $NEO4J_DBNAME`

echo "Adding extra config"
cat << EOF >> AppConfig.Properties
NEO4J_DBNAME=$NEO4J_DBNAME_ENC
NEO4J_PROTOCOL=$NEO4J_PROTOCOL_ENC
DATAENGINE_URL=$DATAENGINE_URL_ENC
RULEENGINE_URL=$RULEENGINE_URL_ENC
EXPORTAPIENGINE_URL=$EXPORTAPIENGINE_URL_ENC
HIGHCHARTS_URL=$HIGHCHARTS_URL_ENC
RULEHIERARCHY=$RULEHIERARCHY
server.servlet.context-path=$CONTEXT_PATH
server.port=8081
server.tomcat.max-threads=1200
server.tomcat.accept-count=1200
spring.main.allow-bean-definition-overriding=true
spring.servlet.multipart.max-request-size=10MB
EOF

#mkdir WEB-INF/classes

echo "Replacing config file in the war"
cp AppConfig.Properties WEB-INF/classes
jar -uvf /usr/local/tomcat/webapps/nFlows.war WEB-INF/classes/AppConfig.Properties

echo "Launching tomcat..."
catalina.sh run