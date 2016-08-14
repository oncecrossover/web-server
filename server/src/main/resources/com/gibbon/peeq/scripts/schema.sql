CREATE TABLE `User` (
  `uid` NVARCHAR(200) NOT NULL,
  `firstName` NVARCHAR(100) DEFAULT NULL,
  `middleName` NVARCHAR(100) DEFAULT NULL,
  `lastName` NVARCHAR(100) DEFAULT NULL,
  `pwd` NVARCHAR(100) NOT NULL,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Profile` (
  `uid` NVARCHAR(200) NOT NULL,
  `rate` DOUBLE UNSIGNED NOT NULL,
  `avatarUrl` NVARCHAR(1000) DEFAULT NULL,
  `fullName` NVARCHAR(500) DEFAULT NULL,
  `title` NVARCHAR(1000) DEFAULT NULL,
  `aboutMe` NVARCHAR(2000) DEFAULT NULL,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`uid`),
  FOREIGN KEY fk_user(uid) REFERENCES User(uid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Quanda` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `asker` NVARCHAR(100) NOT NULL,
  `question` NVARCHAR(2000) NOT NULL,
  `responder` NVARCHAR(100) NOT NULL,
  `rate` DOUBLE UNSIGNED NOT NULL,
  `answerUrl` NVARCHAR(1000) DEFAULT NULL,
  `status` ENUM('PENDING', 'ANSWERED', 'EXPIRED') NOT NULL DEFAULT 'PENDING',
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  FOREIGN KEY fk_asker(asker) REFERENCES User(uid),
  FOREIGN KEY fk_responder(responder) REFERENCES User(uid)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

CREATE TABLE `Snoop` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `uid` NVARCHAR(200) NOT NULL,
  `quandaId` BIGINT UNSIGNED NOT NULL,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  FOREIGN KEY fk_user(uid) REFERENCES User(uid),
  FOREIGN KEY fk_quanda(quandaId) REFERENCES Quanda(id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

CREATE TABLE `PcAccount` (
  `uid` NVARCHAR(200) NOT NULL,
  `chargeFrom` NVARCHAR(200) NULL,
  `payTo` NVARCHAR(200) NULL,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`uid`),
  FOREIGN KEY fk_user(uid) REFERENCES User(uid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `PcEntry` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `uid` NVARCHAR(200) NOT NULL,
  `entryId` NVARCHAR(200) NOT NULL,
  `brand` NVARCHAR(10) NULL,
  `last4` NVARCHAR(10) NOT NULL,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY (uid, entryId),
  FOREIGN KEY fk_pcAccount(uid) REFERENCES User(uid)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

CREATE TABLE `QaTransaction` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `uid` NVARCHAR(200) NOT NULL,
  `type` ENUM('ASKED', 'SNOOPED') NOT NULL,
  `quandaId` BIGINT UNSIGNED NOT NULL,
  `amount` DOUBLE UNSIGNED NOT NULL,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY (`uid`, `type`, `quandaId`),
  FOREIGN KEY fk_user(uid) REFERENCES User(uid),
  FOREIGN KEY fk_quanda(quandaId) REFERENCES Quanda(id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

CREATE TABLE `Journal` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `transactionId` BIGINT UNSIGNED NOT NULL,
  `uid` NVARCHAR(200) NOT NULL,
  `amount` DOUBLE NOT NULL,
  `type` ENUM('BALANCE', 'CARD', 'BANKING') NOT NULL,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  FOREIGN KEY fk_user(uid) REFERENCES User(uid),
  FOREIGN KEY fk_qaTransaction(transactionId) REFERENCES QaTransaction(id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;