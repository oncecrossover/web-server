What is it?
This project is Netty based backend server that integrates Hibernate to talk MySQL


How to compile?
mvn clean package


How to initialize MySQL?
execute com.gibbon.peeq.scripts/schema.sql to create tables.

How to change DB connection parameters:
go to com.gibbon.peeq.scripts/hibernate.cfg.xml, change <hibernate.connection.url>,
<hibernate.connection.username> and <hibernate.connection.password> accordingly.

How to run server?
./run-jar.sh, you will see
Usage: run-jar.sh [-D<name>[=<value>] ...] <server-name>
Example: run-jar.sh -Dport=8443 -Dssl peeq-snoop-server
         run-jar.sh -Dhost=127.0.0.1 -Dport=8009 peeq-snoop-server
         run-jar.sh -DlogLevel=debug -Dhost=127.0.0.1 -Dport=8009 peeq-snoop-server

Available servers:

  peeq-snoop-server

Specially, ./run-jar.sh peeq-snoop-server to start peeq-snoop-server

./run-jar.sh will also compile/package any changes made to source code.


What RESTful APIs available:
1. getuser: query user information by id, e.g.
curl -i "http://127.0.0.1:8080/user?op=getuser&uid=xiaobingo"

2. remove user: delete user by id from DB, e.g.
curl -i -X PUT  "http://127.0.0.1:8080/user?op=rmuser&uid=xiaobingo"

3. putuser: insert a new user to DB, e.g.
curl -i -X PUT  "http://127.0.0.1:8080/user?op=putuser&uid=xiaobingo&fname=Xiaobing&mname=Yunxuan&lname=Zhou&pwd=123"

4. upduser: update user's change to DB
curl -i -X PUT  "http://127.0.0.1:8080/user?op=upduser&uid=xiaobingo&fname=Xiaobing&mname=Edgar&lname=Zhou&pwd=123"


How to file BUGs?
go to https://gibbon.atlassian.net


Where to download source code:
go to https://github.com/newgibbon

