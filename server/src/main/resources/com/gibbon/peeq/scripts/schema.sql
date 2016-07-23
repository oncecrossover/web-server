CREATE TABLE `User` (
  `uid` varchar(200) NOT NULL,
  `firstName` varchar(100) DEFAULT NULL,
  `middleName` varchar(100) DEFAULT NULL,
  `lastName` varchar(100) DEFAULT NULL,
  `pwd` varchar(100) NOT NULL,
  `createdTime` datetime DEFAULT NULL,
  `updatedTime` datetime DEFAULT NULL,
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Profile` (
  `uid` varchar(200) NOT NULL,
  `avatarUrl` varchar(1000) DEFAULT NULL,
  `fullName` varchar(500) DEFAULT NULL,
  `title` varchar(1000) DEFAULT NULL,
  `aboutMe` varchar(2000) DEFAULT NULL,
  PRIMARY KEY (`uid`),
  FOREIGN KEY fk_user(uid) REFERENCES User(uid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Quanda` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `asker` varchar(100) NOT NULL,
  `question` varchar(2000) NOT NULL,
  `responder` varchar(100) NOT NULL,
  `answerUrl` varchar(1000) DEFAULT NULL,
  `status` ENUM('PENDING', 'ANSWERED', 'EXPIRED') NOT NULL DEFAULT 'PENDING',
  `createdTime` datetime NOT NULL,
  `updatedTime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY fk_asker(asker) REFERENCES User(uid),
  FOREIGN KEY fk_responder(responder) REFERENCES User(uid)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE `Snoop` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uid` varchar(200) NOT NULL,
  `quandaId` bigint NOT NULL,
  `createdTime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY fk_user(uid) REFERENCES User(uid),
  FOREIGN KEY fk_quanda(quandaId) REFERENCES Quanda(id)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE `Payment` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uid` varchar(200) NOT NULL,
  `accId` varchar(200) NOT NULL,
  `type` ENUM('CARD', 'CHECKING') NOT NULL,
  `lastFour` varchar(10) NOT NULL,
  `createdTime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY(uid, accId),
  FOREIGN KEY fk_user(uid) REFERENCES User(uid)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE `Balance` (
  `uid` varchar(200) NOT NULL,
  `val` bigint DEFAULT 0,
  PRIMARY KEY (`uid`),
  FOREIGN KEY fk_user(uid) REFERENCES User(uid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
