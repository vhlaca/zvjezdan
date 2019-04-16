# adding group of extensions / users
# file version 1.0.0
# date: 20.5.2015
#
# changes:

INSERT INTO `asteriskdatabase`.`sipfriends`
(
`name`,
`extension`,
`voicemail`,
`voicemail_context`,
`beforeNext`,
`call_type`,
`gmembers`,
`gtype`
)
VALUES
(
<{name: }>,
<{extension: }>,
<{voicemail: }>,
<{voicemail_context: }>,
<{beforeNext: }>,
2,
<{gmembers: }>, #members have to be separate by * and ath the end should be * too
<{gtype: }> #ringing rule s - sequence, g - group
);
