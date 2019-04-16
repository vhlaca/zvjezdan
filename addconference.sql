# adding conference bridge
# file version 1.0.0
# date: 20.5.2015
#
# changes:

INSERT INTO `asteriskdatabase`.`sipfriends`
(
`name`,
`extension`,
`directmedia`,
`nat`,
`call_type`
)
VALUES
<{name: }>,
<{extension: }>,
'yes',
'no',
5);
