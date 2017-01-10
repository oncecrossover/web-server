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
mvn clean package -DskipTests



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
  Usage: run-jar.sh [-D<name>[=<value>] ...] <component-name>
Example: run-jar.sh  peeq-snoop-server
         run-jar.sh -Dhttp.snoop.server.port=8080 peeq-snoop-server
         run-jar.sh -Dhttp.snoop.server.port=8443 -Dhttp.snoop.ssl peeq-snoop-server
         run-jar.sh -Dhttp.snoop.server.host=127.0.0.1 -Dhttp.snoop.server.port=8443 -Dhttp.snoop.ssl -Dresource.uri=users/edmund peeq-snoop-client

Available servers:

  peeq-snoop-client       peeq-snoop-server

Specifically, "./run-jar.sh peeq-snoop-server" to start snoop server, and
"nohup ./run-jar.sh peeq-snoop-server &" will run snoop server as long running independent daemon.

./run-jar.sh will also compile/package any changes you made to the code base.



PUBLIC KEY OF PAYMENT SERVICE:
pk_test_wyZIIuEmr4TQLHVnZHUxlTtm



WHAT RESTFUL APIs AVAILABLE?
RESTFUL APIs OF USERS:
1. get user by uid, e.g.
curl -i -X GET "http://127.0.0.1:8080/users/edmund"

2. create new user, e.g.
curl -i -X POST "http://127.0.0.1:8080/users" -d '{"uid":"edmund","fullName":"Edmund Burke","pwd":"123"}'


RESTFUL APIs OF SIGNIN:
1. sign-in by user id and password, e.g.
curl -i -X POST "http://127.0.0.1:8080/signin" -d '{"uid":"kuan","pwd":"123"}'


RESTFUL APIs OF PROFILES:
1. get profile by uid, e.g.
curl -i -X GET "http://127.0.0.1:8080/profiles/edmund"
curl -i -G -X GET http://127.0.0.1:8080/profiles --data-urlencode "uid='edmund'", equivalent to
curl -i -X GET "http://127.0.0.1:8080/profiles/edmund"

2. get profile by name. It's always doing SQL LIKE style query.
For example, fullName LIKE 'edmund burke':
curl -i -G -X GET http://127.0.0.1:8080/profiles --data-urlencode "fullName='edmund burke'", equivalent to
curl -i -X GET "http://127.0.0.1:8080/profiles?fullName='edmund burke'"

For example, fullName LIKE '%edmund%':
curl -i -G -X GET http://127.0.0.1:8080/profiles --data-urlencode "fullName='%edmund%'", equivalent to
curl -i -X GET "http://127.0.0.1:8080/profiles?fullName='%edmund%'"

3. update profile by uid, e.g.
curl -i -X PUT "http://127.0.0.1:8080/profiles/edmund" -d '{"rate":200,"title":"Philosopher","aboutMe":"I was an Irish political philosopher, Whig politician and statesman who is often regarded as the father of modern conservatism."}'

4. paginate profiles.
Both lastSeenUpdatedTime and lastSeenId must be specified since updatedTime can have duplicate values.
Limit defaults as 10 if it's not specified.

Query all, limit must be specified, e.g.
curl -i -G -X GET http://127.0.0.1:8080/profiles -d "limit=20", equivalent to
curl -i -X GET "http://127.0.0.1:8080/profiles?limit=20"

Query based on the last seen, e.g.
curl -i -G -X GET http://127.0.0.1:8080/profiles --data-urlencode "takeQuestion='APPROVED'" --data-urlencode "fullName='%zh%'" --data-urlencode "lastSeenUpdatedTime=1474607620000" -d "lastSeenId='xiaobingo'" -d "limit=20", equivalent to
curl -i -X GET "http://127.0.0.1:8080/questions?takeQuestion='APPROVED'&fullName='%zh%'&lastSeenUpdatedTime=1474607620000&lastSeenId='xiaobingo'&limit=20"

Example response:
{"uid":"edmund","rate":200.0,"avatarUrl":"/users/edmund/avatar","avatarImage":"dGhpcyBpcyBhbnN3ZXIgYXV0aWRvLg==","fullName":"Edmund Burke","title":"Philosopher","aboutMe":"I was an Irish political philosopher, Whig politician and statesman who is often regarded as the father of modern conservatism.","takeQuestion":"APPROVED","createdTime":null,"updatedTime":1484030623000}


RESTFUL APIs OF QUANDAS:
1. get quanda by id, e.g.
curl -i -X GET "http://127.0.0.1:8080/quandas/1"

2. answer question by id, e.g.
curl -i -X PUT "http://127.0.0.1:8080/quandas/1" -d '{"answerAudio":"dGhpcyBpcyBhbnN3ZXIgYXV0aWRvLg==","answerCover":"dGhpcyBpcyBhbnN3ZXIgYXV0aWRvLg==","status":"ANSWERED"}'

3. deactivate quanda by id, e.g.
curl -i -X PUT "http://127.0.0.1:8080/quandas/1" -d '{"active":"FALSE"}'


RESTFUL APIs OF QUESTIONS:
1. query questions, e.g.
curl -i -G -X GET http://127.0.0.1:8080/questions --data-urlencode "asker='bowen'", equivalent to
curl -i -X GET "http://127.0.0.1:8080/questions?asker='bowen'"

2. paginate questions.
Both lastSeenUpdatedTime and lastSeenId must be specified since updatedTime can have duplicate values. Limit defaults as 10 if it's not specified.
For example:
curl -i -G -X GET http://127.0.0.1:8080/questions -d "asker='kuan'" --data-urlencode "lastSeenUpdatedTime=1474522304000" -d "lastSeenId=3" -d "limit=20", equivalent to
curl -i -X GET "http://127.0.0.1:8080/questions?asker='kuan'&lastSeenUpdatedTime=1474522304000&lastSeenId=3&limit=20"

Example response:
[{"id":6,"question":"How do you believe in being an entrepreneur?","rate":100.0,"status":"ANSWERED","updatedTime":1472443395000, "answerCover": "SDFGSDF2456254GWFQRTG!", "responderName":"Xiaobing Zhou","responderTitle":"Software Engineer","responderAvatarUrl":"/users/xiaobingo/avatar","responderAvatarImage":"dGhpcyBpcyBhbnN3ZXIgYXV0aWRvLg==", "askerName":"Jason", "askerAvatarImage": "2G%23FAS=", "duration":45}]


RESTFUL APIs OF ANSWERS:
1. query answers by other criteria, e.g.
curl -i -G -X GET http://127.0.0.1:8080/answers/ --data-urlencode "responder='bowen'", equivalent to
curl -i -X GET "http://127.0.0.1:8080/answers?responder='bowen'"

2. paginate answers.
Both lastSeenCreatedTime and lastSeenId must be specified since createdTime can have duplicate values. Limit defaults as 10 if it's not specified.
For example:
curl -i -G -X GET http://127.0.0.1:8080/answers/ -d "responder='edmund'" --data-urlencode "lastSeenCreatedTime=1473224175000" -d "lastSeenId=3" -d "limit=20", equivalent to
curl -i -X GET "http://127.0.0.1:8080/answers?responder='edmund'&lastSeenCreatedTime=1473224175000&lastSeenId=3&limit=20"

Example response:
[{"id":4,"question":"Are you nervous being an entrepreneur?","rate":300.0,"status":"EXPIRED","createdTime":1472169993000, "answerCover": "FADY@%$^GAQRGQGT%Q%TY%$T#%G$=", askerName":"Xiaobing Zhou", "askerAvatarUrl":"/users/xiaobingo/avatar","askerAvatarImage":"dGhpcyBpcyBhbnN3ZXIgYXV0aWRvLg==", "responderName": "Ben", "responderTitle": "engineer", "responderAvatarUrl": "/users/ben/avatar", "responderAvatarImage": "AGSD3546AGFADFGTQ$%Y@$%Y==",  "hoursToExpire":0}]


RESTFUL APIs OF SNOOPS:
1. query snoops, e.g.
curl -i -G -X GET http://127.0.0.1:8080/snoops --data-urlencode "uid='edmund'", equivalent to
curl -i -X GET "http://127.0.0.1:8080/snoops?uid='edmund'"

2. paginate snoops.
Both lastSeenCreatedTime and lastSeenId must be specified since createdTime can have duplicate values. Limit defaults as 10 if it's not specified.
For example:
curl -i -G -X GET http://127.0.0.1:8080/snoops -d "uid='kuan'" --data-urlencode "lastSeenCreatedTime=1473225675000" -d "lastSeenId=10" -d "limit=20", equivalent to
curl -i -X GET "http://127.0.0.1:8080/snoops?uid='kuan'&lastSeenCreatedTime=1473225675000&lastSeenId=10&limit=20"

Example response:
[{"id":2,"uid":null,"quandaId":6,"createdTime":1472443947000,"question":"How do you believe in being an entrepreneur?","status":"ANSWERED","rate":100.0,"responderName":"Xiaobing Zhou","responderTitle":"Software Engineer","responderAvatarUrl":"/users/xiaobingo/avatar","responderAvatarImage":"dGhpcyBpcyBhbnN3ZXIgYXV0aWRvLg==", "askerName":"Kansen", "askerAvatarImage":"F$GWTU&^fds", "duration":45}]


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

2. paginate newsfeed.
Both lastSeenUpdatedTime and lastSeenId must be specified since updatedTime can have duplicate values. Limit defaults as 10 if it's not specified.
For example:
curl -i -G -X GET http://127.0.0.1:8080/newsfeeds/ -d "uid='bowen'" --data-urlencode "lastSeenUpdatedTime=1474522304000" -d "lastSeenId=3" -d "limit=10", equivalent to
curl -i -X GET "http://127.0.0.1:8080/newsfeeds?uid='bowen'&lastSeenUpdatedTime=1474522304000&lastSeenId=3&limit=10"

Example response:
[{"id":6,"question":"How do you believe in being an entrepreneur?","updatedTime":1472443395000,"responderId":"xiaobingo","responderName":"Xiaobing Zhou","responderTitle":"Software Engineer","responderAvatarUrl":"/users/xiaobingo/avatar","responderAvatarImage":"dGhpcyBpcyBhbnN3ZXIgYXV0aWRvLg==","answerCover": "AFD$#QTGAER==","askerName": "Kansen", "askerAvatarImage": "GTRWGQ#$TGAFDG", "duration": 56, "snoops":1}]


RESTFUL APIs OF TEMP PASSWORD:
1. request new temp password, e.g.
curl -i -X POST "http://127.0.0.1:8080/temppwds" -d '{"uid":"edmund@gmail.com"}'

RESTFUL APIs OF RESETING PASSWORD:
1. reset password for a user, e.g.
curl -i -X POST "http://127.0.0.1:8080/resetpwd/edmund@gmail.com" -d '{"tempPwd":"1*j@Tz", "newPwd":"yyyy"}'


RESTFUL APIs OF EXPIRING QUANDAs:
1. to expire quandas, e.g.
curl -i -X POST "http://127.0.0.1:8080/quandas/expire"


RESTFUL APIs TO APPLY FOR/APROVE/DENY TAKING QUESTIONs:
1. to apply for taking questions, e.g.
curl -i -X POST "http://127.0.0.1:8080/takeq" -d '{"uid":"kuan","takeQuestion":"APPLIED"}'

2. to approve taking questions, e.g.
curl -i -X POST "http://127.0.0.1:8080/takeq" -d '{"uid":"kuan","takeQuestion":"APPROVED"}'

3. to deny taking questions, e.g.
curl -i -X POST "http://127.0.0.1:8080/takeq" -d '{"uid":"kuan","takeQuestion":"DENIED"}'



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



PLAY WITH SECURITY TEST
1. bash run-jar.sh -Dhttp.snoop.ssl  peeq-snoop-server
2. bash run-jar.sh -Dhttp.snoop.ssl -Dresource.uri=users/edmund peeq-snoop-client

Programmatically, http should be replaced with https for security, the port should be changed too.
Without proper certificates, curl command is not supported, please switch to insecure conf for curl for test purpose.

To log detailed security related logs, please refer to http://stackoverflow.com/questions/23659564/limiting-java-ssl-debug-logging



HOW TO FIND DB SECURITY CONFS?
server/src/main/resources/com/snoop/server/security/

a8d59c0e0933fe7c.crt:        CA signed certificates for snoop
gd_bundle-g2-g1.crt:         CA signed root certificates
snoop-cert-ca.zip:           zip that contains the two files above
snoop-cert.csr:              certificates signing request file
snoop-client-keystore.jks:   client-side keystore
snoop-client-truststore.jks: server-side truststore
snoop-client.crt:            client-side public key certificate
snoop-server-keystore.jks:   server-side keystore
snoop-server-truststore.jks: client-side truststore
snoop-server.crt:            server-side public key certificate



HOW TO FIND DB SCHEMA?
server/src/main/resources/com/gibbon/peeq/scripts/schema.sql



HOW TO FILE BUGS?
go to https://gibbon.atlassian.net



WHERE TO DOWNLOAD SOURCE CODE?
go to https://github.com/newgibbon

