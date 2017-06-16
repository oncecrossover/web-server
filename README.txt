WHAT IS IT?
Snoop is a novel social Q&A community, where people pay to get video answers from celebrities they love most to ask questions for. Three major features:
1. People pay to ask celebrities questions by text.
2. Celebrities get paid for answering questions by video.
3. Snoopers pay to unlock others' answers.



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

Defaults: http.snoop.ssl and http.snoop.server.live default false

Example: run-jar.sh  snoop-web-server
         run-jar.sh -Dhttp.snoop.server.port=8080 snoop-web-server
         run-jar.sh -Dhttp.snoop.server.port=8443 -Dhttp.snoop.ssl snoop-web-server
         run-jar.sh -Dhttp.snoop.server.port=8443 -Dhttp.snoop.ssl -Dhttp.snoop.server.live snoop-web-server
         run-jar.sh -Dhttp.snoop.server.host=127.0.0.1 -Dhttp.snoop.server.port=8443 -Dhttp.snoop.ssl -Dresource.uri=users/123 snoop-web-client

Available services:

  snoop-web-client        snoop-web-server

Specifically, "./run-jar.sh snoop-web-server" to start snoop server, and
"nohup ./run-jar.sh snoop-web-server &" will run snoop server as long running independent daemon.

./run-jar.sh will also compile/package any changes you made to the code base.



PUBLIC KEY OF PAYMENT SERVICE:
pk_test_wyZIIuEmr4TQLHVnZHUxlTtm



WHAT RESTFUL APIs AVAILABLE?
RESTFUL APIs OF USERS:
1. get user by id, e.g.
curl -i -X GET "http://127.0.0.1:8080/users/16072271319793664"
Example response:
{
  "id": 16072271319793664,
  "uname": "edmund@fight.com",
  "pwd": null,
  "primaryEmail": "edmund@fight.com",
  "createdTime": 1494786328000,
  "updatedTime": 1494786328000,
  "fullName": null,
  "profile": null,
  "pcAccount": null
}

2. create new user, e.g.
curl -i -X POST "http://127.0.0.1:8080/users" -d '{"uname":"edmund@fight.com","primaryEmail":"edmund@fight.com","fullName":"Edmund Zhou","pwd":"123"}'
Example response:
{"id": 16072271319793664}

3. Query users by id, uname and so on, e.g.
curl -i -G -X GET http://127.0.0.1:8080/users --data-urlencode "id=16072271319793664", equivalent to
curl -i -X GET "http://127.0.0.1:8080/users/16072271319793664"
Example response:
[
  {
    "id": 16072271319793664,
    "uname": "edmund@fight.com",
    "pwd": null,
    "primaryEmail": "edmund@fight.com",
    "createdTime": 1494786328000,
    "updatedTime": 1494786328000,
    "fullName": null,
    "profile": null,
    "pcAccount": null
  }
]

curl -i -G -X GET http://127.0.0.1:8080/users --data-urlencode "uname='bingo@snoopqa.com'", equivalent to
curl -i -X GET "http://127.0.0.1:8080/users?uname='bingo@snoopqa.com'"
Example resposne:
[
  {
    "id": 16077851778351104,
    "uname": "bingo@snoopqa.com",
    "pwd": null,
    "primaryEmail": "bingo@snoopqa.com",
    "createdTime": 1494787658000,
    "updatedTime": 1494787658000,
    "fullName": null,
    "profile": null,
    "pcAccount": null
  }
]


4. paginate users, e.g.
Both lastSeenUpdatedTime and lastSeenId must be specified since updatedTime can have duplicate values.
Limit defaults as 10 if it's not specified.

Query based on the last seen, e.g.
curl -i -G -X GET http://127.0.0.1:8080/users --data-urlencode "uname='%o%'" --data-urlencode "lastSeenUpdatedTime=16077851778351104" -d "lastSeenId=16077851778351104" -d "limit=20", equivalent to
curl -i -X GET "http://127.0.0.1:8080/users?uname='%%o%%'&lastSeenUpdatedTime=16077851778351104&lastSeenId=16077851778351104&limit=20"
Example response:
[
  {
    "id": 16077851778351104,
    "uname": "bingo@snoopqa.com",
    "pwd": null,
    "primaryEmail": "bingo@snoopqa.com",
    "createdTime": 1494787658000,
    "updatedTime": 1494787658000,
    "fullName": null,
    "profile": null,
    "pcAccount": null
  },
  {
    "id": 16072271319793664,
    "uname": "edmund@fight.com",
    "pwd": null,
    "primaryEmail": "edmund@fight.com",
    "createdTime": 1494786328000,
    "updatedTime": 1494786328000,
    "fullName": null,
    "profile": null,
    "pcAccount": null
  }
]


RESTFUL APIs OF SIGNIN:
1. sign-in by user name and password, e.g.
curl -i -X POST "http://127.0.0.1:8080/signin" -d '{"uname":"edmund@fight.com","pwd":"123"}'
Example response:
{"id":16072271319793664}


RESTFUL APIs OF PROFILES:
1. get profile by id, e.g.
curl -i -X GET "http://127.0.0.1:8080/profiles/16072271319793664"
Example response:
{
  "id": 16072271319793664,
  "rate": 0,
  "avatarUrl": null,
  "avatarImage": null,
  "fullName": "Edmund Zhou",
  "title": null,
  "aboutMe": null,
  "takeQuestion": "NA",
  "deviceToken": null,
  "createdTime": 1494786328000,
  "updatedTime": 1494787600000
}

curl -i -G -X GET http://127.0.0.1:8080/profiles --data-urlencode "id=16072271319793664", equivalent to
curl -i -X GET "http://127.0.0.1:8080/profiles/16072271319793664"
Example respones:
[
  {
    "id": 16072271319793664,
    "rate": 0,
    "avatarUrl": null,
    "avatarImage": null,
    "fullName": "Edmund Zhou",
    "title": null,
    "aboutMe": null,
    "takeQuestion": "NA",
    "deviceToken": null,
    "createdTime": null,
    "updatedTime": 1494787600000
  }
]

2. get profile by name. It's always doing SQL LIKE style query.
For example, fullName LIKE 'edmund burke':
curl -i -G -X GET http://127.0.0.1:8080/profiles --data-urlencode "fullName='Edmund Zhou'", equivalent to
curl -i -X GET "http://127.0.0.1:8080/profiles?fullName='edmund burke'"

For example, fullName LIKE '%edmund%':
curl -i -G -X GET http://127.0.0.1:8080/profiles --data-urlencode "fullName='%edmund%'", equivalent to
curl -i -X GET "http://127.0.0.1:8080/profiles?fullName='%edmund%'"

Example respones:
[
  {
    "id": 16072271319793664,
    "rate": 0,
    "avatarUrl": null,
    "avatarImage": null,
    "fullName": "Edmund Zhou",
    "title": null,
    "aboutMe": null,
    "takeQuestion": "NA",
    "deviceToken": null,
    "createdTime": null,
    "updatedTime": 1494787600000
  }
]

3. update profile by id, e.g.
curl -i -X PUT "http://127.0.0.1:8080/profiles/16072271319793664" -d '{"rate":10,"title":"Philosopher","aboutMe":"I was an Irish political philosopher, Whig politician and statesman who is often regarded as the father of modern conservatism."}'

4. paginate profiles.
Both lastSeenUpdatedTime and lastSeenId must be specified since updatedTime can have duplicate values.
Limit defaults as 10 if it's not specified.

Query all, limit must be specified, e.g.
curl -i -G -X GET http://127.0.0.1:8080/profiles -d "limit=20", equivalent to
curl -i -X GET "http://127.0.0.1:8080/profiles?limit=20"
Example response:
[
  {
    "id": 16077851778351104,
    "rate": 0,
    "avatarUrl": null,
    "avatarImage": null,
    "fullName": "Bingo Zhou",
    "title": null,
    "aboutMe": null,
    "takeQuestion": "NA",
    "deviceToken": null,
    "createdTime": null,
    "updatedTime": 1494787658000
  },
  {
    "id": 16072271319793664,
    "rate": 10,
    "avatarUrl": null,
    "avatarImage": null,
    "fullName": "Edmund Zhou",
    "title": "Philosopher",
    "aboutMe": "I was an Irish political philosopher, Whig politician and statesman who is often regarded as the father of modern conservatism.",
    "takeQuestion": "NA",
    "deviceToken": null,
    "createdTime": null,
    "updatedTime": 1494787600000
  }
]

Query based on the last seen, e.g.
curl -i -G -X GET http://127.0.0.1:8080/profiles --data-urlencode "takeQuestion='APPROVED'" --data-urlencode "fullName='%zh%'" --data-urlencode "lastSeenUpdatedTime=1494787600000" -d "lastSeenId=16077851778351104" -d "limit=20", equivalent to
curl -i -X GET "http://127.0.0.1:8080/profiles?takeQuestion='APPROVED'&fullName='%zh%'&lastSeenUpdatedTime=1491148086000&lastSeenId=812381424844800&limit=20"
Example response:
[
  {
    "id": 16072271319793664,
    "rate": 10,
    "avatarUrl": null,
    "avatarImage": null,
    "fullName": "Edmund Zhou",
    "title": "Philosopher",
    "aboutMe": "I was an Irish political philosopher, Whig politician and statesman who is often regarded as the father of modern conservatism.",
    "takeQuestion": "NA",
    "deviceToken": null,
    "createdTime": null,
    "updatedTime": 1494787600000
  }
]


RESTFUL APIs OF QUANDAS:
1. get quanda by id, e.g.
curl -i -X GET "http://127.0.0.1:8080/quandas/16086168076550144"
Example response:
{
  "id": 16086168076550144,
  "asker": 16077851778351104,
  "question": "How do you define a good man?",
  "responder": 16072271319793664,
  "rate": 10,
  "answerUrl": "https://ddk9xa5p5b3lb.cloudfront.net/test/answers/videos/16086168076550144/16086168076550144.video.mp4",
  "answerCoverUrl": "https://ddk9xa5p5b3lb.cloudfront.net/test/answers/thumbnails/16086168076550144/16086168076550144.thumbnail.png",
  "answerMedia": null,
  "answerCover": null,
  "duration": 0,
  "status": "ANSWERED",
  "active": "TRUE",
  "createdTime": 1494789641000,
  "updatedTime": 1494789641000,
  "snoops": null,
  "hoursToExpire": 48
}

2. answer question by id, e.g.
curl -i -X PUT "http://127.0.0.1:8080/quandas/1012998336413696" -d '{"answerMedia":"dGhpcyBpcyBhbnN3ZXIgYXV0aWRvLg==","answerCover":"dGhpcyBpcyBhbnN3ZXIgYXV0aWRvLg==","status":"ANSWERED"}'

3. deactivate quanda by id, e.g.
curl -i -X PUT "http://127.0.0.1:8080/quandas/1012998336413696" -d '{"active":"FALSE"}'


RESTFUL APIs OF QUESTIONS:
1. query questions, e.g.
curl -i -G -X GET http://127.0.0.1:8080/questions --data-urlencode "asker=16077851778351104", equivalent to
curl -i -X GET "http://127.0.0.1:8080/questions?asker=16077851778351104"
Example response:
[
  {
    "id": 16086638018953216,
    "question": "What is your opinion on the future of human beings?",
    "rate": 10,
    "status": "ANSWERED",
    "createdTime": 1494789753000,
    "updatedTime": 1494790051000,
    "answerUrl": "https://ddk9xa5p5b3lb.cloudfront.net/test/answers/videos/16086638018953216/16086638018953216.video.mp4",
    "answerCoverUrl": "https://ddk9xa5p5b3lb.cloudfront.net/test/answers/thumbnails/16086638018953216/16086638018953216.thumbnail.png",
    "answerCover": null,
    "duration": 0,
    "hoursToExpire": 47,
    "responderName": "Edmund Zhou",
    "responderTitle": "Philosopher",
    "responderAvatarUrl": null,
    "responderAvatarImage": null,
    "askerName": "Bingo Zhou",
    "askerAvatarUrl": null,
    "askerAvatarImage": null
  },
  {
    "id": 16086307713318912,
    "question": "How do you define a bad man?",
    "rate": 10,
    "status": "ANSWERED",
    "createdTime": 1494789674000,
    "updatedTime": 1494789674000,
    "answerUrl": "https://ddk9xa5p5b3lb.cloudfront.net/test/answers/videos/16086307713318912/16086307713318912.video.mp4",
    "answerCoverUrl": "https://ddk9xa5p5b3lb.cloudfront.net/test/answers/thumbnails/16086307713318912/16086307713318912.thumbnail.png",
    "answerCover": null,
    "duration": 0,
    "hoursToExpire": 47,
    "responderName": "Edmund Zhou",
    "responderTitle": "Philosopher",
    "responderAvatarUrl": null,
    "responderAvatarImage": null,
    "askerName": "Bingo Zhou",
    "askerAvatarUrl": null,
    "askerAvatarImage": null
  }
]

2. paginate questions.
Both lastSeenUpdatedTime and lastSeenId must be specified since updatedTime can have duplicate values. Limit defaults as 10 if it's not specified.
For example:
curl -i -G -X GET http://127.0.0.1:8080/questions -d "asker=16077851778351104" --data-urlencode "lastSeenUpdatedTime=1494789674000" -d "lastSeenId=16086307713318912" -d "limit=20", equivalent to
curl -i -X GET "http://127.0.0.1:8080/questions?asker=16077851778351104&lastSeenUpdatedTime=1494789674000&lastSeenId=16086307713318912&limit=20"
Example response:
[
  {
    "id": 16086168076550144,
    "question": "How do you define a good man?",
    "rate": 10,
    "status": "ANSWERED",
    "createdTime": 1494789641000,
    "updatedTime": 1494789641000,
    "answerUrl": "https://ddk9xa5p5b3lb.cloudfront.net/test/answers/videos/16086168076550144/16086168076550144.video.mp4",
    "answerCoverUrl": "https://ddk9xa5p5b3lb.cloudfront.net/test/answers/thumbnails/16086168076550144/16086168076550144.thumbnail.png",
    "answerCover": null,
    "duration": 0,
    "hoursToExpire": 47,
    "responderName": "Edmund Zhou",
    "responderTitle": "Philosopher",
    "responderAvatarUrl": null,
    "responderAvatarImage": null,
    "askerName": "Bingo Zhou",
    "askerAvatarUrl": null,
    "askerAvatarImage": null
  }
]


RESTFUL APIs OF ANSWERS:
1. query answers by other criteria, e.g.
curl -i -G -X GET http://127.0.0.1:8080/answers/ --data-urlencode "responder=16072271319793664", equivalent to
curl -i -X GET "http://127.0.0.1:8080/answers?responder=16072271319793664"
Example response:
[
  {
    "id": 16086638018953216,
    "question": "What is your opinion on the future of human beings?",
    "rate": 10,
    "status": "ANSWERED",
    "createdTime": 1494789753000,
    "updatedTime": 1494789753000,
    "answerUrl": "https://ddk9xa5p5b3lb.cloudfront.net/test/answers/videos/16086638018953216/16086638018953216.video.mp4",
    "answerCoverUrl": "https://ddk9xa5p5b3lb.cloudfront.net/test/answers/thumbnails/16086638018953216/16086638018953216.thumbnail.png",
    "answerCover": null,
    "duration": 0,
    "responderName": "Edmund Zhou",
    "responderTitle": "Philosopher",
    "responderAvatarUrl": null,
    "responderAvatarImage": null,
    "askerName": "Bingo Zhou",
    "askerAvatarUrl": null,
    "askerAvatarImage": null,
    "hoursToExpire": 47
  },
  {
    "id": 16086307713318912,
    "question": "How do you define a bad man?",
    "rate": 10,
    "status": "ANSWERED",
    "createdTime": 1494789674000,
    "updatedTime": 1494789753000,
    "answerUrl": "https://ddk9xa5p5b3lb.cloudfront.net/test/answers/videos/16086307713318912/16086307713318912.video.mp4",
    "answerCoverUrl": "https://ddk9xa5p5b3lb.cloudfront.net/test/answers/thumbnails/16086307713318912/16086307713318912.thumbnail.png",
    "answerCover": null,
    "duration": 0,
    "responderName": "Edmund Zhou",
    "responderTitle": "Philosopher",
    "responderAvatarUrl": null,
    "responderAvatarImage": null,
    "askerName": "Bingo Zhou",
    "askerAvatarUrl": null,
    "askerAvatarImage": null,
    "hoursToExpire": 47
  },
  {
    "id": 16086168076550144,
    "question": "How do you define a good man?",
    "rate": 10,
    "status": "ANSWERED",
    "createdTime": 1494789641000,
    "updatedTime": 1494789753000,
    "answerUrl": "https://ddk9xa5p5b3lb.cloudfront.net/test/answers/videos/16086168076550144/16086168076550144.video.mp4",
    "answerCoverUrl": "https://ddk9xa5p5b3lb.cloudfront.net/test/answers/thumbnails/16086168076550144/16086168076550144.thumbnail.png",
    "answerCover": null,
    "duration": 0,
    "responderName": "Edmund Zhou",
    "responderTitle": "Philosopher",
    "responderAvatarUrl": null,
    "responderAvatarImage": null,
    "askerName": "Bingo Zhou",
    "askerAvatarUrl": null,
    "askerAvatarImage": null,
    "hoursToExpire": 47
  }
]

2. paginate answers.
Both lastSeenCreatedTime and lastSeenId must be specified since createdTime can have duplicate values. Limit defaults as 10 if it's not specified.
For example:
curl -i -G -X GET http://127.0.0.1:8080/answers/ -d "responder=16072271319793664" --data-urlencode "lastSeenCreatedTime=1494789674000" -d "lastSeenId=16086307713318912" -d "limit=20", equivalent to
curl -i -X GET "http://127.0.0.1:8080/answers?responder=16072271319793664&lastSeenCreatedTime=1494789674000&lastSeenId=16086307713318912&limit=20"
Example response:
[
  {
    "id": 16086168076550144,
    "question": "How do you define a good man?",
    "rate": 10,
    "status": "ANSWERED",
    "createdTime": 1494789641000,
    "updatedTime": 1494789753000,
    "answerUrl": "https://ddk9xa5p5b3lb.cloudfront.net/test/answers/videos/16086168076550144/16086168076550144.video.mp4",
    "answerCoverUrl": "https://ddk9xa5p5b3lb.cloudfront.net/test/answers/thumbnails/16086168076550144/16086168076550144.thumbnail.png",
    "answerCover": null,
    "duration": 0,
    "responderName": "Edmund Zhou",
    "responderTitle": "Philosopher",
    "responderAvatarUrl": null,
    "responderAvatarImage": null,
    "askerName": "Bingo Zhou",
    "askerAvatarUrl": null,
    "askerAvatarImage": null,
    "hoursToExpire": 47
  }
]


RESTFUL APIs OF SNOOPS:
1. query snoops, e.g.
curl -i -G -X GET http://127.0.0.1:8080/snoops --data-urlencode "uid=16084904089485312", equivalent to
curl -i -X GET "http://127.0.0.1:8080/snoops?uid=16084904089485312"
Example response:
[
  {
    "id": 16115662829125632,
    "uid": null,
    "quandaId": 16086307713318912,
    "createdTime": 1494796673000,
    "question": "How do you define a bad man?",
    "status": "ANSWERED",
    "rate": 10,
    "answerUrl": "https://ddk9xa5p5b3lb.cloudfront.net/test/answers/videos/16086307713318912/16086307713318912.video.mp4",
    "answerCoverUrl": "https://ddk9xa5p5b3lb.cloudfront.net/test/answers/thumbnails/16086307713318912/16086307713318912.thumbnail.png",
    "answerCover": null,
    "duration": 0,
    "isAskerAnonymous": "FALSE"
    "responderName": "Edmund Zhou",
    "responderTitle": "Philosopher",
    "responderAvatarUrl": null,
    "responderAvatarImage": null,
    "askerName": "Bingo Zhou",
    "askerAvatarUrl": null,
    "askerAvatarImage": null
  },
  {
    "id": 16115631308931072,
    "uid": null,
    "quandaId": 16086168076550144,
    "createdTime": 1494796665000,
    "question": "How do you define a good man?",
    "status": "ANSWERED",
    "rate": 10,
    "answerUrl": "https://ddk9xa5p5b3lb.cloudfront.net/test/answers/videos/16086168076550144/16086168076550144.video.mp4",
    "answerCoverUrl": "https://ddk9xa5p5b3lb.cloudfront.net/test/answers/thumbnails/16086168076550144/16086168076550144.thumbnail.png",
    "answerCover": null,
    "duration": 0,
    "isAskerAnonymous": "FALSE"
    "responderName": "Edmund Zhou",
    "responderTitle": "Philosopher",
    "responderAvatarUrl": null,
    "responderAvatarImage": null,
    "askerName": "Bingo Zhou",
    "askerAvatarUrl": null,
    "askerAvatarImage": null
  }
]

2. paginate snoops.
Both lastSeenCreatedTime and lastSeenId must be specified since createdTime can have duplicate values. Limit defaults as 10 if it's not specified.
For example:
curl -i -G -X GET http://127.0.0.1:8080/snoops -d "uid=16084904089485312" --data-urlencode "lastSeenCreatedTime=1494796673000" -d "lastSeenId=16115662829125632" -d "limit=20", equivalent to
curl -i -X GET "http://127.0.0.1:8080/snoops?uid=16084904089485312&lastSeenCreatedTime=1494796673000&lastSeenId=16115662829125632&limit=20"
Example response:
[
  {
    "id": 16115631308931072,
    "uid": null,
    "quandaId": 16086168076550144,
    "createdTime": 1494796665000,
    "question": "How do you define a good man?",
    "status": "ANSWERED",
    "rate": 10,
    "answerUrl": "https://ddk9xa5p5b3lb.cloudfront.net/test/answers/videos/16086168076550144/16086168076550144.video.mp4",
    "answerCoverUrl": "https://ddk9xa5p5b3lb.cloudfront.net/test/answers/thumbnails/16086168076550144/16086168076550144.thumbnail.png",
    "answerCover": null,
    "duration": 0,
    "isAskerAnonymous": "FALSE"
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
curl -i -X GET "http://127.0.0.1:8080/balances/16077851778351104"
Example response:
{
  "uid": 16077851778351104,
  "balance": 0.2
}

RESTFUL APIs OF QATRANSACTION:
1. get QaTransaction by id, e.g.
Example response:
curl -i -X GET "http://127.0.0.1:8080/qatransactions/16086168080744448"
{
  "id": 16086168080744448,
  "uid": 16077851778351104,
  "type": "ASKED",
  "quandaId": 16086168076550144,
  "amount": 10,
  "createdTime": 1494789641000,
  "quanda": null
}

2. create new QaTransaction with type of ASKED, e.g.
To ask a question using real name, curl -i -X POST "http://127.0.0.1:8080/qatransactions" -d '{"uid":812381424844800,"type":"ASKED","quanda":{"question":"How do you define a good man?","responder":813938593759232}}'
To ask a question anonymously,     curl -i -X POST "http://127.0.0.1:8080/qatransactions" -d '{"uid":812381424844800,"type":"ASKED","quanda":{"question":"How do you define a bad man?","responder":813938593759232,"isAskerAnonymous":"TRUE"}}'
Example response:
{"id":16086168080744448}

create new QaTransaction with type of SNOOPED, e.g.
curl -i -X POST "http://127.0.0.1:8080/qatransactions" -d '{"uid":"813562284998656","type":"SNOOPED","quanda":{"id":1012998336413696}}'
Example response:
{"id":16115662833319936}

RESTFUL APIs OF NEWSFEED:
1. query newsfeed, e.g.
curl -i -G -X GET http://127.0.0.1:8080/newsfeeds/ --data-urlencode "uid=16084904089485312", equivalent to
curl -i -X GET "http://127.0.0.1:8080/newsfeeds?uid=16084904089485312"
Example response:
[
  {
    "id": 16123341584728064,
    "question": "How can I become an entrepreneaur?",
    "rate": 0,
    "updatedTime": 1494798504000,
    "answerUrl": "https://ddk9xa5p5b3lb.cloudfront.net/test/answers/videos/16123341584728064/16123341584728064.video.mp4",
    "answerCoverUrl": "https://ddk9xa5p5b3lb.cloudfront.net/test/answers/thumbnails/16123341584728064/16123341584728064.thumbnail.png",
    "answerCover": null,
    "duration": 0,
    "isAskerAnonymous": "FALSE"
    "askerName": "Edgar Zhou",
    "askerAvatarUrl": null,
    "responderId": 16077851778351104,
    "responderName": "Bingo Zhou",
    "responderTitle": null,
    "responderAvatarUrl": null,
    "responderAvatarImage": null,
    "snoops": 0
  },
  {
    "id": 16086638018953216,
    "question": "What is your opinion on the future of human beings?",
    "rate": 10,
    "updatedTime": 1494790051000,
    "answerUrl": "https://ddk9xa5p5b3lb.cloudfront.net/test/answers/videos/16086638018953216/16086638018953216.video.mp4",
    "answerCoverUrl": "https://ddk9xa5p5b3lb.cloudfront.net/test/answers/thumbnails/16086638018953216/16086638018953216.thumbnail.png",
    "answerCover": null,
    "duration": 0,
    "isAskerAnonymous": "FALSE"
    "askerName": "Bingo Zhou",
    "askerAvatarUrl": null,
    "responderId": 16072271319793664,
    "responderName": "Edmund Zhou",
    "responderTitle": "Philosopher",
    "responderAvatarUrl": null,
    "responderAvatarImage": null,
    "snoops": 1
  }
]

2. paginate newsfeed.
Both lastSeenUpdatedTime and lastSeenId must be specified since updatedTime can have duplicate values. Limit defaults as 10 if it's not specified.
For example:
curl -i -G -X GET http://127.0.0.1:8080/newsfeeds/ -d "uid=16084904089485312" --data-urlencode "lastSeenUpdatedTime=1494798504000" -d "lastSeenId=16123341584728064" -d "limit=10", equivalent to
curl -i -X GET "http://127.0.0.1:8080/newsfeeds?uid=16084904089485312&lastSeenUpdatedTime=1494798504000&lastSeenId=16123341584728064&limit=10"
Example response:
[
  {
    "id": 16086638018953216,
    "question": "What is your opinion on the future of human beings?",
    "rate": 10,
    "updatedTime": 1494790051000,
    "answerUrl": "https://ddk9xa5p5b3lb.cloudfront.net/test/answers/videos/16086638018953216/16086638018953216.video.mp4",
    "answerCoverUrl": "https://ddk9xa5p5b3lb.cloudfront.net/test/answers/thumbnails/16086638018953216/16086638018953216.thumbnail.png",
    "answerCover": null,
    "duration": 0,
    "isAskerAnonymous": "FALSE"
    "askerName": "Bingo Zhou",
    "askerAvatarUrl": null,
    "responderId": 16072271319793664,
    "responderName": "Edmund Zhou",
    "responderTitle": "Philosopher",
    "responderAvatarUrl": null,
    "responderAvatarImage": null,
    "snoops": 1
  }
]


RESTFUL APIs OF TEMP PASSWORD:
1. request new temp password, e.g.
curl -i -X POST "http://127.0.0.1:8080/temppwds" -d '{"uname":"edmund@fight.com"}'
Example response:
{"id":2123595681628160}

RESTFUL APIs OF RESETING PASSWORD:
1. reset password for a user, e.g.
curl -i -X POST "http://127.0.0.1:8080/resetpwd/16072271319793664" -d '{"tempPwd":"NFAL)t", "newPwd":"1234"}'


RESTFUL APIs OF EXPIRING QUANDAs:
1. to expire quandas, e.g.
curl -i -X POST "http://127.0.0.1:8080/quandas/expire"


RESTFUL APIs TO APPLY FOR/APROVE/DENY TAKING QUESTIONs:
1. to apply for taking questions, e.g.
curl -i -X POST "http://127.0.0.1:8080/takeq" -d '{"uid":16072271319793664,"takeQuestion":"APPLIED"}'
Example response:
{"uid":16072271319793664}

2. to approve taking questions, e.g.
curl -i -X POST "http://127.0.0.1:8080/takeq" -d '{"uid":16072271319793664,"takeQuestion":"APPROVED"}'
Example response:
{"uid":16072271319793664}

3. to deny taking questions, e.g.
curl -i -X POST "http://127.0.0.1:8080/takeq" -d '{"uid":16072271319793664,"takeQuestion":"DENIED"}'
Example response:
{"uid":16072271319793664}


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
curl -i -X GET "http://127.0.0.1:8080/categories/16136794785447936"
Example response:
{
  "id": 19833904793911296,
  "name": "fashion",
  "description": "category for fashion.",
  "resourceUrl": "https://ddk9xa5p5b3lb.cloudfront.net/resources/categories/fashion.pdf",
  "createdTime": 1495683171000,
  "updatedTime": 1495683171000
}

2. create category, e.g.
curl -i -X POST "http://127.0.0.1:8080/categories" -d '{"name":"beauty","description":"category for makeup and cosmetic."}'
Example response:
{"id":16136794785447936}

3. update category, e.g.
curl -i -X PUT "http://127.0.0.1:8080/categories/16136794785447936" -d '{"name":"beauty","description":"category for beauty like makeup and cosmetic."}'
curl -i -X PUT "http://127.0.0.1:8080/categories/19833904793911296" -d '{"resourceUrl":"https://ddk9xa5p5b3lb.cloudfront.net/resources/categories/fashion.pdf"}'

4. query category, e.g.
curl -i -G -X GET http://127.0.0.1:8080/categories --data-urlencode "name='%'", equivalent to
curl -i -X GET "http://127.0.0.1:8080/categories?name='%%'"

curl -i -G -X GET http://127.0.0.1:8080/categories --data-urlencode "name='%fitness'", equivalent to
curl -i -G -X GET http://127.0.0.1:8080/categories --data-urlencode "name='%%fitness'",

curl -i -X GET "http://127.0.0.1:8080/categories?id=16136794785447936"

Example response:
[
  {
    "id": 16136794785447936,
    "name": "beauty",
    "description": "category for beauty like makeup and cosmetic.",
    "resourceUrl": null,
    "createdTime": 1494801711000,
    "updatedTime": 1494801711000
  },
  {
    "id": 16137425126424576,
    "name": "fitness",
    "description": "category for fitness.",
    "resourceUrl": null,
    "createdTime": 1494801861000,
    "updatedTime": 1494801861000
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
curl -i -X PUT "http://127.0.0.1:8080/catmappings/16077851778351104" -d '[{"catId":16136794785447936,"isExpertise":"YES"}]'
curl -i -X PUT "http://127.0.0.1:8080/catmappings/16077851778351104" -d '[{"id":16137970344001536,"catId":16136794785447936,"isExpertise":"NO"}]'
curl -i -X PUT "http://127.0.0.1:8080/catmappings/16077851778351104" -d '[{"catId":16136794785447936,"isExpertise":"YES"},{"catId":16137471796445184,"isInterest":"YES"}]'
curl -i -X PUT "http://127.0.0.1:8080/catmappings/16077851778351104" -d '[{"id":16137970344001536,"catId":16136794785447936,"isExpertise":"YES"},{"id":16139344083419136,"catId":16137471796445184,"isInterest":"YES"}]'

3. Query expertise for user:
curl -i -X GET "http://127.0.0.1:8080/catmappings?uid=16077851778351104&isExpertise='YES'"
Example response:
[
  {
    "id": 16137970344001536,
    "catId": 16136794785447936,
    "catName": "beauty",
    "catDescription": "category for beauty like makeup and cosmetic.",
    "uid": 16077851778351104,
    "isExpertise": "YES",
    "isInterest": "NO",
    "createdTime": 1494801991000,
    "updatedTime": 1494801991000
  }
]

4. Query interests for user:
curl -i -X GET "http://127.0.0.1:8080/catmappings?uid=16077851778351104&isInterest='YES'"
Example response:
[
  {
    "id": 16139344083419136,
    "catId": 16137471796445184,
    "catName": "outdoors",
    "catDescription": "category for outdoors.",
    "uid": 16077851778351104,
    "isExpertise": "NO",
    "isInterest": "YES",
    "createdTime": 1494802319000,
    "updatedTime": 1494802319000
  }
]


RESTFUL APIs OF COIN:
1. get by user, e.g.
curl -i -X GET "http://127.0.0.1:8080/coins/16077851778351104"
Example response:
{
  "id": null,
  "uid": 16077851778351104,
  "amount": 250,
  "originId": null,
  "createdTime": null
}

2. buy coins, e.g.
curl -i -X POST "http://127.0.0.1:8080/coins" -d '{"uid":"16077851778351104","amount":200}'
Example response:
{"id":16140291354394624}


RESTFUL APIs OF PCACCOUNT:
1. get PcAccount by uid, e.g.
curl -i -X GET "http://127.0.0.1:8080/pcaccounts/16077851778351104"
Example response:
{
  "id": 16077851778351104,
  "chargeFrom": "cus_AelH78AE4I3F9S",
  "payTo": null,
  "createdTime": 1494787658000,
  "updatedTime": 1494787658000
}

2. update PcAccount by uid, only payTo can be updated, e.g.
curl -i -X PUT "http://127.0.0.1:8080/pcaccounts/16077851778351104"  -d '{"payTo":"xzhou40@fight.com"}'


RESTFUL APIs OF CONFIGURATION:
1. get configuration by id, e.g.
curl -i -X GET "http://127.0.0.1:8080/configurations/16140668300689408"
Example response:
{
  "id": 16140668300689408,
  "ckey": "com.snoop.app.welcome.video.url",
  "value": "xxx",
  "defaultValue": "yyy",
  "description": "url for welcome video",
  "createdTime": 1494802635000,
  "updatedTime": 1494802635000
}

2. create a configuration, e.g.
curl -i -X POST "http://127.0.0.1:8080/configurations" -d '{"ckey":"com.snoop.app.welcome.video.url","value":"xxx","defaultValue":"yyy","description":"url for welcome video"}'
Example response:
{"id":16140668300689408}

3. update a configuration, e.g.
curl -i -X PUT "http://127.0.0.1:8080/configurations/16140668300689408" -d '{"ckey":"com.snoop.app.welcome.video.url","value":"zzz"}'

4. query configurations, e.g.
curl -i -X GET "http://127.0.0.1:8080/configurations?id=16140668300689408"
curl -i -X GET "http://127.0.0.1:8080/configurations?ckey='com.snoop.app.welcome.video.url'"
[
  {
    "id": 16140668300689408,
    "ckey": "com.snoop.app.welcome.video.url",
    "value": "zzz",
    "defaultValue": "yyy",
    "description": "url for welcome video",
    "createdTime": 1494802635000,
    "updatedTime": 1494802635000
  }
]



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

snoop-truststore-1.0.jceks          client/server truststore
snoop-client-keystore-1.0.jceks     client-side keystore
snoop-server-keystore-1.0.jceks     server-side keystore



HOW TO FIND DB SCHEMA?
server/src/main/resources/com/snoop/server/scripts/schema.sql



HOW TO FILE BUGS?
go to https://gibbon.atlassian.net



WHERE TO DOWNLOAD SOURCE CODE?
go to https://github.com/newgibbon



HOW TO COMPILE?
1. compile frontend through xcode, before that you must do:
$ sudo gem install cocoapods
$ pod install

2. compile backend
$ mvn clean package, or
$ mvn clean package -DskipTests