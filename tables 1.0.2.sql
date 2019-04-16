-- 
-- file version 1.0.2
-- date: 14.04.2016
-- 
-- changes:
-- 14.04.2016 1.0.2
-- added fields to table sipfriends (realm, username, ...)
-- changed order of the fields in table sipfriends (allow and disallow)
-- 03.06.2015 1.0.1
-- added comments to fields and tables 
-- changed sipfriends: added field for public number publicclir
-- changed trunk_pattern: added field min, max, prefix and sufix
-- added table recorded_files
-- added table dialplanerrors

USE asteriskdatabase;

-- table type of calls
CREATE TABLE `cdr_call_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `call_type` varchar(20) COLLATE latin2_croatian_ci NOT NULL,
  `goSub` varchar(45) COLLATE latin2_croatian_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin2 COLLATE=latin2_croatian_ci COMMENT='This table contains types of calls. It is fixed to: 1. Normal call, 2. Group call, 3. Fax, 4. Voicemail & 5. Conference.';

-- populating the table 
INSERT INTO `asteriskdatabase`.`cdr_call_type`
(`id`,
`call_type`,
`goSub`)
VALUES
(1,
'Phone call',
'subToExtension'),
(2,
'Group call',
'subToGroup'),
(3,
'Fax',
'subToFax'),
(4,
'Voice mail',
'subToVoicemail'),
(5,
'Conference',
'subToConference')
;


-- CDR records table
CREATE TABLE `cdr` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `calldate` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `clid` varchar(80) NOT NULL DEFAULT '',
  `src` varchar(80) NOT NULL DEFAULT '',
  `dst` varchar(80) NOT NULL DEFAULT '',
  `dcontext` varchar(80) NOT NULL DEFAULT '',
  `channel` varchar(80) NOT NULL DEFAULT '',
  `dstchannel` varchar(80) NOT NULL DEFAULT '',
  `lastapp` varchar(80) NOT NULL DEFAULT '',
  `lastdata` varchar(80) NOT NULL DEFAULT '',
  `duration` int(11) NOT NULL DEFAULT '0',
  `billsec` int(11) NOT NULL DEFAULT '0',
  `disposition` varchar(45) NOT NULL DEFAULT '',
  `amaflags` int(11) NOT NULL DEFAULT '0',
  `accountcode` varchar(20) NOT NULL DEFAULT '',
  `uniqueid` varchar(32) NOT NULL DEFAULT '',
  `userfield` varchar(255) NOT NULL DEFAULT '',
  `peeraccount` varchar(20) NOT NULL DEFAULT '',
  `linkedid` varchar(32) NOT NULL DEFAULT '',
  `sequence` int(11) NOT NULL DEFAULT '0',
  `calltype` int(11) NOT NULL DEFAULT '1' COMMENT 'related to table cdr_call_type.',
  `recorded` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Set through mvrecording when recordin is activated.',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  KEY `calltype_idx` (`calltype`),
  KEY `uniqueid` (`uniqueid`),
  CONSTRAINT `calltype` FOREIGN KEY (`calltype`) REFERENCES `cdr_call_type` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=617 DEFAULT CHARSET=latin1 COMMENT='Call detail records table (CDR).';



-- types of outgoing calls 
CREATE TABLE `pattern_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pattern_type_name` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COMMENT='Types of outgoing patterns. Locale, Nationale, Mobile, Emergency, International...';

-- populating the table
INSERT INTO `asteriskdatabase`.`pattern_type`
(
`pattern_type_name`)
VALUES
('Locale'),

('National'),

('Mobile'),

('Emergency'),

('International');


-- Users
CREATE TABLE `sipfriends` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL COMMENT 'Mandatory field: username',
  `user` varchar(45) DEFAULT NULL,
  `ipaddr` varchar(15) DEFAULT NULL,
  `port` int(5) DEFAULT NULL,
  `extension` varchar(128) NOT NULL COMMENT 'Extensions which user uses',
  `regseconds` int(11) DEFAULT NULL,
  `defaultuser` varchar(10) DEFAULT NULL COMMENT 'Same as username.',
  `fullcontact` varchar(35) DEFAULT NULL,
  `regserver` varchar(20) DEFAULT NULL,
  `useragent` varchar(20) DEFAULT NULL,
  `lastms` int(11) DEFAULT NULL,
  `host` varchar(40) DEFAULT NULL COMMENT 'If it is phone then it is dynamic, if it is trunk then IP address.',
  `type` enum('friend','user','peer') DEFAULT NULL COMMENT 'Type of SIP entity. Phone = friend, Trunk = peer.',
  `context` varchar(40) DEFAULT NULL COMMENT 'Context of the entity.',
  `permit` varchar(40) DEFAULT NULL COMMENT 'Allowed networks from which SIP entity comes. Can be IP address.',
  `deny` varchar(40) DEFAULT NULL COMMENT 'Forbiden networks from which SIP entity comes. Can be IP address.',
  `secret` varchar(40) DEFAULT NULL COMMENT 'Password.',
  `username` varchar(20) DEFAULT NULL,
  `realm` varchar(40) DEFAULT NULL,
  `md5secret` varchar(40) DEFAULT NULL,
  `remotesecret` varchar(40) DEFAULT NULL,
  `transport` enum('udp','tcp','tls','ws','wss','udp,tcp','tcp,udp') DEFAULT NULL,
  `dtmfmode` enum('rfc2833','info','shortinfo','inband','auto') DEFAULT NULL COMMENT 'Usually in sip.conf is set RFC2833 and here we can set per user.',
  `directmedia` enum('yes','no','nonat','update') DEFAULT 'no' COMMENT 'If phone yes, and if trunk then no. This parameter defines if two entities can communicate directly.',
  `nat` enum('yes','no','never','route') DEFAULT 'no' COMMENT 'Is NAT (Network Address Translation) used.',
  `callgroup` varchar(40) DEFAULT NULL,
  `pickupgroup` varchar(40) DEFAULT NULL,
  `language` varchar(40) DEFAULT NULL,
  `disallow` varchar(40) DEFAULT NULL,
  `allow` varchar(40) DEFAULT NULL COMMENT 'Allowed codecs.',
  `insecure` varchar(40) DEFAULT NULL,
  `trustrpid` enum('yes','no') DEFAULT NULL,
  `progressinband` enum('yes','no','never') DEFAULT NULL,
  `promiscredir` enum('yes','no') DEFAULT NULL,
  `useclientcode` enum('yes','no') DEFAULT NULL,
  `accountcode` varchar(40) DEFAULT NULL,
  `setvar` varchar(40) DEFAULT NULL,
  `callerid` varchar(40) DEFAULT NULL COMMENT 'Caller ID - can be text too.',
  `amaflags` varchar(40) DEFAULT NULL,
  `callcounter` enum('yes','no') DEFAULT NULL,
  `busylevel` int(11) DEFAULT NULL,
  `allowoverlap` enum('yes','no') DEFAULT NULL,
  `allowsubscribe` enum('yes','no') DEFAULT NULL,
  `videosupport` enum('yes','no') DEFAULT NULL,
  `maxcallbitrate` int(11) DEFAULT NULL,
  `rfc2833compensate` enum('yes','no') DEFAULT NULL,
  `mailbox` varchar(40) DEFAULT NULL,
  `session-timers` enum('accept','refuse','originate') DEFAULT NULL,
  `session-expires` int(11) DEFAULT NULL,
  `session-minse` int(11) DEFAULT NULL,
  `session-refresher` enum('uac','uas') DEFAULT NULL,
  `t38pt_usertpsource` varchar(40) DEFAULT NULL,
  `regexten` varchar(40) DEFAULT NULL,
  `fromdomain` varchar(40) DEFAULT NULL,
  `fromuser` varchar(40) DEFAULT NULL,
  `qualify` varchar(40) DEFAULT NULL,
  `defaultip` varchar(40) DEFAULT NULL,
  `rtptimeout` int(11) DEFAULT NULL,
  `rtpholdtimeout` int(11) DEFAULT NULL,
  `sendrpid` enum('yes','no') DEFAULT NULL,
  `outboundproxy` varchar(40) DEFAULT NULL,
  `callbackextension` varchar(40) DEFAULT NULL,
  `registertrying` enum('yes','no') DEFAULT NULL,
  `timert1` int(11) DEFAULT NULL,
  `timerb` int(11) DEFAULT NULL,
  `qualifyfreq` int(11) DEFAULT NULL,
  `constantssrc` enum('yes','no') DEFAULT NULL,
  `contactpermit` varchar(40) DEFAULT NULL,
  `contactdeny` varchar(40) DEFAULT NULL,
  `usereqphone` enum('yes','no') DEFAULT NULL,
  `textsupport` enum('yes','no') DEFAULT NULL,
  `faxdetect` enum('yes','no') DEFAULT NULL,
  `buggymwi` enum('yes','no') DEFAULT NULL,
  `auth` varchar(40) DEFAULT NULL,
  `fullname` varchar(40) DEFAULT NULL,
  `trunkname` varchar(40) DEFAULT NULL,
  `cid_number` varchar(40) DEFAULT NULL COMMENT 'Numerical Caller ID. Needed for call back at least.',
  `publicclid` varchar(40) DEFAULT NULL COMMENT 'Outgoing calls id',
  `callingpres` enum('allowed_not_screened','allowed_passed_screen','allowed_failed_screen','allowed','prohib_not_screened','prohib_passed_screen','prohib_failed_screen','prohib') DEFAULT NULL COMMENT 'If there is requirement to present differently on a trunk (public caller ID).',
  `mohinterpret` varchar(40) DEFAULT NULL,
  `mohsuggest` varchar(40) DEFAULT NULL,
  `parkinglot` varchar(40) DEFAULT NULL,
  `hasvoicemail` enum('yes','no') DEFAULT NULL,
  `subscribemwi` enum('yes','no') DEFAULT NULL,
  `vmexten` varchar(40) DEFAULT NULL,
  `autoframing` enum('yes','no') DEFAULT NULL,
  `rtpkeepalive` int(11) DEFAULT NULL,
  `call-limit` int(11) DEFAULT NULL,
  `g726nonstandard` enum('yes','no') DEFAULT NULL,
  `ignoresdpversion` enum('yes','no') DEFAULT NULL,
  `allowtransfer` enum('yes','no') DEFAULT NULL,
  `dynamic` enum('yes','no') DEFAULT NULL,
  `canreinvite` varchar(45) DEFAULT NULL,
  `voicemail` varchar(45) DEFAULT NULL COMMENT 'Voicemail mailbox.',
  `voicemail_context` varchar(45) DEFAULT NULL COMMENT 'Voicemail context.',
  `options` varchar(45) DEFAULT NULL COMMENT 'Call options',
  `beforeNext` int(11) DEFAULT NULL COMMENT 'Time in seconds for next step in callflow. Used for forwarding or voicemail.',
  `call_type` int(11) DEFAULT '1' COMMENT 'Type of call / extension. Related to cdr_call_type table.',
  `record` enum('yes','no') DEFAULT 'no' COMMENT 'Calls are recorded (yes or no).',
  `path` varchar(256) DEFAULT NULL,
  `supportpath` enum('yes','no') DEFAULT NULL,
  `gmembers` varchar(256) DEFAULT NULL COMMENT 'Member of the group separated by *. Field must end with the same character.',
  `gtype` enum('s','g') DEFAULT NULL COMMENT 'Type of group: s - phones are ringing one by one, g - all phones are ringing in same time.',
  `conftype` varchar(20) DEFAULT NULL COMMENT 'Type of conference bridge (if it is empty used default from confbridge.conf).',
  `confusertype` varchar(20) DEFAULT NULL COMMENT 'For phones conference user. (If empty used default user from confbridge.conf)',
  `forwardedto` varchar(20) DEFAULT NULL COMMENT 'If calls are forwarded to which number. If it is external destinatio must contain dial out number.',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `extension_UNIQUE` (`extension`),
  KEY `ipaddr` (`ipaddr`,`port`),
  KEY `host` (`host`,`port`),
  KEY `call_type_idx` (`call_type`),
  CONSTRAINT `call_type_FK` FOREIGN KEY (`call_type`) REFERENCES `cdr_call_type` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1 COMMENT='Table contains list of all users (SIP) both phones and trunks.';




-- table with definition of users that are allowed to use patterns
CREATE TABLE `pattern_type_allowed` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_caller` int(11) NOT NULL COMMENT 'From sipfriends table.',
  `id_pattern` int(11) NOT NULL COMMENT 'From pattern_type table.',
  PRIMARY KEY (`id`),
  KEY `caller_idx` (`id_caller`),
  KEY `pattern_type_idx` (`id_pattern`),
  CONSTRAINT `caller` FOREIGN KEY (`id_caller`) REFERENCES `sipfriends` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `pattern_type` FOREIGN KEY (`id_pattern`) REFERENCES `pattern_type` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1 COMMENT='Relation between type of outgoing calls and users.';


-- table connecting pattern and trunk
CREATE TABLE `trunk_pattern` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) DEFAULT NULL COMMENT 'Pattern name',
  `pattern` varchar(20) NOT NULL COMMENT 'Pattern - beginning of the dialed number',
  `min` int(11) NOT NULL COMMENT 'Min number of digits.',
  `max` int(11) NOT NULL COMMENT 'Max number of digits.',
  `trunk` varchar(20) NOT NULL COMMENT 'Outgoing trunk including technology. E.g. "SIP/trunkname".',
  `pattern_type` int(11) NOT NULL COMMENT 'Type of pattern - pattern_type.',
  `prefix` varchar(5) DEFAULT NULL COMMENT 'Added infront of dialed number.',
  `sufix` varchar(5) DEFAULT NULL COMMENT 'Added behind dialed number.',
  PRIMARY KEY (`id`),
  UNIQUE KEY `pattern_unique` (`pattern`,`min`,`max`),
  KEY `pattern_type_idx` (`pattern_type`),
  KEY `pattern_type_fk_idx` (`pattern_type`),
  CONSTRAINT `pattern_type_fk` FOREIGN KEY (`pattern_type`) REFERENCES `pattern_type` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1 COMMENT='List of patterns.';



-- podaci za voicemail mailboxove
CREATE TABLE `voicemail` (
  `uniqueid` int(11) NOT NULL AUTO_INCREMENT,
  `context` varchar(80) NOT NULL COMMENT 'VM context. Can be different from users ',
  `mailbox` varchar(80) NOT NULL COMMENT 'Mailbox name',
  `password` varchar(80) NOT NULL COMMENT 'Password.',
  `fullname` varchar(80) DEFAULT NULL,
  `alias` varchar(80) DEFAULT NULL,
  `email` varchar(80) DEFAULT NULL COMMENT 'Email address for voicemail forwarding.',
  `pager` varchar(80) DEFAULT NULL,
  `attach` enum('yes','no') DEFAULT NULL,
  `attachfmt` varchar(10) DEFAULT NULL,
  `serveremail` varchar(80) DEFAULT NULL COMMENT 'Mail which server uses afor identification when sending the email.',
  `language` varchar(20) DEFAULT NULL,
  `tz` varchar(30) DEFAULT NULL,
  `deletevoicemail` enum('yes','no') DEFAULT NULL COMMENT 'Message is deleted after forwarding?',
  `saycid` enum('yes','no') DEFAULT NULL,
  `sendvoicemail` enum('yes','no') DEFAULT NULL COMMENT 'Is the message sent or only information.',
  `review` enum('yes','no') DEFAULT NULL,
  `tempgreetwarn` enum('yes','no') DEFAULT NULL,
  `operator` enum('yes','no') DEFAULT NULL,
  `envelope` enum('yes','no') DEFAULT NULL,
  `sayduration` int(11) DEFAULT NULL,
  `forcename` enum('yes','no') DEFAULT NULL,
  `forcegreetings` enum('yes','no') DEFAULT NULL,
  `callback` varchar(80) DEFAULT NULL,
  `dialout` varchar(80) DEFAULT NULL,
  `exitcontext` varchar(80) DEFAULT NULL,
  `maxmsg` int(11) DEFAULT NULL,
  `volgain` decimal(5,2) DEFAULT NULL,
  `imapuser` varchar(80) DEFAULT NULL,
  `imappassword` varchar(80) DEFAULT NULL,
  `imapserver` varchar(80) DEFAULT NULL,
  `imapport` varchar(8) DEFAULT NULL,
  `imapflags` varchar(80) DEFAULT NULL,
  `stamp` datetime DEFAULT NULL,
  PRIMARY KEY (`uniqueid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Voicemail mailboxes definition.';

-- table with errors (requests that dont return results). Writes down errors from GetExternaPath, GetSIPUserWithOptions and dialplan.
CREATE TABLE `dialplanerrors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `from` varchar(45) DEFAULT NULL,
  `to` varchar(45) DEFAULT NULL,
  `description` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `CREATED` (`created`)
) ENGINE=InnoDB AUTO_INCREMENT=74 DEFAULT CHARSET=latin1 COMMENT='This is Error log. Writes down errors from GetExternaPath, GetSIPUserWithOptions and dialplan. If the error is in dialplan then error logging is initialized from dialplan, if the error is in stored procedures, then from the procedure.';


-- table which connects calls with recordings (for searches and retrieval)
CREATE TABLE `recorded_files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `recorded_filename` varchar(100) DEFAULT NULL,
  `call_id` varchar(32) DEFAULT NULL COMMENT 'uniqueid field in cdr table.',
  PRIMARY KEY (`id`),
  KEY `uniquecall_idx` (`call_id`),
  CONSTRAINT `uniquecall` FOREIGN KEY (`call_id`) REFERENCES `cdr` (`uniqueid`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=latin1 COMMENT='List of recordings and relation with the call (UNIQUE ID).';

