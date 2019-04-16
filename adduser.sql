# adding user to asterisk
# file version 1.0.1
# date: 03.06.2015
#
# changes:
# 03.06.2015 1.0.1
# added field for public number - publicclid

INSERT INTO `asteriskdatabase`.`sipfriends`
(
`name`,
`extension`,
`defaultuser`,
`host`,
`type`,
`context`,
`secret`,
`directmedia`,
`nat`,
`callerid`,
`cid_number`,
`publicclid`,
`voicemail`,
`voicemail_context`,
`options`,
`beforeNext`,
`call_type`
)
VALUES
(
<{name: }>,
<{extension: }>,
<{defaultuser: }>,
'dynamic',
'friend',
<{context: }>,
<{secret: }>,
'yes',
'no',
<{callerid: }>,
<{cid_number: }>, # this is extension
<{publicclid: }>, # this is public number on PSTN
<{voicemail: }>,
<{voicemail_context: }>,
<{options: }>,
<{beforeNext: }>,
1
);
