FROM tomcat:8
# Take the war and copy to webapps of tomcat
COPY target/stradegi-1.war /usr/local/tomcat/webapps/
