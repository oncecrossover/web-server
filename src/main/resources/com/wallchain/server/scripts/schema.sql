CREATE DATABASE `wallchaindb` DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
CREATE USER 'sa' IDENTIFIED BY 'sqlme';
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP
ON wallchaindb.* TO 'sa';

use wallchaindb;

CREATE TABLE `User` (
  `id` BIGINT UNSIGNED NOT NULL,
  `uname` NVARCHAR(200) NOT NULL,
  `pwd` NVARCHAR(200) NOT NULL,
  `primaryEmail` NVARCHAR(200) NULL,
  `source` ENUM('FACEBOOK', 'TWITTER', 'INSTAGRAM', 'GMAIL', 'EMAIL') NOT NULL DEFAULT 'EMAIL',
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `pk_user` PRIMARY KEY (`id`),
  CONSTRAINT `uk_user` UNIQUE (`uname`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `TempPwd` (
  `id` BIGINT UNSIGNED NOT NULL,
  `uid` BIGINT UNSIGNED NOT NULL,
  `pwd` NVARCHAR(50) NOT NULL,
  `status` ENUM('PENDING', 'EXPIRED') NOT NULL DEFAULT 'PENDING',
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `pk_tempPwd` PRIMARY KEY (`id`),
  CONSTRAINT `fk_tempPwd_uid` FOREIGN KEY (`uid`) REFERENCES `User` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Profile` (
  `id` BIGINT UNSIGNED NOT NULL,
  `rate` INT UNSIGNED NOT NULL DEFAULT 0,
  `avatarUrl` NVARCHAR(1000) DEFAULT NULL,
  `fullName` NVARCHAR(500) NOT NULL,
  `title` NVARCHAR(1000) DEFAULT NULL,
  `aboutMe` NVARCHAR(2000) DEFAULT NULL,
  `takeQuestion` ENUM('NA', 'APPLIED', 'APPROVED', 'DENIED') NOT NULL DEFAULT 'NA',
  `deviceToken` NVARCHAR(1000) DEFAULT NULL,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `pk_profile` PRIMARY KEY (`id`),
  CONSTRAINT `fk_profile_id` FOREIGN KEY (`id`) REFERENCES `User` (`id`),
  INDEX `idx_profile_fullName` (`fullName`),
  INDEX `idx_profile_discover` (`id`, `updatedTime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Quanda` (
  `id` BIGINT UNSIGNED NOT NULL,
  `asker` BIGINT UNSIGNED NOT NULL,
  `question` NVARCHAR(2000) NOT NULL,
  `responder` BIGINT UNSIGNED NOT NULL,
  `rate` INT UNSIGNED NOT NULL,
  `answerUrl` NVARCHAR(1000) DEFAULT NULL,
  `answerCoverUrl` NVARCHAR(1000) DEFAULT NULL,
  `duration` INT NOT NULL DEFAULT 0,
  `status` ENUM('PENDING', 'ANSWERED', 'EXPIRED') NOT NULL DEFAULT 'PENDING',
  `active` ENUM('TRUE', 'FALSE') NOT NULL DEFAULT 'TRUE',
  `isAskerAnonymous` ENUM('TRUE', 'FALSE') NOT NULL DEFAULT 'FALSE',
  `limitedFreeHours` BIGINT UNSIGNED NOT NULL DEFAULT 48,
  `answeredTime` TIMESTAMP NULL,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `pk_quanda` PRIMARY KEY (`id`),
  CONSTRAINT `fk_quanda_asker` FOREIGN KEY (`asker`) REFERENCES `User` (`id`),
  CONSTRAINT `fk_quanda_responder` FOREIGN KEY (`responder`) REFERENCES `User` (`id`),
  INDEX `idx_quanda_questions` (`id`, `asker`, `active`, `updatedTime`),
  INDEX `idx_quanda_answers` (`id`, `responder`, `status`, `createdTime`),
  INDEX `idx_quanda_snoops` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Snoop` (
  `id` BIGINT UNSIGNED NOT NULL,
  `uid` BIGINT UNSIGNED NOT NULL,
  `quandaId` BIGINT UNSIGNED NOT NULL,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `pk_snoop` PRIMARY KEY (`id`),
  CONSTRAINT `uk_snoop` UNIQUE (`uid`,`quandaId`),
  CONSTRAINT `fk_snoop_uid` FOREIGN KEY (`uid`) REFERENCES `User` (`id`),
  CONSTRAINT `fk_snoop_quandaId` FOREIGN KEY (`quandaId`) REFERENCES `Quanda` (`id`),
  INDEX `idx_snoop_uid` (`uid`),
  INDEX `idx_snoop_quandaId` (`quandaId`),
  INDEX `idx_snoop_createdTime` (`createdTime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `PcAccount` (
  `id` BIGINT UNSIGNED NOT NULL,
  `chargeFrom` NVARCHAR(200) NULL,
  `payTo` NVARCHAR(200) NULL,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `pk_pcAccount` PRIMARY KEY (`id`),
  CONSTRAINT `fk_pcAccount_id` FOREIGN KEY (`id`) REFERENCES `User` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `PcEntry` (
  `id` BIGINT UNSIGNED NOT NULL,
  `uid` BIGINT UNSIGNED NOT NULL,
  `entryId` NVARCHAR(200) NOT NULL,
  `brand` NVARCHAR(10) NULL,
  `last4` NVARCHAR(10) NOT NULL,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `pk_pcEntry` PRIMARY KEY (`id`),
  CONSTRAINT `uk_pcEntry` UNIQUE (`uid`,`entryId`),
  CONSTRAINT `fk_pcEntry_uid` FOREIGN KEY (`uid`) REFERENCES `PcAccount` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `QaTransaction` (
  `id` BIGINT UNSIGNED NOT NULL,
  `uid` BIGINT UNSIGNED NOT NULL,
  `type` ENUM('ASKED', 'SNOOPED') NOT NULL,
  `quandaId` BIGINT UNSIGNED NOT NULL,
  `amount` DOUBLE UNSIGNED NOT NULL,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `pk_qaTransaction` PRIMARY KEY (`id`),
  CONSTRAINT `uk_qaTransaction` UNIQUE (`uid`, `type`, `quandaId`),
  CONSTRAINT `fk_qaTransaction_uid` FOREIGN KEY (`uid`) REFERENCES `User` (`id`),
  CONSTRAINT `fk_qaTransaction_quandaId` FOREIGN KEY (`quandaId`) REFERENCES `Quanda` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Coin` (
  `id` BIGINT UNSIGNED NOT NULL,
  `uid` BIGINT UNSIGNED NOT NULL,
  `amount` INT NOT NULL,
  `originId` BIGINT UNSIGNED NULL,
  `promoId` BIGINT UNSIGNED NULL,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `pk_coin` PRIMARY KEY (`id`),
  CONSTRAINT `fk_coin_uid` FOREIGN KEY (`uid`) REFERENCES `User` (`id`),
  CONSTRAINT `fk_coin_originId` FOREIGN KEY (`originId`) REFERENCES `Coin` (`id`),
  CONSTRAINT `fk_coin_promoId` FOREIGN KEY (`promoId`) REFERENCES `Promo` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Journal` (
  `id` BIGINT UNSIGNED NOT NULL,
  `transactionId` BIGINT UNSIGNED NOT NULL,
  `uid` BIGINT UNSIGNED NOT NULL,
  `amount` DOUBLE NOT NULL,
  `type` ENUM('BALANCE', 'CARD', 'BANKING', 'COIN') NOT NULL,
  `status` ENUM('PENDING', 'CLEARED', 'REFUNDED') NOT NULL,
  `chargeId` NVARCHAR(200) NULL,
  `coinEntryId` BIGINT UNSIGNED NULL,
  `originId` BIGINT UNSIGNED NULL,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `pk_journal` PRIMARY KEY (`id`),
  CONSTRAINT `fk_journal_transactionId` FOREIGN KEY (`transactionId`) REFERENCES `QaTransaction` (`id`),
  CONSTRAINT `fk_journal_uid` FOREIGN KEY (`uid`) REFERENCES `User` (`id`),
  CONSTRAINT `fk_journal_originId` FOREIGN KEY (`originId`) REFERENCES `Journal` (`id`),
  CONSTRAINT `fk_journal_coinEntryId` FOREIGN KEY (`coinEntryId`) REFERENCES `Coin` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Category` (
  `id` BIGINT UNSIGNED NOT NULL,
  `name` NVARCHAR(200) NOT NULL,
  `description` NVARCHAR(500) DEFAULT NULL,
  `resourceUrl` NVARCHAR(1000) DEFAULT NULL,
  `active` ENUM('TRUE', 'FALSE') NOT NULL DEFAULT 'TRUE',
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `pk_category` PRIMARY KEY (`id`),
  CONSTRAINT `uk_category` UNIQUE (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `CatMapping` (
  `id` BIGINT UNSIGNED NOT NULL,
  `catId` BIGINT UNSIGNED NOT NULL,
  `uid` BIGINT UNSIGNED NOT NULL,
  `isExpertise` ENUM('YES', 'NO') NOT NULL DEFAULT 'NO',
  `isInterest` ENUM('YES', 'NO') NOT NULL DEFAULT 'NO',
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `pk_catMapping` PRIMARY KEY (`id`),
  CONSTRAINT `uk_catMapping` UNIQUE (`catId`, `uid`),
  CONSTRAINT `fk_catMapping_catId` FOREIGN KEY (`catId`) REFERENCES `Category` (`id`),
  CONSTRAINT `fk_catMapping_uid` FOREIGN KEY (`uid`) REFERENCES `User` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Configuration` (
  `id` BIGINT UNSIGNED NOT NULL,
  `ckey` NVARCHAR(255) NOT NULL,
  `value` NVARCHAR(512) DEFAULT NULL,
  `defaultValue` NVARCHAR(512) NOT NULL,
  `description` NVARCHAR(512) NOT NULL,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `pk_Configuration` PRIMARY KEY (`id`),
  CONSTRAINT `uk_Configuration` UNIQUE (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Report` (
  `id` BIGINT UNSIGNED NOT NULL,
  `uid` BIGINT UNSIGNED NOT NULL,
  `quandaId` BIGINT UNSIGNED NOT NULL,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `pk_report` PRIMARY KEY (`id`),
  CONSTRAINT `fk_report_uid` FOREIGN KEY (`uid`) REFERENCES `User` (`id`),
  CONSTRAINT `fk_report_quandaId` FOREIGN KEY (`quandaId`) REFERENCES `Quanda` (`id`),
  INDEX `idx_report_uid` (`uid`),
  INDEX `idx_report_quandaId` (`quandaId`),
  INDEX `idx_report_createdTime` (`createdTime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Block` (
  `id` BIGINT UNSIGNED NOT NULL,
  `uid` BIGINT UNSIGNED NOT NULL,
  `blockeeId` BIGINT UNSIGNED NOT NULL,
  `blocked` ENUM('TRUE', 'FALSE') NOT NULL DEFAULT 'FALSE',
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `pk_block` PRIMARY KEY (`id`),
  CONSTRAINT `uk_block` UNIQUE (`uid`,`blockeeId`),
  CONSTRAINT `fk_block_uid` FOREIGN KEY (`uid`) REFERENCES `User` (`id`),
  CONSTRAINT `fk_block_blockeeId` FOREIGN KEY (`blockeeId`) REFERENCES `User` (`id`),
  INDEX `idx_block_uid` (`uid`),
  INDEX `idx_block_blockeeId` (`blockeeId`),
  INDEX `idx_block_createdTime` (`createdTime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Follow` (
  `id` BIGINT UNSIGNED NOT NULL,
  `uid` BIGINT UNSIGNED NOT NULL,
  `followeeId` BIGINT UNSIGNED NOT NULL,
  `followed` ENUM('TRUE', 'FALSE') NOT NULL DEFAULT 'FALSE',
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `pk_follow` PRIMARY KEY (`id`),
  CONSTRAINT `uk_follow` UNIQUE (`uid`,`followeeId`),
  CONSTRAINT `fk_follow_uid` FOREIGN KEY (`uid`) REFERENCES `User` (`id`),
  CONSTRAINT `fk_follow_followeeId` FOREIGN KEY (`followeeId`) REFERENCES `User` (`id`),
  INDEX `idx_follow_uid` (`uid`),
  INDEX `idx_follow_followeeId` (`followeeId`),
  INDEX `idx_follow_createdTime` (`createdTime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Thumb` (
  `id` BIGINT UNSIGNED NOT NULL,
  `uid` BIGINT UNSIGNED NOT NULL,
  `quandaId` BIGINT UNSIGNED NOT NULL,
  `upped` ENUM('TRUE', 'FALSE') NOT NULL DEFAULT 'FALSE',
  `downed` ENUM('TRUE', 'FALSE') NOT NULL DEFAULT 'FALSE',
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `pk_thumb` PRIMARY KEY (`id`),
  CONSTRAINT `uk_thumb` UNIQUE (`uid`,`quandaId`),
  CONSTRAINT `fk_thumb_uid` FOREIGN KEY (`uid`) REFERENCES `User` (`id`),
  CONSTRAINT `fk_thumb_quandaId` FOREIGN KEY (`quandaId`) REFERENCES `Quanda` (`id`),
  INDEX `idx_thumb_uid` (`uid`),
  INDEX `idx_thumb_quandaId` (`quandaId`),
  INDEX `idx_thumb_createdTime` (`createdTime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `Promo` (
  `id` BIGINT UNSIGNED NOT NULL,
  `uid` BIGINT UNSIGNED NOT NULL,
  `code` NVARCHAR(255) NOT NULL,
  `amount` INT NOT NULL DEFAULT 20,
  `createdTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `pk_promo` PRIMARY KEY (`id`),
  CONSTRAINT `uk_promo` UNIQUE (`uid`,`code`),
  CONSTRAINT `fk_promo_uid` FOREIGN KEY (`uid`) REFERENCES `User` (`id`),
  INDEX `idx_promo_uid` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;