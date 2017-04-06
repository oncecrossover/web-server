WHAT IS IT?
Snoop is a novel social Q&A community, where people paid to get voice answers from celebrities they love most to ask questions for. Three major functions in the community:
1. Celebrities get paid for answering questions by voice.
2. People pay to ask celebrities questions.
3. Eavesdroppers pay to hear others' answers.



DIRECTORY STRUCTURE:
server:  backend server
Snoop:    IOS frontend



HOW TO COMIPLE?
mvn clean package
mvn clean package -DskipTests



DEPENDENCIES:
HADOOP HDFS DEPENDENCIES:
Co-located HDFS setup is needed to run the backend server. 127.0.0.1:8020 is HDFS namenode address.



HOW TO INITIALIZE MySQL?
execute com.snoop.server.scripts/schema.sql to create tables.



HOW TO CHANGE PARAMETERS OF DB CONNECTION?
go to com.snoop.server.scripts/hibernate.cfg.xml, change <hibernate.connection.url>,
<hibernate.connection.username> and <hibernate.connection.password> accordingly.



HOW TO RUN SERVER?
./run-jar.sh, you will see
  Usage: run-jar.sh [-D<name>[=<value>] ...] <component-name>
Example: run-jar.sh  snoop-web-server
         run-jar.sh -Dhttp.snoop.server.port=8080 snoop-web-server
         run-jar.sh -Dhttp.snoop.server.port=8443 -Dhttp.snoop.ssl snoop-web-server
         run-jar.sh -Dhttp.snoop.server.host=127.0.0.1 -Dhttp.snoop.server.port=8443 -Dhttp.snoop.ssl -Dresource.uri=users/edmund snoop-web-client

Available servers:

  snoop-web-client        snoop-web-server

Specifically, "./run-jar.sh snoop-web-server" to start snoop server, and
"nohup ./run-jar.sh snoop-web-server &" will run snoop server as long running independent daemon.

./run-jar.sh will also compile/package any changes you made to the code base.



PUBLIC KEY OF PAYMENT SERVICE:
pk_test_wyZIIuEmr4TQLHVnZHUxlTtm



WHAT RESTFUL APIs AVAILABLE?
RESTFUL APIs OF USERS:
1. get user by uid, e.g.
curl -i -X GET "http://127.0.0.1:8080/users/812381424844800"
Example response:
{
  "uid": 812381424844800,
  "uname": "bingo@snoopqa.com",
  "pwd": null,
  "primaryEmail": "bingo@snoopqa.com",
  "createdTime": 1491148086000,
  "updatedTime": 1491195101000,
  "fullName": null,
  "profile": null,
  "pcAccount": null
}

2. create new user, e.g.
curl -i -X POST "http://127.0.0.1:8080/users" -d '{"uname":"edmund@fight.com","primaryEmail":"edmund@fight.com","fullName":"Bingo Zhou","pwd":"123"}'

3. Query users by uid, uname and so on, e.g.
curl -i -G -X GET http://127.0.0.1:8080/users --data-urlencode "uid=812381424844800", equivalent to
curl -i -X GET "http://127.0.0.1:8080/users/812381424844800"

curl -i -G -X GET http://127.0.0.1:8080/users --data-urlencode "uname='bingo@snoopqa.com'", equivalent to
curl -i -X GET "http://127.0.0.1:8080/users?uname='bingo@snoopqa.com'"

4. paginate users, e.g.
Both lastSeenUpdatedTime and lastSeenId must be specified since updatedTime can have duplicate values.
Limit defaults as 10 if it's not specified.

Query based on the last seen, e.g.
curl -i -G -X GET http://127.0.0.1:8080/users --data-urlencode "uname='%o%'" --data-urlencode "lastSeenUpdatedTime=1491201766000" -d "lastSeenId=1037529214091264" -d "limit=20", equivalent to
curl -i -X GET "http://127.0.0.1:8080/users?uname='%%o%%'&lastSeenUpdatedTime=1491201766000&lastSeenId=812381424844800&limit=20"
Example response:
[
  {
    "uid": 812381424844800,
    "uname": "bingo@snoopqa.com",
    "pwd": null,
    "primaryEmail": "bingo@snoopqa.com",
    "createdTime": 1491148086000,
    "updatedTime": 1491195101000,
    "fullName": null,
    "profile": null,
    "pcAccount": null
  },
  {
    "uid": 813938593759232,
    "uname": "xzhou40@gmail.com",
    "pwd": null,
    "primaryEmail": "xzhou40@gmail.com",
    "createdTime": 1491148458000,
    "updatedTime": 1491148458000,
    "fullName": null,
    "profile": null,
    "pcAccount": null
  }
]


RESTFUL APIs OF SIGNIN:
1. sign-in by user name and password, e.g.
curl -i -X POST "http://127.0.0.1:8080/signin" -d '{"uname":"edmund@fight.com","pwd":"123"}'
Example response:
{"uid":1918315924553728}


RESTFUL APIs OF PROFILES:
1. get profile by uid, e.g.
curl -i -X GET "http://127.0.0.1:8080/profiles/812381424844800"
curl -i -G -X GET http://127.0.0.1:8080/profiles --data-urlencode "uid=812381424844800", equivalent to
curl -i -X GET "http://127.0.0.1:8080/profiles/812381424844800"

2. get profile by name. It's always doing SQL LIKE style query.
For example, fullName LIKE 'edmund burke':
curl -i -G -X GET http://127.0.0.1:8080/profiles --data-urlencode "fullName='edmund burke'", equivalent to
curl -i -X GET "http://127.0.0.1:8080/profiles?fullName='edmund burke'"

For example, fullName LIKE '%edmund%':
curl -i -G -X GET http://127.0.0.1:8080/profiles --data-urlencode "fullName='%edmund%'", equivalent to
curl -i -X GET "http://127.0.0.1:8080/profiles?fullName='%edmund%'"

3. update profile by uid, e.g.
curl -i -X PUT "http://127.0.0.1:8080/profiles/813938593759232" -d '{"rate":200,"title":"Philosopher","aboutMe":"I was an Irish political philosopher, Whig politician and statesman who is often regarded as the father of modern conservatism."}'

4. paginate profiles.
Both lastSeenUpdatedTime and lastSeenId must be specified since updatedTime can have duplicate values.
Limit defaults as 10 if it's not specified.

Query all, limit must be specified, e.g.
curl -i -G -X GET http://127.0.0.1:8080/profiles -d "limit=20", equivalent to
curl -i -X GET "http://127.0.0.1:8080/profiles?limit=20"

Query based on the last seen, e.g.
curl -i -G -X GET http://127.0.0.1:8080/profiles --data-urlencode "takeQuestion='APPROVED'" --data-urlencode "fullName='%zh%'" --data-urlencode "lastSeenUpdatedTime=1491148086000" -d "lastSeenId=812381424844800" -d "limit=20", equivalent to
curl -i -X GET "http://127.0.0.1:8080/questions?takeQuestion='APPROVED'&fullName='%zh%'&lastSeenUpdatedTime=1491148086000&lastSeenId=812381424844800&limit=20"
Example response:
[
  {
    "uid": 813938593759232,
    "rate": 200,
    "avatarUrl": null,
    "avatarImage": null,
    "fullName": "Edmund Burke",
    "title": "Philosopher",
    "aboutMe": "I was an Irish political philosopher, Whig politician and statesman who is often regarded as the father of modern conservatism.",
    "takeQuestion": "NA",
    "deviceToken": null,
    "createdTime": null,
    "updatedTime": 1491148458000
  }
]


RESTFUL APIs OF QUANDAS:
1. get quanda by id, e.g.
curl -i -X GET "http://127.0.0.1:8080/quandas/1012998336413696"
Example response:
{
  "id": 1012998336413696,
  "asker": 812381424844800,
  "question": "How do you define a good man?",
  "responder": 813938593759232,
  "rate": 2,
  "answerUrl": "https://ddk9xa5p5b3lb.cloudfront.net/answers/videos/1012998336413696/1012998336413696.mp4",
  "answerCoverUrl": "https://ddk9xa5p5b3lb.cloudfront.net/answers/thumbnails/1012998336413696/1012998336413696.png",
  "answerMedia": null,
  "answerCover": null,
  "duration": 0,
  "status": "ANSWERED",
  "active": "TRUE",
  "createdTime": 1491195917000,
  "updatedTime": 1491195917000,
  "snoops": null,
  "hoursToExpire": 47
}

2. answer question by id, e.g.
curl -i -X PUT "http://127.0.0.1:8080/quandas/1012998336413696" -d '{"answerMedia":"dGhpcyBpcyBhbnN3ZXIgYXV0aWRvLg==","answerCover":"dGhpcyBpcyBhbnN3ZXIgYXV0aWRvLg==","status":"ANSWERED"}'

3. deactivate quanda by id, e.g.
curl -i -X PUT "http://127.0.0.1:8080/quandas/1012998336413696" -d '{"active":"FALSE"}'


RESTFUL APIs OF QUESTIONS:
1. query questions, e.g.
curl -i -G -X GET http://127.0.0.1:8080/questions --data-urlencode "asker=812381424844800", equivalent to
curl -i -X GET "http://127.0.0.1:8080/questions?asker=812381424844800"

2. paginate questions.
Both lastSeenUpdatedTime and lastSeenId must be specified since updatedTime can have duplicate values. Limit defaults as 10 if it's not specified.
For example:
curl -i -G -X GET http://127.0.0.1:8080/questions -d "asker=812381424844800" --data-urlencode "lastSeenUpdatedTime=1491195917000" -d "lastSeenId=1012998336413696" -d "limit=20", equivalent to
curl -i -X GET "http://127.0.0.1:8080/questions?asker=812381424844800&lastSeenUpdatedTime=1491195917000&lastSeenId=1012998336413696&limit=20"

Example response:
[
  {
    "id": 1012998336413696,
    "question": "How do you predict house market in US?",
    "rate": 1,
    "status": "ANSWERED",
    "createdTime": 1484635427000,
    "updatedTime": 1484635427000,
    "answerUrl": "https://ddk9xa5p5b3lb.cloudfront.net/answers/videos/1012998336413696/1012998336413696.mp4",
    "answerCoverUrl": "https://ddk9xa5p5b3lb.cloudfront.net/answers/thumbnails/1012998336413696/1012998336413696.png"
    "answerCover": null,
    "duration": 0,
    "hoursToExpire": 0,
    "responderName": "Bowen Zhang",
    "responderTitle": null,
    "responderAvatarUrl": null,
    "responderAvatarImage": null,
    "askerName": "Xiaobing Zhou",
    "askerAvatarUrl": null,
    "askerAvatarImage": null
  }
]


RESTFUL APIs OF ANSWERS:
1. query answers by other criteria, e.g.
curl -i -G -X GET http://127.0.0.1:8080/answers/ --data-urlencode "responder=813938593759232", equivalent to
curl -i -X GET "http://127.0.0.1:8080/answers?responder=813938593759232"

2. paginate answers.
Both lastSeenCreatedTime and lastSeenId must be specified since createdTime can have duplicate values. Limit defaults as 10 if it's not specified.
For example:
curl -i -G -X GET http://127.0.0.1:8080/answers/ -d "responder=813938593759232" --data-urlencode "lastSeenCreatedTime=1473224175000" -d "lastSeenId=3" -d "limit=20", equivalent to
curl -i -X GET "http://127.0.0.1:8080/answers?responder=813938593759232&lastSeenCreatedTime=1473224175000&lastSeenId=3&limit=20"

Example response:
[
  {
    "id": 1031638783885312,
    "question": "What would you pursue if given a second life?",
    "rate": 2,
    "status": "ANSWERED",
    "createdTime": 1491200361000,
    "answerUrl": "https://ddk9xa5p5b3lb.cloudfront.net/answers/videos/1031638783885312/1031638783885312.mp4",
    "answerCoverUrl": "https://ddk9xa5p5b3lb.cloudfront.net/answers/thumbnails/1031638783885312/1031638783885312.png",
    "answerCover": null,
    "duration": 0,
    "responderName": "Edmund Zhou",
    "responderTitle": "Philosopher",
    "responderAvatarUrl": null,
    "responderAvatarImage": null,
    "askerName": "Bingo Zhou",
    "askerAvatarUrl": null,
    "askerAvatarImage": null,
    "hoursToExpire": 48
  }
]


RESTFUL APIs OF SNOOPS:
1. query snoops, e.g.
curl -i -G -X GET http://127.0.0.1:8080/snoops --data-urlencode "uid=813562284998656", equivalent to
curl -i -X GET "http://127.0.0.1:8080/snoops?uid=813562284998656"

2. paginate snoops.
Both lastSeenCreatedTime and lastSeenId must be specified since createdTime can have duplicate values. Limit defaults as 10 if it's not specified.
For example:
curl -i -G -X GET http://127.0.0.1:8080/snoops -d "uid=813562284998656" --data-urlencode "lastSeenCreatedTime=1473225675000" -d "lastSeenId=10" -d "limit=20", equivalent to
curl -i -X GET "http://127.0.0.1:8080/snoops?uid=813562284998656&lastSeenCreatedTime=1473225675000&lastSeenId=10&limit=20"

Example response:
[
  {
    "id": 1036727590322176,
    "uid": null,
    "quandaId": 1031638783885312,
    "createdTime": 1491201575000,
    "question": "What would you pursue if given a second life?",
    "status": "ANSWERED",
    "rate": 2,
    "answerUrl": "https://ddk9xa5p5b3lb.cloudfront.net/answers/videos/1031638783885312/1031638783885312.mp4",
    "answerCoverUrl": "https://ddk9xa5p5b3lb.cloudfront.net/answers/thumbnails/1031638783885312/1031638783885312.png",
    "answerCover": null,
    "duration": 0,
    "responderName": "Edmund Zhou",
    "responderTitle": "Philosopher",
    "responderAvatarUrl": null,
    "responderAvatarImage": null,
    "askerName": "Bingo Zhou",
    "askerAvatarUrl": null,
    "askerAvatarImage": null
  }
]


RESTFUL APIs OF PCENTRY (i.e. credit/debit card or bank account):
1. get PcEntry by id, e.g.
curl -i -X GET "http://127.0.0.1:8080/pcentries/964211601571840"

2. create new PcEntry, e.g.
curl -i -X POST "http://127.0.0.1:8080/pcentries" -d '{"uid":813938593759232,"token":"tok_1A4KLCEl5MEVXMYqYxar9tOV"}'

3. delete PcEntry, e.g.
curl -i -X DELETE "http://127.0.0.1:8080/pcentries/1"


RESTFUL APIs OF FILTERING PCENTRY (i.e. credit/debit card or bank account):
1. load PcEntries by user id, e.g.
curl -i -X GET "http://127.0.0.1:8080/pcentries?filter=uid=813938593759232"
It doesn't support loading all, e.g. filter=*


RESTFUL APIs OF BALANCE:
1. get balance for a user with 'kuan' as uid, e.g.
curl -i -X GET "http://127.0.0.1:8080/balances/812381424844800"
Example response:
{
  "uid": 812381424844800,
  "balance": 0
}

RESTFUL APIs OF QATRANSACTION:
1. get QaTransaction by id, e.g.
curl -i -X GET "http://127.0.0.1:8080/qatransactions/1012998336413697"

2. create new QaTransaction with type of ASKED, e.g.
curl -i -X POST "http://127.0.0.1:8080/qatransactions" -d '{"uid":812381424844800,"type":"ASKED","quanda":{"question":"How do you define a good man?","responder":813938593759232}}'

create new QaTransaction with type of SNOOPED, e.g.
curl -i -X POST "http://127.0.0.1:8080/qatransactions" -d '{"uid":"813562284998656","type":"SNOOPED","quanda":{"id":1012998336413696}}'


RESTFUL APIs OF NEWSFEED:
1. query newsfeed, e.g.
curl -i -G -X GET http://127.0.0.1:8080/newsfeeds/ --data-urlencode "uid=1037529214091264", equivalent to
curl -i -X GET "http://127.0.0.1:8080/newsfeeds?uid=1037529214091264"

2. paginate newsfeed.
Both lastSeenUpdatedTime and lastSeenId must be specified since updatedTime can have duplicate values. Limit defaults as 10 if it's not specified.
For example:
curl -i -G -X GET http://127.0.0.1:8080/newsfeeds/ -d "uid=1037529214091264" --data-urlencode "lastSeenUpdatedTime=1474522304000" -d "lastSeenId=3" -d "limit=10", equivalent to
curl -i -X GET "http://127.0.0.1:8080/newsfeeds?uid=1037529214091264&lastSeenUpdatedTime=1474522304000&lastSeenId=3&limit=10"

Example response:
[
  {
    "id": 1012998336413696,
    "question": "How do you define a good man?",
    "rate": 2,
    "updatedTime": 1491202590000,
    "answerUrl": "https://ddk9xa5p5b3lb.cloudfront.net/answers/videos/1012998336413696/1012998336413696.mp4",
    "answerCoverUrl": "https://ddk9xa5p5b3lb.cloudfront.net/answers/thumbnails/1012998336413696/1012998336413696.png",
    "answerCover": null,
    "duration": 0,
    "askerName": "Bingo Zhou",
    "askerAvatarUrl": null,
    "responderId": "813938593759232",
    "responderName": "Edmund Zhou",
    "responderTitle": "Philosopher",
    "responderAvatarUrl": null,
    "responderAvatarImage": null,
    "snoops": 1
  }
]


RESTFUL APIs OF TEMP PASSWORD:
1. request new temp password, e.g.
curl -i -X POST "http://127.0.0.1:8080/temppwds" -d '{"uname":"edmund@gmail.com"}'
Example response:
{"id":2123595681628160}

RESTFUL APIs OF RESETING PASSWORD:
1. reset password for a user, e.g.
curl -i -X POST "http://127.0.0.1:8080/resetpwd/812381424844800" -d '{"tempPwd":"^ucSE0", "newPwd":"yyyy"}'


RESTFUL APIs OF EXPIRING QUANDAs:
1. to expire quandas, e.g.
curl -i -X POST "http://127.0.0.1:8080/quandas/expire"


RESTFUL APIs TO APPLY FOR/APROVE/DENY TAKING QUESTIONs:
1. to apply for taking questions, e.g.
curl -i -X POST "http://127.0.0.1:8080/takeq" -d '{"uid":812381424844800,"takeQuestion":"APPLIED"}'
Example response:
{"uid":812381424844800}

2. to approve taking questions, e.g.
curl -i -X POST "http://127.0.0.1:8080/takeq" -d '{"uid":812381424844800,"takeQuestion":"APPROVED"}'
Example response:
{"uid":812381424844800}

3. to deny taking questions, e.g.
curl -i -X POST "http://127.0.0.1:8080/takeq" -d '{"uid":812381424844800,"takeQuestion":"DENIED"}'
Example response:
{"uid":812381424844800}


RESTFUL APIs OF BULKDATA:
1. get bulk data by uri(s)
curl -i -X GET "http://127.0.0.1:8080/bulkdata/https://s3-us-west-1.amazonaws.com/com.snoop.server.answers/8"
curl -i -G -X GET http://127.0.0.1:8080/bulkdata --data-urlencode "uri=https://s3-us-west-1.amazonaws.com/com.snoop.server.answers/8"  --data-urlencode "uri=https://s3-us-west-1.amazonaws.com/com.snoop.server.answers/7.cover"
, which are equivalent to
curl -i -G -X GET "http://127.0.0.1:8080/bulkdata?/bulkdata?uri=https://s3-us-west-1.amazonaws.com/com.snoop.server.answers/8&uri=https://s3-us-west-1.amazonaws.com/com.snoop.server.answers/7.cover"

Example response:
{"https://s3-us-west-1.amazonaws.com/com.snoop.server.answers/8":"dGhpcyBpcyBhbnN3ZXIgYXV0aWRvLg=="}
{"https://s3-us-west-1.amazonaws.com/com.snoop.server.answers/8":"dGhpcyBpcyBhbnN3ZXIgYXV0aWRvLg==","https://s3-us-west-1.amazonaws.com/com.snoop.server.answers/7.cover":"dGhpcyBpcyBhbnN3ZXIgYXV0aWRvLg=="}


RESTFUL APIs OF CATEGORY:
1. get category by id, e.g.
curl -i -X GET "http://127.0.0.1:8080/categories/983752469643264"
Example response:
{
  "id": 983752469643264,
  "name": "beauty",
  "description": "category for makeup and cosmetic.",
  "createdTime": 1491188944000,
  "updatedTime": 1491188944000
}

2. create category, e.g.
curl -i -X POST "http://127.0.0.1:8080/categories" -d '{"name":"beauty","description":"category for makeup and cosmetic."}'
Example response:
{"id":983752469643264}

3. update category, e.g.
curl -i -X PUT "http://127.0.0.1:8080/categories/983752469643264" -d '{"name":"beauty","description":"category for beauty like makeup and cosmetic."}'

4. query category, e.g.
curl -i -G -X GET http://127.0.0.1:8080/categories --data-urlencode "name='%'", equivalent to
curl -i -X GET "http://127.0.0.1:8080/categories?name='%%'"

curl -i -G -X GET http://127.0.0.1:8080/categories --data-urlencode "name='%music'", equivalent to
curl -i -G -X GET http://127.0.0.1:8080/categories --data-urlencode "name='%%music'",

curl -i -X GET "http://127.0.0.1:8080/categories?id=983752469643264"

Example response:
[
  {
    "id": 983752469643264,
    "name": "beauty",
    "description": "category for beauty like makeup and cosmetic.",
    "createdTime": 1491188944000,
    "updatedTime": 1491188944000
  },
  {
    "id": 984987897692160,
    "name": "fitness",
    "description": "category for fitness.",
    "createdTime": 1491189239000,
    "updatedTime": 1491189239000
  }
]


RESTFUL APIs OF CATMAPPING:
1. get catmapping by id
curl -i -X GET "http://127.0.0.1:8080/catmappings/1"
Example response:
{
  "id": 1,
  "catId": 5,
  "catName": "tech",
  "catDescription": "category for tech.",
  "uid": "bingo",
  "isExpertise": "YES",
  "isInterest": "NO",
  "createdTime": 1487754906000,
  "updatedTime": 1487754906000
}

2. update catmapping for user
curl -i -X PUT "http://127.0.0.1:8080/catmappings/812381424844800" -d '[{"catId":983752469643264,"isExpertise":"YES"}]'
curl -i -X PUT "http://127.0.0.1:8080/catmappings/812381424844800" -d '[{"id":999719186726912,"catId":983752469643264,"isExpertise":"NO"}]'
curl -i -X PUT "http://127.0.0.1:8080/catmappings/812381424844800" -d '[{"catId":984987897692160,"isExpertise":"YES"},{"catId":983752469643264,"isInterest":"YES"}]'
curl -i -X PUT "http://127.0.0.1:8080/catmappings/812381424844800" -d '[{"id":999719186726912,"catId":983752469643264,"isExpertise":"YES"},{"id":1003944083980288,"catId":984987897692160,"isInterest":"YES"}]'

3. Query expertise for user:
curl -i -X GET "http://127.0.0.1:8080/catmappings?uid=812381424844800&isExpertise='YES'"
Example response:
[
  {
    "id": 1003944083980288,
    "catId": 984987897692160,
    "catName": "fitness",
    "catDescription": "category for fitness.",
    "uid": 812381424844800,
    "isExpertise": "YES",
    "isInterest": "YES",
    "createdTime": 1491193758000,
    "updatedTime": 1491193758000
  }
]

4. Query interests for user:
curl -i -X GET "http://127.0.0.1:8080/catmappings?uid=812381424844800&isInterest='YES'"
Example response:
[
  {
    "id": 999719186726912,
    "catId": 983752469643264,
    "catName": "beauty",
    "catDescription": "category for beauty like makeup and cosmetic.",
    "uid": 812381424844800,
    "isExpertise": "NO",
    "isInterest": "YES",
    "createdTime": 1491192751000,
    "updatedTime": 1491192751000
  },
  {
    "id": 1003944083980288,
    "catId": 984987897692160,
    "catName": "fitness",
    "catDescription": "category for fitness.",
    "uid": 812381424844800,
    "isExpertise": "YES",
    "isInterest": "YES",
    "createdTime": 1491193758000,
    "updatedTime": 1491193758000
  }
]


RESTFUL APIs OF COIN:
1. get by user, e.g.
curl -i -X GET "http://127.0.0.1:8080/coins/812381424844800"
Example response:
{
  "id": null,
  "uid": 812381424844800,
  "amount": 0,
  "originId": null,
  "createdTime": null
}

2. buy coins, e.g.
curl -i -X POST "http://127.0.0.1:8080/coins" -d '{"uid":"812381424844800","amount":200}'
Example response:
{"id":1}


RESTFUL APIs OF PCACCOUNT:
1. get PcAccount by uid, e.g.
curl -i -X GET "http://127.0.0.1:8080/pcaccounts/813938593759232"
Example response:
{
  "uid": 813938593759232,
  "chargeFrom": "cus_AOyzQ05QJTkoLV",
  "payTo": "edmund@fight.com",
  "createdTime": 1491148458000,
  "updatedTime": 1491148458000
}

2. update PcAccount by uid, only payTo can be updated, e.g.
curl -i -X PUT "http://127.0.0.1:8080/pcaccounts/813938593759232"  -d '{"payTo":"edmund@fight.com"}'



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
1. bash run-jar.sh -Dhttp.snoop.ssl  snoop-web-server
2. bash run-jar.sh -Dhttp.snoop.ssl -Dresource.uri=users/edmund snoop-web-client

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
server/src/main/resources/com/snoop/server/scripts/schema.sql



HOW TO FILE BUGS?
go to https://gibbon.atlassian.net



WHERE TO DOWNLOAD SOURCE CODE?
go to https://github.com/newgibbon

