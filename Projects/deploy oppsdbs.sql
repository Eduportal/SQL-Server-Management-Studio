USE [master]
SET NOCOUNT ON
GO
:r "\\seafresqldba01\DBA_Docs\SQLCMD Scripts\SQLCMD_Header.sql"
GO
:CONNECT FREBASPSQL01\A
GO
:OUT NULL
:SETVAR DataDrive E 
:r "\\seafresqldba01\DBA_Docs\SQLCMD Scripts\Deploy_Operations_DBs.sql"
GO
:OUT STDERR 
:r "\\seafresqldba01\DBA_Docs\SQLCMD Scripts\Validate_Getty_ALL.sql"
GO
:CONNECT FREBGMSSQLA01\A
:OUT NULL
:SETVAR DataDrive E 
:r "\\seafresqldba01\DBA_Docs\SQLCMD Scripts\Deploy_Operations_DBs.sql"
GO
:OUT STDERR 
:r "\\seafresqldba01\DBA_Docs\SQLCMD Scripts\Validate_Getty_ALL.sql"
GO
:CONNECT FREBGMSSQLB01\B
:OUT NULL
:SETVAR DataDrive E 
:r "\\seafresqldba01\DBA_Docs\SQLCMD Scripts\Deploy_Operations_DBs.sql"
GO
:OUT STDERR 
:r "\\seafresqldba01\DBA_Docs\SQLCMD Scripts\Validate_Getty_ALL.sql"
GO
:CONNECT FREBGMSSQLB01\HGA
:OUT NULL
:SETVAR DataDrive E 
:r "\\seafresqldba01\DBA_Docs\SQLCMD Scripts\Deploy_Operations_DBs.sql"
GO
:OUT STDERR 
:r "\\seafresqldba01\DBA_Docs\SQLCMD Scripts\Validate_Getty_ALL.sql"
GO
:CONNECT FREBPCXSQL01\A
:OUT NULL
:SETVAR DataDrive E 
:r "\\seafresqldba01\DBA_Docs\SQLCMD Scripts\Deploy_Operations_DBs.sql"
GO
:OUT STDERR 
:r "\\seafresqldba01\DBA_Docs\SQLCMD Scripts\Validate_Getty_ALL.sql"
GO
:CONNECT FREBSHLSQL01\A
:OUT NULL
:SETVAR DataDrive E 
:r "\\seafresqldba01\DBA_Docs\SQLCMD Scripts\Deploy_Operations_DBs.sql"
GO
:OUT STDERR 
:r "\\seafresqldba01\DBA_Docs\SQLCMD Scripts\Validate_Getty_ALL.sql"
GO
:CONNECT FREBSHWSQL01\A
:OUT NULL
:SETVAR DataDrive E 
:r "\\seafresqldba01\DBA_Docs\SQLCMD Scripts\Deploy_Operations_DBs.sql"
GO
:OUT STDERR 
:r "\\seafresqldba01\DBA_Docs\SQLCMD Scripts\Validate_Getty_ALL.sql"
GO


