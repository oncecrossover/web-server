WHAT IS IT?
Peeq is a novel social Q&A community, where people paid to get voice answers from celebrities they love most to ask questions for. Three major functions in the community:
1. Celebrities get paid for answering questions by voice.
2. People pay to ask celebrities questions.
3. Eavesdroppers pay to hear others' answers.



DIRECTORY STRUCTURE:
server:  backend server
Peeq:    IOS frontend



HOW TO COMIPLE?
mvn clean package



HOW TO INITIALIZE MySQL?
execute com.gibbon.peeq.scripts/schema.sql to create tables.



HOW TO CHANGE PARAMETERS OF DB CONNECTION?
go to com.gibbon.peeq.scripts/hibernate.cfg.xml, change <hibernate.connection.url>,
<hibernate.connection.username> and <hibernate.connection.password> accordingly.



HOW TO RUN SERVER?
./run-jar.sh, you will see
  Usage: run-jar.sh [-D<name>[=<value>] ...] <server-name>
Example: run-jar.sh -Dport=8443 -Dssl peeq-snoop-server
         run-jar.sh -Dhost=127.0.0.1 -Dport=8009 peeq-snoop-server
         run-jar.sh -DlogLevel=debug -Dhost=127.0.0.1 -Dport=8009 peeq-snoop-server

Available servers:

  http-snoop-client       peeq-snoop-server

Specially, ./run-jar.sh peeq-snoop-server to start peeq-snoop-server

./run-jar.sh will also compile/package any changes you made to the code base.



WHAT RESTFUL APIs AVAILABLE?
RESTFUL APIs OF USERS:
1. get user information by id, e.g.
curl -i -X GET "http://127.0.0.1:8080/users/edmund"

2. delete user by id, e.g.
curl -i -X DELETE "http://127.0.0.1:8080/users/edmund"

3. create a new user, e.g.
curl -i -X POST "http://127.0.0.1:8080/users" -d '{"uid":"edmund","firstName":"Edmund","middleName":"Peng","lastName":"Burke","pwd":"123","createdTime":1467156716625,"updatedTime":1467156716625,"profile":{"uid":null,"avatarUrl":"https://en.wikiquote.org/wiki/Edmund_Burke","avatarImage":null,"fullName":"Edmund Peng Burke","title":"Philosopher","aboutMe":"I was an Irish political philosopher, Whig politician and statesman who is often regarded as the father of modern conservatism."}}'

4. update user, e.g.
curl -i -X PUT "http://127.0.0.1:8080/users/edmund" -d '{"uid":"edmund","firstName":"Edmund","middleName":"Peng","lastName":"Burke","pwd":"456","createdTime":1467156716625,"updatedTime":1467156716625,"profile":{"uid":null,"avatarUrl":"https://en.wikiquote.org/wiki/Edmund_Burke","avatarImage":null,"fullName":"Edmund Burke","title":"Philosopher","aboutMe":"I was an Irish political philosopher, Whig politician and statesman who is often regarded as the father of modern conservatism."}}'

RESTFUL APIs OF PROFILES:
1. to get profile infomation by uid, e.g.
curl -i -X GET "http://127.0.0.1:8080/profiles/edmund"

2. update profile, e.g.
curl -i -X PUT "http://127.0.0.1:8080/profiles/edmund" -d '{"uid":"edmund","avatarUrl":"https://en.wikiquote.org/wiki/Edmund_Burke","avatarImage":null,"fullName":"Edmund Burke","title":"Philosopher","aboutMe":"I was an Irish political philosopher, Whig politician and statesman who is often regarded as the father of modern conservatism."}'

RESTFUL APIs OF PROFILE FILTERING:
1. load all profile records, e.g.
curl -i -X GET "http://127.0.0.1:8080/profiles?filter=*"

2. Do a query based on single column:
curl -i -X GET "http://127.0.0.1:8080/profiles?filter=uid=edmund"



HTTP STATUS CODE OF REST API:
1. get user (i.e. HTTP GET):
400(BAD_REQUEST):            Missing parameter: uid
200(OK):                     <user-json-string> or "Nonexistent resource with URI: /users/<user_id>"
500(INTERNAL_SERVER_ERROR):  <various server error/exception>

2. delete user (i.e. HTTP DELETE):
400(BAD_REQUEST):            Missing parameter: uid
204(NO_CONTENT):             <deleted or not deleted depending on whether the uid is correct or the DB record exists>
500(INTERNAL_SERVER_ERROR):  <various server error/exception>

3. create user (i.e. HTTP POST):
400(BAD_REQUEST):            "No user or incorrect format specified."
201(CREATED):                "New resource created with URI: /users/<user_id>"
500(INTERNAL_SERVER_ERROR):  <various server error/exception>

4. update user (i.e. HTTP PUT)
400(BAD_REQUEST):            "No user or incorrect format specified."
204(NO_CONTENT):             <updated or not updated depending on whether the uid is correct or the DB record exists>
500(INTERNAL_SERVER_ERROR):  <various server error/exception>



HOW TO FILE BUGS?
go to https://gibbon.atlassian.net



WHERE TO DOWNLOAD SOURCE CODE?
go to https://github.com/newgibbon

