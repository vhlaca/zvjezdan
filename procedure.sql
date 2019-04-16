-- creating of stored procedures needed for integration
-- file version 1.0.1
-- date: 03.06.2015
-- 
-- changes:
-- 03.06.2015 1.0.1
-- Changed GetExternalPath for processing of public number, prefix and sufix.
-- Changed GetExternalPath takes into account min i max pattern length
-- Changed GetExternalPath to record errors using stored procedure SetDialplanError
-- Changed GetSIPUserWithOptions to record errors using stored procedureSetDialplanError
-- Added procedure for writing down errors to SetDialplanError
-- Added procedure for connecting CDR records and call recording SetRecorded

-- Procedure to get outgoing trunk
DELIMITER $$
CREATE DEFINER=`mySQLadmin`@`%` PROCEDURE `GetExternalPath`(
	in p_dialed nvarchar(20), 
	in p_dialer nvarchar (20)
)
BEGIN
DECLARE duzina INT;
DECLARE p_trunk VARCHAR(20);
DECLARE p_options VARCHAR(45);
DECLARE p_recorded VARCHAR(5);
DECLARE p_publicnum VARCHAR(45);
DECLARE p_prefix VARCHAR(5);
DECLARE p_sufix VARCHAR(5);
DECLARE found_rows int;
SET duzina = char_length(p_dialed);

SELECT trunk, prefix, sufix, sipfriends.options, sipfriends.record, sipfriends.publicclid FROM trunk_pattern 
INNER JOIN pattern_type
ON trunk_pattern.pattern_type = pattern_type.id
INNER JOIN pattern_type_allowed
ON pattern_type.id= pattern_type_allowed.id_pattern
INNER JOIN sipfriends
ON pattern_type_allowed.id_caller = sipfriends.id
WHERE concat(pattern,substring(p_dialed,char_length(pattern)+1))=p_dialed AND min<=duzina AND max>=duzina AND sipfriends.cid_number=p_dialer
ORDER BY char_length(pattern) DESC LIMIT 1
INTO p_trunk, p_prefix, p_sufix, p_options, p_recorded, p_publicnum
;
SET found_rows = FOUND_ROWS();

IF found_rows = 1 THEN
	SELECT 
		'subDialOut' AS sub,
		IFNULL(p_dialed,'0') as dialed,
		'1' AS priority, 
		CONCAT('(',IFNULL(p_options,'')) AS options,
        IFNULL(p_trunk,'') AS trunk,
        IFNULL(p_recorded,'') AS recorded,
        IFNULL(p_prefix,'') AS prefix,
        IFNULL(p_sufix,'') AS sufix,
        CONCAT(IFNULL(p_publicnum,''),')') as publicnum;
ELSE
	CALL SetDialplanError(p_dialer,p_dialed,'Dialout pattern not defined or dialer has no rights. (GetExternalPath)');
    SELECT
		'subError' AS sub,
		IFNULL(p_dialed,'0') as extension,
		'1' AS priority;
END IF;

END$$
DELIMITER ;

-- procedure for translation to SIP user
DELIMITER $$
CREATE DEFINER=`mySQLadmin`@`%` PROCEDURE `GetSIPUserWithOptions`(
	in p_extension nvarchar(4), 
	in p_dialer nvarchar (20)
)
BEGIN
    DECLARE p_name nvarchar(20);
    DECLARE p_voicemail_context nvarchar(45);
    DECLARE p_voicemail nvarchar(45);
    DECLARE p_beforeNext int(11);
    DECLARE p_options nvarchar(45);
    DECLARE p_record nvarchar(5);
	DECLARE p_options_dialer nvarchar(45);
    DECLARE p_record_dialer nvarchar(5);
    DECLARE p_call_type INT(11);
    DECLARE p_goSub nvarchar(45);
    DECLARE p_mailbox nvarchar(40);
    DECLARE p_gmembers nvarchar (256);
    DECLARE p_gtype nvarchar (256);
    DECLARE found_rows INT;
    DECLARE p_conftype nvarchar(20);
    DECLARE p_confusertype nvarchar(20);
    DECLARE p_forwardedto nvarchar(20);
    
	SELECT name, voicemail_context, voicemail, beforeNext, options, record, sipfriends.call_type, cdr_call_type.goSub, mailbox, gmembers, gtype, conftype, confusertype, forwardedto
    INTO p_name, p_voicemail_context, p_voicemail, p_beforeNext, p_options, p_record, p_call_type, p_goSub, p_mailbox, p_gmembers, p_gtype, p_conftype, p_confusertype, p_forwardedto
    FROM sipfriends 
    INNER JOIN cdr_call_type ON sipfriends.call_type = cdr_call_type.id
    WHERE extension = p_extension OR publicclid = p_extension;
    SET found_rows = FOUND_ROWS();
    
    IF found_rows = 1 THEN
		-- CALL TYPE EXTENSION
        IF p_call_type='1' THEN
			SELECT options, record 
			INTO p_options_dialer, p_record_dialer
			FROM sipfriends
			WHERE cid_number = p_dialer;

			SET p_options = CONCAT(IFNULL(p_options,''),IFNULL(p_options_dialer,''));
		
			IF p_record_dialer != p_record then
				SET p_record = 'yes';
			END IF;

			SELECT 
				IFNULL(p_goSub,'subError') AS sub,
				IFNULL(p_extension,'0') as extension,
				'1' AS priority, 
				'(SIP' as technology,
				IFNULL(p_name,'') as name, 
				IFNULL(p_voicemail_context,'') as vm_context, 
				IFNULL(p_voicemail,'') as vm,
				IFNULL(p_beforeNext,'') as wait,
				IFNULL(p_options,'') as options,
				IFNULL(p_record,'') as record,
                '' as groupname,
				CONCAT(IFNULL(p_forwardedto,''),')')as forwarded;
		END IF;
        
        -- CALL TYPE GROUP
        IF p_call_type='2' THEN
   			SELECT options, record 
			INTO p_options_dialer, p_record_dialer
			FROM sipfriends
			WHERE name = p_dialer;

			SET p_options = CONCAT(IFNULL(p_options,''),IFNULL(p_options_dialer,''));
		
			IF p_record_dialer != p_record then
				SET p_record = 'yes';
			END IF;

			SELECT 
				IFNULL(p_goSub,'subError') AS sub,
				IFNULL(p_extension,'0') as extension,
				'1' AS priority, 
				'(SIP' as technology,
				IFNULL(p_gmembers,'') as gmembers, 
				IFNULL(p_voicemail_context,'') as vm_context, 
				IFNULL(p_voicemail,'') as vm,
				IFNULL(p_beforeNext,'') as wait,
				IFNULL(p_options,'') as options,
				IFNULL(p_record,'') as record,
				CONCAT(IFNULL(p_gtype,''),')') as type;
		END IF;
        
        -- CALL TYPE FAX
        IF p_call_type='3' THEN
			SELECT 
				IFNULL(p_goSub,'subError') AS sub,
				IFNULL(p_extension,'0') as extension,
				'1' AS priority, 
				CONCAT('(',IFNULL(p_mailbox,'')) as fromMail,
				IFNULL(p_name,'') as fromName, 
				CONCAT(IFNULL(p_options,''),')') as toMail;
		END IF;
        
        -- CALL TYPE CONFERENCE
		IF p_call_type='5' THEN 
			SELECT 
				IFNULL(p_goSub,'subError') AS sub,
				IFNULL(p_extension,'0') as extension,
				'1' AS priority, 
				CONCAT('(',IFNULL(p_confusertype,'')) as userType,
				-- IFNULL(p_name,'') as fromName, 
				CONCAT(IFNULL(p_conftype,''),')') as bridgeType
                ;
		END IF;
	ELSE
		CALL SetDialplanError(p_dialer,p_extension,'Extension not found. (GetSIPUserWithOptions)');
        SELECT 
				'subError' AS sub,
				IFNULL(p_extension,'0') as extenion,
				'1' AS priority;
    END IF;
    
END$$
DELIMITER ;

-- procedure for writting down errors
DELIMITER $$
CREATE DEFINER=`mySQLadmin`@`%` PROCEDURE `SetDialplanError`(
	p_from varchar(45),
    p_to varchar(45),
    p_desription varchar(256)
)
BEGIN

INSERT INTO `asteriskdatabase`.`dialplanerrors`
(
`from`,
`to`,
`description`)
VALUES
(
p_from,
p_to,
p_desription);

END$$

DELIMITER ;

-- procedure for setting "forward all calls" 
DELIMITER $$
CREATE DEFINER=`mySQLadmin`@`%` PROCEDURE `SetForwardAll`(
	in p_forward nvarchar (20), 
	in p_forwardTo nvarchar (20)
)
BEGIN
	UPDATE sipfriends
    SET forwardedto=p_forwardTo, beforeNext=1
    WHERE name=p_forward
    LIMIT 1;
END$$

DELIMITER ;

-- procedure for setting after how many seconds the call will be forwarded
DELIMITER $$
CREATE DEFINER=`mySQLadmin`@`%` PROCEDURE `SetForwardBDA`(
	in p_forward nvarchar (20), 
	in p_forwardTo nvarchar (20),
    in p_timer int
)
BEGIN
	UPDATE sipfriends
    SET forwardedto=p_forwardTo, beforeNext=p_timer
    WHERE name=p_forward
    LIMIT 1;
END$$

DELIMITER ;

-- procedure to connect CDR records with recorded calls
DELIMITER $$
CREATE DEFINER=`mySQLadmin`@`%` PROCEDURE `SetRecorded`(
	in p_filename nvarchar (120),
    in p_extension int
    )
BEGIN

DECLARE uniqueID nvarchar(100);
DECLARE minus int;

SET uniqueID = p_filename;

SET minus=instr(uniqueID,'-');
WHILE minus != 0 DO
	SET uniqueID=SUBSTRING(uniqueID,minus+1);
    SET minus=instr(uniqueID,'-');
END WHILE;

SET uniqueID = SUBSTRING(uniqueID,1,length(uniqueID)-p_extension);

UPDATE cdr 
SET recorded=1
WHERE cdr.uniqueid=uniqueID;

INSERT INTO `asteriskdatabase`.`recorded_files`
(
`recorded_filename`,
`call_id`
)
VALUES
(
p_filename,
uniqueID
);

END$$
DELIMITER ;

-- procedure for removing forwarding
DELIMITER $$
CREATE DEFINER=`mySQLadmin`@`%` PROCEDURE `SetRemoveForward`(
	in p_forward nvarchar (20)
)
BEGIN
	UPDATE sipfriends
    SET forwardedto=NULL, beforeNext=NULL
    WHERE name=p_forward
    LIMIT 1;
END$$

DELIMITER ;
-- procedure for hint
DELIMITER $$
CREATE DEFINER=`mySQLadmin`@`%` PROCEDURE `GetSIPUser`(in p_extension nvarchar(4))
BEGIN
	SELECT name FROM asteriskdatabase.sipfriends WHERE extension = p_extension;
END$$

DELIMITER ;