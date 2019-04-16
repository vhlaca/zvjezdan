# adding fax user to database
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
`mailbox`,
`options`,
`call_type`
)
VALUES
<{name: }>,
<{extension: }>,
'yes',
'no',
<{mailbox: }>, #FROM mail address
<{options: }> #TO mail address
3);
