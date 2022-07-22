FROM tomcat:8
# Take the war and copy to webapps of tomcat
COPY target/java-web-app-1.0.war /usr/local/tomcat/webapps/myweb-0.0.5
# Added for jenkins demo
