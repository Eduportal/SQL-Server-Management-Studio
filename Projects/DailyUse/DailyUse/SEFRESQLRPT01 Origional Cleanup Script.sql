use master
go

select @@servername, getdate()
go


 
/***************************************************************************************
CHANGE DATABASE OWNER for Database: SoundTrackDB
***************************************************************************************/
USE master
go
 
ALTER AUTHORIZATION ON DATABASE::SoundTrackDB TO sa;
go
 



/**************************************************************
Remove users from SoundTrackDB sysusers table
**************************************************************/
USE SoundTrackDB
go
                                                                                                                                                                                                                                                                
 
---------------------------------------------------------------------------------------------------------------------------
--  Use the Following code to DROP all Users from 'SoundTrackDB'
---------------------------------------------------------------------------------------------------------------------------
If exists (select 1 from [SoundTrackDB].sys.assemblies where principal_id > 4 and principal_id < 16384)
   begin
      Declare @save_aname sysname
      Declare @cmd nvarchar(500)
      drop_user01:
      Select @save_aname = (select top 1 name from [SoundTrackDB].sys.assemblies where principal_id > 4 and principal_id < 16384)
      Select @cmd = 'ALTER AUTHORIZATION ON Assembly::[' + @save_aname + '] TO dbo;'
      Print @cmd
      Exec (@cmd)
      If exists (select 1 from [SoundTrackDB].sys.assemblies where principal_id > 4 and principal_id < 16384)
         begin
            goto drop_user01
         end
   end
go
 
If exists (select 1 from [SoundTrackDB].sys.schemas where principal_id > 4 and principal_id < 16384)
   begin
      Declare @save_sname sysname
      Declare @cmd nvarchar(500)
      drop_user02:
      Select @save_sname = (select top 1 name from [SoundTrackDB].sys.schemas where principal_id > 4 and principal_id < 16384)
      Select @cmd = 'ALTER AUTHORIZATION ON SCHEMA::[' + @save_sname + '] TO dbo;'
      Print @cmd
      Exec (@cmd)
      If exists (select 1 from [SoundTrackDB].sys.schemas where principal_id > 4 and principal_id < 16384)
         begin
            goto drop_user02
         end
   end
go
 


If exists (select 1 from [SoundTrackDB].sys.database_principals where is_fixed_role = 0 and type = 'R' AND owning_principal_id != 1)
   begin
      Declare @save_rname sysname
      Declare @cmd nvarchar(500)
      drop_user03:
      Select @save_rname = (select top 1 name from [SoundTrackDB].sys.database_principals where is_fixed_role = 0 and type = 'R' AND owning_principal_id != 1)
      Select @cmd = 'ALTER AUTHORIZATION ON ROLE::[' + @save_rname + '] TO dbo;'
      Print @cmd
      Exec (@cmd)
      If exists (select 1 from [SoundTrackDB].sys.database_principals where is_fixed_role = 0 and type = 'R' AND owning_principal_id != 1)
         begin
            goto drop_user03
         end
   end
go


If exists (select 1 from [SoundTrackDB].sys.database_principals where principal_id > 4 and type <> 'R')
   begin
      Declare @save_uname sysname
      Declare @cmd nvarchar(500)
      drop_user03:
      Select @save_uname = (select top 1 name from [SoundTrackDB].sys.database_principals where principal_id > 4 and type <> 'R')
      Select @cmd = 'DROP USER [' + @save_uname + '];'
      Print @cmd
      Exec (@cmd)
      If exists (select 1 from [SoundTrackDB].sys.database_principals where principal_id > 4 and type <> 'R')
         begin
            goto drop_user03
         end
   end
go
 
If exists (select 1 from [SoundTrackDB].sys.schemas where principal_id > 4 and principal_id < 16384)
   begin
      Declare @save_uname sysname
      Declare @save_schema_id int
      Declare @cmd nvarchar(500)
      Select @save_schema_id = 4
      drop_schema04:
      Select @save_schema_id = (select top 1 schema_id from [SoundTrackDB].sys.schemas where schema_id > @save_schema_id and schema_id < 16380 order by schema_id)
      Select @save_uname = (select name from [SoundTrackDB].sys.schemas where schema_id = @save_schema_id)
      If (select count(*) from [SoundTrackDB].sys.objects where schema_id = @save_schema_id) = 0
         begin
            Select @cmd = 'DROP SCHEMA [' + @save_uname + '];'
            Print @cmd
            Exec (@cmd)
         end
      If (select count(*) from [SoundTrackDB].sys.schemas where schema_id > @save_schema_id and schema_id < 16380) > 0
         begin
            goto drop_schema04
         end
   end
go
 



 
/****************************************************
Set database options for database SoundTrackDB
****************************************************/
 
 
 
ALTER DATABASE [SoundTrackDB] SET RECOVERY SIMPLE WITH NO_WAIT
go

ALTER DATABASE [SoundTrackDB] SET MULTI_USER  WITH NO_WAIT
go 

EXEC sp_dbcmptlevel 'SoundTrackDB', 90
go

select @@servername, getdate()
go


