FROM tomcat:8
# Take the war and copy to webapps of tomcat
COPY myweb-0.0.5.war /usr/local/tomcat/webapps/
# Added for jenkins demo
