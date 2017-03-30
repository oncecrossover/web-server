CREATE DATABASE `snoopdb` DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
CREATE USER 'sa' IDENTIFIED BY 'sqlme';
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP
ON snoopdb.* TO 'sa';

use snoopdb;

CREATE TABLE `User` (
  `uid` NVARCHAR(200) NOT NULL,
  `pwd` NVARCHAR(200) NOT NULL,
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
  `rate` INT UNSIGNED NOT NULL DEFAULT 0,
  `avatarUrl` NVARCHAR(1000) DEFAULT NULL,
  `fullName` NVARCHAR(500) NOT NULL,
  `title` NVARCHAR(1000) DEFAULT NULL,
  `aboutMe` NVARCHAR(2000) DEFAULT NULL,
  `takeQuestion` ENUM('NA', 'APPLIED', 'APPROVED', 'DENIED') NOT NULL DEFAULT 'NA',
  `deviceToken` NVARCHAR(1000) DEFAULT NULL,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `pk_profile` PRIMARY KEY (`uid`),
  CONSTRAINT `fk_profile_uid` FOREIGN KEY (`uid`) REFERENCES `User` (`uid`),
  INDEX `idx_profile_fullName` (`fullName`),
  INDEX `idx_profile_discover` (`uid`, `updatedTime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Quanda` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `asker` NVARCHAR(200) NOT NULL,
  `question` NVARCHAR(2000) NOT NULL,
  `responder` NVARCHAR(200) NOT NULL,
  `rate` INT UNSIGNED NOT NULL,
  `answerUrl` NVARCHAR(1000) DEFAULT NULL,
  `answerCoverUrl` NVARCHAR(1000) DEFAULT NULL,
  `duration` INT NOT NULL DEFAULT 0,
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
  INDEX `idx_snoop_uid` (`uid`),
  INDEX `idx_snoop_createdTime` (`createdTime`)
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
  `type` ENUM('BALANCE', 'CARD', 'BANKING', 'COIN') NOT NULL,
  `status` ENUM('PENDING', 'CLEARED', 'REFUNDED') NOT NULL,
  `chargeId` NVARCHAR(200) NULL,
  `coinEntryId` BIGINT UNSIGNED NULL,
  `originId` BIGINT UNSIGNED NULL,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `pk_journal` PRIMARY KEY (`id`),
  CONSTRAINT `fk_journal_transactionId` FOREIGN KEY (`transactionId`) REFERENCES `QaTransaction` (`id`),
  CONSTRAINT `fk_journal_uid` FOREIGN KEY (`uid`) REFERENCES `User` (`uid`),
  CONSTRAINT `fk_journal_originId` FOREIGN KEY (`originId`) REFERENCES `Journal` (`id`),
  CONSTRAINT `fk_journal_coinEntryId` FOREIGN KEY (`coinEntryId`) REFERENCES `Coin` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

CREATE TABLE `Category` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` NVARCHAR(200) NOT NULL,
  `description` NVARCHAR(500) DEFAULT NULL,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `pk_category` PRIMARY KEY (`id`),
  CONSTRAINT `uk_category` UNIQUE (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

CREATE TABLE `CatMapping` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `catId` BIGINT UNSIGNED NOT NULL,
  `uid` NVARCHAR(200) NOT NULL,
  `isExpertise` ENUM('YES', 'NO') NOT NULL DEFAULT 'NO',
  `isInterest` ENUM('YES', 'NO') NOT NULL DEFAULT 'NO',
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `pk_catMapping` PRIMARY KEY (`id`),
  CONSTRAINT `uk_catMapping` UNIQUE (`catId`, `uid`),
  CONSTRAINT `fk_catMapping_catId` FOREIGN KEY (`catId`) REFERENCES `Category` (`id`),
  CONSTRAINT `fk_catMapping_uid` FOREIGN KEY (`uid`) REFERENCES `User` (`uid`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;

CREATE TABLE `Coin` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `uid` NVARCHAR(200) NOT NULL,
  `amount` INT NOT NULL,
  `originId` BIGINT UNSIGNED NULL,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `pk_coin` PRIMARY KEY (`id`),
  CONSTRAINT `fk_coin_uid` FOREIGN KEY (`uid`) REFERENCES `User` (`uid`),
  CONSTRAINT `fk_coin_originId` FOREIGN KEY (`originId`) REFERENCES `Coin` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;