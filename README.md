# zvjezdan
Zvjezdan is project in which goal was to control users, extensions and call treatment through database tables. The development was done druing 2015 and 2016 therefore features should be checked if they work in current version of asterisk.

## Used software
- Ubuntu Linux
- Asterisk
- mySQL 
- email client

## Files included
- All configuration files of asteris (*.conf) with requiered changes for this setup to work
- Instruction how to install asterisk together with prerequisites: instruction asteriska installation.txt
- SQL scripts:
  - to create needed tables: tables 1.0.2.sql
  - to create needed stored procedures: procedure.sql
  - to add user: adduser.sql
  - to add group: addgroup.sql
  - to add fax extension: addfax.sql
  - to add conference bridge: addconference.sql
 - script for moving recording from RAMDISK to hard disk: mvrecording
 - PERL script to forward fax to email: sendfax2mail.pl
 
