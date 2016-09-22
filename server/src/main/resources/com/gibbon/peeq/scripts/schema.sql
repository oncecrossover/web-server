CREATE TABLE `User` (
  `uid` NVARCHAR(200) NOT NULL,
  `pwd` NVARCHAR(100) NOT NULL,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `pk_user` PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `TempPwd` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `uid` NVARCHAR(200) NOT NULL,
  `pwd` NVARCHAR(50) NOT NULL,
  `status` ENUM('PENDING', 'EXPIRED') NOT NULL DEFAULT 'PENDING',
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `pk_tempPwd` PRIMARY KEY (`id`),
  CONSTRAINT `fk_tempPwd_uid` FOREIGN KEY (`uid`) REFERENCES `User` (`uid`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

CREATE TABLE `Profile` (
  `uid` NVARCHAR(200) NOT NULL,
  `rate` DOUBLE UNSIGNED NOT NULL,
  `avatarUrl` NVARCHAR(1000) DEFAULT NULL,
  `fullName` NVARCHAR(500) NOT NULL,
  `title` NVARCHAR(1000) DEFAULT NULL,
  `aboutMe` NVARCHAR(2000) DEFAULT NULL,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `pk_profile` PRIMARY KEY (`uid`),
  CONSTRAINT `fk_profile_uid` FOREIGN KEY (`uid`) REFERENCES `User` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Quanda` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `asker` NVARCHAR(200) NOT NULL,
  `question` NVARCHAR(2000) NOT NULL,
  `responder` NVARCHAR(200) NOT NULL,
  `rate` DOUBLE UNSIGNED NOT NULL,
  `answerUrl` NVARCHAR(1000) DEFAULT NULL,
  `status` ENUM('PENDING', 'ANSWERED', 'EXPIRED') NOT NULL DEFAULT 'PENDING',
  `active` ENUM('TRUE', 'FALSE') NOT NULL DEFAULT 'TRUE',
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `pk_quanda` PRIMARY KEY (`id`),
  CONSTRAINT `fk_quanda_asker` FOREIGN KEY (`asker`) REFERENCES `User` (`uid`),
  CONSTRAINT `fk_quanda_responder` FOREIGN KEY (`responder`) REFERENCES `User` (`uid`),
  INDEX `idx_quanda_questions` (`id`, `asker`, `active`, `updatedTime`),
  INDEX `idx_quanda_answers` (`id`, `responder`, `status`, `createdTime`),
  INDEX `idx_quanda_snoops` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

CREATE TABLE `Snoop` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `uid` NVARCHAR(200) NOT NULL,
  `quandaId` BIGINT UNSIGNED NOT NULL,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `pk_snoop` PRIMARY KEY (`id`),
  CONSTRAINT `uk_snoop` UNIQUE (`uid`,`quandaId`),
  CONSTRAINT `fk_snoop_uid` FOREIGN KEY (`uid`) REFERENCES `User` (`uid`),
  CONSTRAINT `fk_snoop_quandaId` FOREIGN KEY (`quandaId`) REFERENCES `Quanda` (`id`),
  INDEX `idx_snoop_snoops` (`createdTime`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

CREATE TABLE `PcAccount` (
  `uid` NVARCHAR(200) NOT NULL,
  `chargeFrom` NVARCHAR(200) NULL,
  `payTo` NVARCHAR(200) NULL,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `pk_pcAccount` PRIMARY KEY (`uid`),
  CONSTRAINT `fk_pcAccount_uid` FOREIGN KEY (`uid`) REFERENCES `User` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `PcEntry` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `uid` NVARCHAR(200) NOT NULL,
  `entryId` NVARCHAR(200) NOT NULL,
  `brand` NVARCHAR(10) NULL,
  `last4` NVARCHAR(10) NOT NULL,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `pk_pcEntry` PRIMARY KEY (`id`),
  CONSTRAINT `uk_pcEntry` UNIQUE (`uid`,`entryId`),
  CONSTRAINT `fk_pcEntry_uid` FOREIGN KEY (`uid`) REFERENCES `PcAccount` (`uid`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

CREATE TABLE `QaTransaction` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `uid` NVARCHAR(200) NOT NULL,
  `type` ENUM('ASKED', 'SNOOPED') NOT NULL,
  `quandaId` BIGINT UNSIGNED NOT NULL,
  `amount` DOUBLE UNSIGNED NOT NULL,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `pk_qaTransaction` PRIMARY KEY (`id`),
  CONSTRAINT `uk_qaTransaction` UNIQUE (`uid`, `type`, `quandaId`),
  CONSTRAINT `fk_qaTransaction_uid` FOREIGN KEY (`uid`) REFERENCES `User` (`uid`),
  CONSTRAINT `fk_qaTransaction_quandaId` FOREIGN KEY (`quandaId`) REFERENCES `Quanda` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

CREATE TABLE `Journal` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `transactionId` BIGINT UNSIGNED NOT NULL,
  `uid` NVARCHAR(200) NOT NULL,
  `amount` DOUBLE NOT NULL,
  `type` ENUM('BALANCE', 'CARD', 'BANKING') NOT NULL,
  `chargeId` NVARCHAR(200) NULL,
  `status` ENUM('PENDING', 'CLEARED', 'REFUNDED') NOT NULL,
  `originId` BIGINT UNSIGNED NULL,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `pk_journal` PRIMARY KEY (`id`),
  CONSTRAINT `fk_journal_transactionId` FOREIGN KEY (`transactionId`) REFERENCES `QaTransaction` (`id`),
  CONSTRAINT `fk_journal_uid` FOREIGN KEY (`uid`) REFERENCES `User` (`uid`),
  CONSTRAINT `fk_journal_originId` FOREIGN KEY (`originId`) REFERENCES `Journal` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;