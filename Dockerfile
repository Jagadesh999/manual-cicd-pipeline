FROM tomcat:9
COPY target/simple-webapp.war /usr/local/tomcat/webapps/
CMD ["catalina.sh", "run"]

