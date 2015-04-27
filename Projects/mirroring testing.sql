--Check if the master key already present. 
USE Master
go
select * from sys.symmetric_keys
 
--Drop the existing Master Key
Use MASTER
GO
DROP MASTER KEY
Go
 
--Create Master Key in Master Database
USE MASTER
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'G3++yIm@g3s';
go
 
**Note :  TypeStrongPassword should remain same throughout the setup.
 
--Create Server Certificate in the Master Database encrypted with master key (created above) which would be used to create USER database encryption key.
 
USE Master;
GO
CREATE CERTIFICATE <MyDB_Mirror_Server_Cert> WITH SUBJECT = 'SQL TDE CERT'
Go
 
*Note : Replace <MyDB_Mirror_Server_Cert> with the name of Certificate. You can specify any name of your choice. Also you can change the SUBJECT to a more meaningful description.
 
-- Now in the User database, create a Database Encryption Key. In my test scenario, I'm dropping the existing Database Encryption Key if already exist and not in use.
-- Information about  the database encryption keys is stored in sys.dm_database_encryption_keys.
 
USE <User Database>
go
DROP DATABASE ENCRYPTION KEY
go
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_128
ENCRYPTION BY SERVER CERTIFICATE <MyDB_Mirror_Server_Cert>
GO
--Enabling Transparent Database Encryption for the USER Database
USE master;
GO
ALTER DATABASE <User Database> SET ENCRYPTION ON
GO
 
-- Now Backup master key immediately
USE master;
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<TypeStrongPassword>';
BACKUP MASTER KEY TO FILE = '<Full path and exportmasterkey filename>’
    ENCRYPTION BY PASSWORD = '<TypeStrongPassword>';
GO
 
**Note: Replace <Full path and exportmasterkey filename> with full path and export file name. Also Replace <TypeStrongPassword> with the actual password use to encrypt the master key.
 
-- Now Backup Server certificate as well
 
BACKUP CERTIFICATE <MyDB_Mirror_Server_Cert> TO FILE = '<Full path and export cert filename>'
    WITH PRIVATE KEY ( FILE = '<Full path and export filename _key>' ,
    ENCRYPTION BY PASSWORD = '<TypeStrongPassword>');
GO
 
-- Perform Full database backup of the Principal database
 
 
On the Mirrored Site
====================
/* On Mirror Server, restore the master key from backup performed from principal site. Since the database master key is a symmetric key used to protect the private keys of certificates and asymmetric keys that are present in the database. Information about the database master key is visible in the sys.symmetric_keys catalog view.
 
If the database master key already exists and not in use, drop the existing database master key (if any) and restore it from backup taken from principal site.
 
In my Test Scenario, I'm dropping the existing master key and restoring the master key from backup taken from principal site */
 
use master
go
drop master key
go
RESTORE MASTER KEY
    FROM FILE = ' Full path and exportmasterkey filename>'
    DECRYPTION BY PASSWORD = '<TypeStrongPassword>'
    ENCRYPTION BY PASSWORD = '<TypeStrongPassword>';
GO
 
-- Create server certificate on the mirror site using the PRIVATE KEY backed up from principal site
 
USE Master;
GO
DROP CERTIFICATE <MyDB_Mirror_Server_Cert>
go
 
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<TypeStrongPassword>'
 
CREATE CERTIFICATE <MyDB_Mirror_Server_Cert>    
FROM FILE = '<Full path and export cert filename>'    
WITH PRIVATE KEY (FILE = '<Full path and export filename _key>',    
DECRYPTION BY PASSWORD = '<TypeStrongPassword>');
GO
 
-- Restore the database from backup with NORECOVERY
 
RESTORE DATABASE <User Database>
   FROM disk = 'C:\Program Files\Microsoft SQL Server\MSSQL10.x\MSSQL\Backup\<Backup_FileName>.bak'
   WITH NORECOVERY,
      MOVE '<Primary FileGroup>' TO
'C:\Program Files\Microsoft SQL Server\MSSQL10.y\MSSQL\DATA\<PrimaryDB_File>.mdf',
      MOVE '<Logical File name of LogFile>'
TO 'C:\Program Files\Microsoft SQL Server\MSSQL10.y\MSSQL\DATA\<Log_File>.ldf'
 
Where x = Instance ID of the Principle Server and y = Instance ID of Mirror Server
 
-- On the Mirrored Site, drop the existing mirroring endpoint and create the database mirroring endpoint as follows
 
DROP ENDPOINT <endpoint_mirroring>
 
CREATE ENDPOINT <endpoint_mirroring>
    STATE = STARTED
    AS TCP ( LISTENER_PORT = 7023 )
    FOR DATABASE_MIRRORING (ROLE=PARTNER);
GO
 
-- Verify that the endpoint is properly configured and is in state "STARTED"
 
select * from sys.database_mirroring_endpoints
 
--On the primary site, drop the existing mirroring endpoint and create the database mirroring endpoint as follows
 
DROP ENDPOINT <endpoint_mirroring>
 
CREATE ENDPOINT <endpoint_mirroring>
    STATE = STARTED
    AS TCP ( LISTENER_PORT = 7022 )
    FOR DATABASE_MIRRORING (ROLE=PARTNER);
GO
 
-- Verify that the endpoint is properly configured and is in state "STARTED"
 
select * from sys.database_mirroring_endpoints
 
-- First set the principal server as partner on the mirror database
 
ALTER DATABASE <User Database> SET PARTNER = 'TCP://<FQDN of the Principal Server>:7022'
 
 
-- Now set the Mirror server as partner on the principal database
 
ALTER DATABASE <User Database> SET PARTNER = 'TCP://<FQDN of the Mirror Server>:7023'
 