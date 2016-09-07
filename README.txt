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



DEPENDENCIES:
HADOOP HDFS DEPENDENCIES:
Co-located HDFS setup is needed to run the backend server. 127.0.0.1:8020 is HDFS namenode address.



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



PUBLIC KEY OF PAYMENT SERVICE:
pk_test_wyZIIuEmr4TQLHVnZHUxlTtm



WHAT RESTFUL APIs AVAILABLE?
RESTFUL APIs OF USERS:
1. get user by uid, e.g.
curl -i -X GET "http://127.0.0.1:8080/users/edmund"

2. create new user, e.g.
curl -i -X POST "http://127.0.0.1:8080/users" -d '{"uid":"edmund","fullName":"Edmund Burke","pwd":"123"}'

curl -i -X POST "http://127.0.0.1:8080/users" -d '{"uid":"kuan","fullName":"Kuan Chung","pwd":"123"}'

3. update user by uid, e.g.
curl -i -X PUT "http://127.0.0.1:8080/users/edmund" -d '{"pwd":"456"}'

curl -i -X PUT "http://127.0.0.1:8080/users/kuan" -d '{"pwd":"456"}'


RESTFUL APIs OF PROFILES:
1. get profile by uid, e.g.
curl -i -X GET "http://127.0.0.1:8080/profiles/edmund"

2. update profile by uid, e.g.
curl -i -X PUT "http://127.0.0.1:8080/profiles/edmund" -d '{"rate":200,"title":"Philosopher","aboutMe":"I was an Irish political philosopher, Whig politician and statesman who is often regarded as the father of modern conservatism."}'

curl -i -X PUT "http://127.0.0.1:8080/profiles/kuan" -d '{"rate":400,"title":"Chancellor and Reformer","aboutMe":"I was was a chancellor and reformer of the State of Qi during the Spring and Autumn Period of Chinese history."}'


RESTFUL APIs OF PROFILE FILTERING:
1. query profiles by a single column(e.g. fullName), e.g.
curl -i -X GET "http://127.0.0.1:8080/profiles?filter=fullName=edmund"
The column name is case sensitive, it only supports single column. In addition, it essentially does parttern matched query, e.g. fullName LIKE '%edmund%'

Example response:
{"uid":"edmund","rate":200.0,"avatarUrl":"/users/edmund/avatar","avatarImage":"dGhpcyBpcyBhbnN3ZXIgYXV0aWRvLg==","fullName":"Edmund Burke","title":"Philosopher","aboutMe":"I was an Irish political philosopher, Whig politician and statesman who is often regarded as the father of modern conservatism.","createdTime":null,"updatedTime":null}


RESTFUL APIs OF QUANDAS:
1. get quanda by id, e.g.
curl -i -X GET "http://127.0.0.1:8080/quandas/1"

2. update quanda by id, e.g.
curl -i -X PUT "http://127.0.0.1:8080/quandas/1" -d '{"answerAudio":"dGhpcyBpcyBhbnN3ZXIgYXV0aWRvLg==","status":"ANSWERED"}'


RESTFUL APIs OF QUANDAS FILTERING:
The results are reversely chronologically ordered by updatedTime as the first preference, and then createdTime.
1. load all quandas
curl -i -X GET "http://127.0.0.1:8080/quandas?filter=*"

2. query quandas by a single column(e.g. asker or responder), e.g.
curl -i -X GET "http://127.0.0.1:8080/quandas?filter=asker=kuan"
curl -i -X GET "http://127.0.0.1:8080/quandas?filter=responder=edmund"
The column name is case sensitive, it only supports single column. In addition, it essentially does equal matched query.


RESTFUL APIs OF QUESTIONS:
1. query questions, e.g.
curl -i -G -X GET http://127.0.0.1:8080/questions --data-urlencode "asker='bowen'", equivalent to
curl -i -X GET "http://127.0.0.1:8080/questions?asker='bowen'"

Example response:
[{"id":6,"question":"How do you believe in being an entrepreneur?","rate":100.0,"status":"ANSWERED","updatedTime":1472443395000,"responderName":"Xiaobing Zhou","responderTitle":"Software Engineer","responderAvatarUrl":"/users/xiaobingo/avatar","responderAvatarImage":"dGhpcyBpcyBhbnN3ZXIgYXV0aWRvLg=="}]


RESTFUL APIs OF ANSWERS:
1. query answers by other criteria, e.g.
curl -i -G -X GET http://127.0.0.1:8080/answers/ --data-urlencode "responder='bowen'", equivalent to
curl -i -X GET "http://127.0.0.1:8080/answers?responder='bowen'"

Example response:
[{"id":4,"question":"Are you nervous being an entrepreneur?","rate":300.0,"status":"EXPIRED","createdTime":1472169993000,"askerName":"Xiaobing Zhou","askerTitle":"Software Engineer","askerAvatarUrl":"/users/xiaobingo/avatar","askerAvatarImage":"dGhpcyBpcyBhbnN3ZXIgYXV0aWRvLg==","hoursToExpire":0}]


RESTFUL APIs OF SNOOPS:
1. query snoops, e.g.
curl -i -G -X GET http://127.0.0.1:8080/snoops --data-urlencode "uid='edmund'", equivalent to
curl -i -X GET "http://127.0.0.1:8080/snoops?uid='edmund'"

Example response:
[{"id":2,"uid":null,"quandaId":6,"createdTime":1472443947000,"question":"How do you believe in being an entrepreneur?","status":"ANSWERED","rate":100.0,"responderName":"Xiaobing Zhou","responderTitle":"Software Engineer","responderAvatarUrl":"/users/xiaobingo/avatar","responderAvatarImage":"dGhpcyBpcyBhbnN3ZXIgYXV0aWRvLg=="}]


RESTFUL APIs OF PCENTRY (i.e. credit/debit card or bank account):
1. get PcEntry by id, e.g.
curl -i -X GET "http://127.0.0.1:8080/pcentries/1"

2. create new PcEntry, e.g.
curl -i -X POST "http://127.0.0.1:8080/pcentries" -d '{"uid":"edmund","token":"tok_18fZTsEl5MEVXMYqdo1MHZtn"}'

3. delete PcEntry, e.g.
curl -i -X DELETE "http://127.0.0.1:8080/pcentries/1"


RESTFUL APIs OF FILTERING PCENTRY (i.e. credit/debit card or bank account):
1. load PcEntries by user id, e.g.
curl -i -X GET "http://127.0.0.1:8080/pcentries?filter=uid=edmund"
It doesn't support loading all, e.g. filter=*


RESTFUL APIs OF BALANCE:
1. get balance for a user with 'kuan' as uid, e.g.
curl -i -X GET "http://127.0.0.1:8080/balances/kuan"


RESTFUL APIs OF QATRANSACTION:
1. get QaTransaction by id, e.g.
curl -i -X GET "http://127.0.0.1:8080/qatransactions/1"

2. create new QaTransaction with type of ASKED, e.g.
curl -i -X POST "http://127.0.0.1:8080/qatransactions" -d '{"uid":"kuan","type":"ASKED","quanda":{"question":"How do you define a good man?","responder":"edmund"}}'

create new QaTransaction with type of SNOOPED, e.g.
curl -i -X POST "http://127.0.0.1:8080/qatransactions" -d '{"uid":"xiaobingo","type":"SNOOPED","quanda":{"id":1}}'


RESTFUL APIs OF NEWSFEED:
1. query newsfeed, e.g.
curl -i -G -X GET http://127.0.0.1:8080/newsfeeds/ --data-urlencode "uid='kuan'", equivalent to
curl -i -X GET "http://127.0.0.1:8080/newsfeeds?uid='kuan'"

Example response:
[{"quandaId":6,"question":"How do you believe in being an entrepreneur?","updatedTime":1472443395000,"responderId":"xiaobingo","responderName":"Xiaobing Zhou","responderTitle":"Software Engineer","responderAvatarUrl":"/users/xiaobingo/avatar","responderAvatarImage":"dGhpcyBpcyBhbnN3ZXIgYXV0aWRvLg==","snoops":1}]


RESTFUL APIs OF TEMP PASSWORD:
1. request new temp password, e.g.
curl -i -X POST "http://127.0.0.1:8080/temppwds" -d '{"uid":"edmund@gmail.com"}'

RESTFUL APIs OF RESETING PASSWORD:
1. reset password for a user, e.g.
curl -i -X POST "http://127.0.0.1:8080/resetpwd/edmund@gmail.com" -d '{"tempPwd":"1*j@Tz", "newPwd":"yyyy"}'


RESTFUL APIs OF EXPIRING QUANDAs:
1. to expire quandas, e.g.
curl -i -X POST "http://127.0.0.1:8080/quandas/expire"



HTTP STATUS CODE OF REST API:
1. get user (i.e. HTTP GET):
400(BAD_REQUEST):            "Missing parameter: uid" or various other information
404(NOT_FOUND):				 "Nonexistent resource with URI: /users/<user_id>"
200(OK):                     <user-json-string>
500(INTERNAL_SERVER_ERROR):  <various server error/exception>

2. delete user (i.e. HTTP DELETE):
400(BAD_REQUEST):            "Missing parameter: uid" or various other information
204(NO_CONTENT):             <deleted or not deleted depending on whether the uid is correct or the DB record exists>
500(INTERNAL_SERVER_ERROR):  <various server error/exception>

3. create user (i.e. HTTP POST):
400(BAD_REQUEST):            "No user or incorrect format specified." or various other information
201(CREATED):                "{"id":<id>}"
500(INTERNAL_SERVER_ERROR):  <various server error/exception>

4. update user (i.e. HTTP PUT)
400(BAD_REQUEST):            "No user or incorrect format specified." or various other information
204(NO_CONTENT):             <updated or not updated depending on whether the uid is correct or the DB record exists>
500(INTERNAL_SERVER_ERROR):  <various server error/exception>



HOW TO FIND DB SCHEMA?
server/src/main/resources/com/gibbon/peeq/scripts/schema.sql



HOW TO FILE BUGS?
go to https://gibbon.atlassian.net



WHERE TO DOWNLOAD SOURCE CODE?
go to https://github.com/newgibbon

