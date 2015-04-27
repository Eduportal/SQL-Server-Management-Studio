DECLARE @Out	VarChar(8000)

DECLARE TableBCPCursor CURSOR
FOR
select 'exec xp_CmdShell ''"C:\Program Files\Microsoft SQL Server\90\Tools\Binn\bcp.exe" ' /* path to BCP.exe */
    +  QUOTENAME(DB_NAME())+ '.' /* Current Database */
    +  QUOTENAME(SCHEMA_NAME(SCHEMA_ID))+'.'            
    +  QUOTENAME(name)  
    +  ' out J:\PurgedDataBackup\'  /* Path where BCP out files will be stored */
    +  REPLACE(SCHEMA_NAME(schema_id),' ','') + '_' 
    +  REPLACE(name,' ','') 
    + '.dat -T -E -SFREPSQLRYLB01 -n''' /* ServerName, -E will take care of Identity, -n is for Native Format */
from sys.tables
where name IN
(
'a_SAVE_preserved_calc_result_prior_to_2009_05_31'
,'a_SAVE_preserved_calc_result_prior_to_2010_09_30'
,'a_SAVE_preserved_calc_result_prior_to_2011_08_31'
,'a_SAVE_preserved_calc_result_prior_to_2012_06_30'
)
OPEN TableBCPCursor; 
FETCH TableBCPCursor INTO @OUT;
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		---------------------------- 
		---------------------------- CURSOR LOOP TOP
	
		PRINT	@OUT
		SET		@Out = NULL

		---------------------------- CURSOR LOOP BOTTOM
		----------------------------
	END
 	FETCH NEXT FROM TableBCPCursor INTO @OUT;
END
CLOSE TableBCPCursor;
DEALLOCATE TableBCPCursor;
GO
PRINT ''
PRINT ''
PRINT ''
PRINT ''
PRINT ''
PRINT ''


declare @Destdbname sysname
DECLARE @Out		VarChar(8000)
set @Destdbname = 'gins_master' /* Destination Database Name where you want to Bulk Insert in */


DECLARE TableBCPCursor CURSOR
FOR
select 'BULK INSERT ' 
/*Remember Tables must be present on destination database */ 
+ QUOTENAME(@Destdbname) + '.' 
+ QUOTENAME(SCHEMA_NAME(SCHEMA_ID)) 
+ '.' + QUOTENAME(name) 
+ ' from ''J:\PurgedDataBackup\' /* Change here for bcp out path */ 
+ REPLACE(SCHEMA_NAME(schema_id), ' ', '') + '_' + REPLACE(name, ' ', '') 
+ '.dat'' with ( KEEPIDENTITY, DATAFILETYPE = ''native'', TABLOCK )' 
+ CHAR(13)+CHAR(10) 
+ 'print ''Bulk insert for ' + REPLACE(SCHEMA_NAME(schema_id), ' ', '') + '_' + REPLACE(name, ' ', '') + ' is done... ''' 
+ CHAR(13)+CHAR(10) + 'go'
   from sys.tables
   where name IN
(
'a_SAVE_preserved_calc_result_prior_to_2009_05_31'
,'a_SAVE_preserved_calc_result_prior_to_2010_09_30'
,'a_SAVE_preserved_calc_result_prior_to_2011_08_31'
,'a_SAVE_preserved_calc_result_prior_to_2012_06_30'
)
OPEN TableBCPCursor; 
FETCH TableBCPCursor INTO @OUT;
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		---------------------------- 
		---------------------------- CURSOR LOOP TOP
	
		PRINT	@OUT
		SET		@Out = NULL

		---------------------------- CURSOR LOOP BOTTOM
		----------------------------
	END
 	FETCH NEXT FROM TableBCPCursor INTO @OUT;
END
CLOSE TableBCPCursor;
DEALLOCATE TableBCPCursor;
GO


/*
exec xp_CmdShell '"C:\Program Files\Microsoft SQL Server\90\Tools\Binn\bcp.exe" [gins_master].[dbo].[a_SAVE_preserved_calc_result_prior_to_2009_05_31] out J:\PurgedDataBackup\dbo_a_SAVE_preserved_calc_result_prior_to_2009_05_31.dat -T -E -SFREPSQLRYLB01 -n'
exec xp_CmdShell '"C:\Program Files\Microsoft SQL Server\90\Tools\Binn\bcp.exe" [gins_master].[dbo].[a_SAVE_preserved_calc_result_prior_to_2010_09_30] out J:\PurgedDataBackup\dbo_a_SAVE_preserved_calc_result_prior_to_2010_09_30.dat -T -E -SFREPSQLRYLB01 -n'
exec xp_CmdShell '"C:\Program Files\Microsoft SQL Server\90\Tools\Binn\bcp.exe" [gins_master].[dbo].[a_SAVE_preserved_calc_result_prior_to_2011_08_31] out J:\PurgedDataBackup\dbo_a_SAVE_preserved_calc_result_prior_to_2011_08_31.dat -T -E -SFREPSQLRYLB01 -n'
exec xp_CmdShell '"C:\Program Files\Microsoft SQL Server\90\Tools\Binn\bcp.exe" [gins_master].[dbo].[a_SAVE_preserved_calc_result_prior_to_2012_06_30] out J:\PurgedDataBackup\dbo_a_SAVE_preserved_calc_result_prior_to_2012_06_30.dat -T -E -SFREPSQLRYLB01 -n'
*/ 
 
 
 
/* 
BULK INSERT [gins_master].[dbo].[a_SAVE_preserved_calc_result_prior_to_2009_05_31] from 'J:\PurgedDataBackup\dbo_a_SAVE_preserved_calc_result_prior_to_2009_05_31.dat' with ( KEEPIDENTITY, DATAFILETYPE = 'native', TABLOCK )
print 'Bulk insert for dbo_a_SAVE_preserved_calc_result_prior_to_2009_05_31 is done... '
go
BULK INSERT [gins_master].[dbo].[a_SAVE_preserved_calc_result_prior_to_2010_09_30] from 'J:\PurgedDataBackup\dbo_a_SAVE_preserved_calc_result_prior_to_2010_09_30.dat' with ( KEEPIDENTITY, DATAFILETYPE = 'native', TABLOCK )
print 'Bulk insert for dbo_a_SAVE_preserved_calc_result_prior_to_2010_09_30 is done... '
go
BULK INSERT [gins_master].[dbo].[a_SAVE_preserved_calc_result_prior_to_2011_08_31] from 'J:\PurgedDataBackup\dbo_a_SAVE_preserved_calc_result_prior_to_2011_08_31.dat' with ( KEEPIDENTITY, DATAFILETYPE = 'native', TABLOCK )
print 'Bulk insert for dbo_a_SAVE_preserved_calc_result_prior_to_2011_08_31 is done... '
go
BULK INSERT [gins_master].[dbo].[a_SAVE_preserved_calc_result_prior_to_2012_06_30] from 'J:\PurgedDataBackup\dbo_a_SAVE_preserved_calc_result_prior_to_2012_06_30.dat' with ( KEEPIDENTITY, DATAFILETYPE = 'native', TABLOCK )
print 'Bulk insert for dbo_a_SAVE_preserved_calc_result_prior_to_2012_06_30 is done... '
go
*/

