--select * From dbaadmin.dbo.Local_ServerEnviro

--exec msdb.sys.sp_dbmmonitorresults 'Getty_Images_US_Inc__MSCRM',1,1

USE DBAADMIN
GO
IF OBJECT_ID('dbasp_DBMirroring_Check') IS NOT NULL
	DROP PROCEDURE	dbasp_DBMirroring_Check
GO
CREATE PROCEDURE	dbasp_DBMirroring_Check
		(
		@ServerName			SYSNAME		= NULL	-- SERVER or NULL = Local Instance.
		,@DBNames			VARCHAR(max)	= NULL	-- Coma Delimited List of Databases or NULL = ALL Mirrored
		)
AS
set nocount on

Declare		@DelayThreashold		INT
		,@miscprint			nvarchar(500)
		,@DBID				int
		,@DBName			sysname
		,@prev_alert_flag		char(1)
		,@need_to_alert			char(1)
		,@save_mirror_alert_date	datetime
		,@save_time_recorded		datetime
		,@save_time_behind		datetime
		,@save_time_diff		int
		,@subject			sysname
		,@message			nvarchar(500)
		,@MS				INT
		,@MSD				SYSNAME
		,@MinBehind			INT

Select		@prev_alert_flag		= 'n'
		--,@DBNames			= 'Getty_Images_US_Inc__MSCRM,Getty_Images_US_Inc_Custom'

IF OBJECT_ID('tempdb..#database_mirroring') IS NOT NULL	
	DROP TABLE #database_mirroring

IF OBJECT_ID('tempdb..#dbmmonitorresults') IS NOT NULL	
	DROP TABLE #dbmmonitorresults

create table #database_mirroring
		( 
		database_id			INT
		,DBName				SYSNAME
		,mirroring_state		INT
		,mirroring_state_desc		SYSNAME
		)

create table #dbmmonitorresults 
		( 
		database_name			SYSNAME
		,role				INT
		,mirroring_state		INT
		,witness_status			INT
		,log_generation_rate		INT
		,unsent_log			INT
		,send_rate			INT
		,unrestored_log			INT
		,recovery_rate			INT
		,transaction_delay		INT
		,transactions_per_sec		INT
		,average_delay			INT
		,time_recorded			DATETIME
		,time_behind			DATETIME
		,local_time			DATETIME
		)

EXEC	msdb.sys.sp_dbmmonitorupdate 

insert into	#database_mirroring 
select		database_id
		,DB_NAME(database_id) DBName
		,mirroring_state
		,CASE mirroring_state
			WHEN	0	THEN 'Suspended'

			WHEN	1	THEN 'Disconnected from the other partner'

			WHEN	2	THEN 'Synchronizing' 

			WHEN	3	THEN 'Pending Failover'

			WHEN	4	THEN 'Synchronized'

			WHEN	5	THEN 'The partners are not synchronized. Failover is not possible now.'

			WHEN	6	THEN 'The partners are synchronized. Failover is potentially possible.' 

			ELSE	'Database is inaccessible or is not mirrored.' 
			END [mirroring_state_desc]
from		msdb.sys.database_mirroring 
where		mirroring_guid is not null
	AND	(
		DB_NAME(database_id) IN (SELECT SplitValue From dbaadmin.dbo.dbaudf_StringToTable(@DBNames,','))
	OR	@DBNames IS NULL
		)
--select * from #database_mirroring

--If exists(select 1 from dbaadmin.dbo.Local_ServerEnviro where env_type = 'mirror_alert_sent')
--   begin
--	Select @save_mirror_alert_date = (select top 1 convert(datetime,env_detail) from dbaadmin.dbo.Local_ServerEnviro where env_type = 'mirror_alert_sent')
--	If datediff(mi,@save_mirror_alert_date, getdate()) > 30
--	   begin
--		Delete from dbaadmin.dbo.Local_ServerEnviro where env_type = 'mirror_alert_sent'
--	   end
--	Else
--	   begin
--		Select @prev_alert_flag = 'y'
--	   end
--   end


DECLARE MirroredDBCursor CURSOR
FOR
-- SELECT QUERY FOR CURSOR
SELECT		*
FROM		#database_mirroring
 

OPEN MirroredDBCursor;
FETCH MirroredDBCursor INTO @DBID,@DBName,@MS,@MSD;
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		---------------------------- 
		---------------------------- BEGIN CHECKS
		DELETE	#dbmmonitorresults
		SET @need_to_alert = 'n'

		--Print 'exec msdb.sys.sp_dbmmonitorresults ' + @DBName + ', 1, 0'
		insert into #dbmmonitorresults exec msdb.sys.sp_dbmmonitorresults @DBName, 1, 0
		--select * from #dbmmonitorresults

		--  Look for problems
		--  no rows in the last 3 minutes
		If (select count(*) from #dbmmonitorresults where time_recorded > getdate()-0.002083) = 0
		   begin
			select * from #dbmmonitorresults
			Select @miscprint = 'DBA Error: No mirror monitor results for DB ' + @DBName + ' for the past 3 minutes'
			Print @miscprint
			raiserror(67016, 16, -1, @miscprint)
			Select @need_to_alert = 'y'
		   end

		--  in a bad state(0=suspended or 3= failing over) - more than 2 times in last 5 minutes
		If (select count(*) from #dbmmonitorresults where time_recorded > getdate()-0.003472 and mirroring_state not in (1,2,4)) > 2
		   begin
			select * from #dbmmonitorresults
			Select @miscprint = 'DBA Error: Mirrored DB ' + @DBName + ' is/was in a bad state over the past 5 minutes'
			Print @miscprint
			raiserror(67016, 16, -1, @miscprint)
			Select @need_to_alert = 'y'
		   end
	
		--  behind more than 45 min (240 min on Thursday)
		SELECT		TOP 1
				@MS			= mirroring_state 
				,@save_time_recorded	= time_recorded 
				,@save_time_behind	= time_behind 
				,@save_time_diff	= DATEDIFF(minute,time_behind,time_recorded)
		FROM		#dbmmonitorresults
		ORDER BY 	time_recorded desc

		-- DISCONNECTED FOR MORE THAN 10 MINUTS FROM COPY DB
		IF @MS = 1 AND @save_time_diff  >= 10
		   begin
			select * from #dbmmonitorresults
			Select @miscprint = 'Networking Error: Mirrored DB ' + @DBName + ' is Disconnected from Partner and is ' + CAST(@MinBehind AS VarChar(10)) + ' Behind. Contact Networking Team.'
			Print @miscprint
			raiserror(67016, 16, -1, @miscprint)
			Select @need_to_alert = 'y'
		   end

		 If @save_time_diff > CASE  datepart(dw, getdate()) WHEN 5 THEN 240 ELSE 45 END
		   begin
			select * from #dbmmonitorresults
			Select @miscprint = 'DBA Error: Mirrored DB ' + @DBName + ' Synchronization is behind by '+CAST(@save_time_diff AS VarChar(50))+' minutes.'
			Print @miscprint
			raiserror(67016, 16, -1, @miscprint)
			Select @need_to_alert = 'y'
		   end

		If @need_to_alert = 'y'
		BEGIN
			IF @prev_alert_flag = 'n'
			BEGIN
				insert into dbaadmin.dbo.Local_ServerEnviro values ('mirror_alert_sent', getdate())

				Print ''
				Select @miscprint = 'DBA ERROR: Mirror Problems found.  Alerting for server ' + @@servername + ', Database ' + @DBName
				Print @miscprint

				Select @subject = 'SQL Mirroring Alert for Server ' + @@servername
				Select @message = 'For server ' + @@servername + ' (last error captured): ' + @miscprint

   				Print 'Gmail being sent.'
				EXEC dbaadmin.dbo.dbasp_sendmail 
				@recipients = 'jdtorpedo58@gmail.com;steve.ledridge@gmail.com', 
				@subject = @subject,
				@message = @message
			END
			ELSE
			BEGIN
				Print ''
				Select @miscprint = 'DBA Note: Problems found and recently alerted for server ' + @@servername + ', Database ' + @DBName
				Print @miscprint
			END
		END
		ELSE IF @prev_alert_flag = 'y'
		BEGIN
			Print ''
			Select @miscprint = 'DBA Note: Recent mirroring issues for server ' + @@servername + ' are no longer present'
			Print @miscprint
			Delete from dbaadmin.dbo.Local_ServerEnviro where env_type = 'mirror_alert_sent'
	
			Select @subject = 'SQL Mirroring Alert Cleared for Server ' + @@servername
			Select @message = 'For server ' + @@servername + ' Previous mirroring issue has been cleared'

   			Print 'Gmail being sent.'
			EXEC dbaadmin.dbo.dbasp_sendmail 
			@recipients = 'jdtorpedo58@gmail.com;steve.ledridge@gmail.com', 
			@subject = @subject,
			@message = @message
		END
		Else
		BEGIN
			Print ''
			Select @miscprint = 'DBA Note: No Mirroring related issues found for Database '+@DBName+' on Server ' + @@servername
			Print @miscprint
		END


		---------------------------- CURSOR LOOP BOTTOM
		----------------------------
	END
 	FETCH NEXT FROM MirroredDBCursor INTO @DBID,@DBName,@MS,@MSD;
END
CLOSE MirroredDBCursor;
DEALLOCATE MirroredDBCursor;


--  Set the mirror tracking record  (monitored by the central server) 
If exists (select 1 from dbaadmin.dbo.Local_ServerEnviro where env_type = 'check_mirror')
   begin
	Update dbaadmin.dbo.Local_ServerEnviro set env_detail = getdate() where env_type = 'check_mirror'
   end
Else
   begin
	Insert into dbaadmin.dbo.Local_ServerEnviro values('check_mirror', getdate())
   end


GO



--If (select count(*) from #database_mirroring) > 0
--   begin
--	start01:
--	Select @DBID = (select top 1 database_id from #database_mirroring)
--	Select @DBName = db_name(@DBID)
	



--	--  check for more rows to process
--	delete from #database_mirroring where database_id = @DBID
--	If (select count(*) from #database_mirroring) > 0
--	   begin
--		delete from #dbmmonitorresults
--		goto start01
--	   end
--   end
--Else
--   begin
--	--  Mirroring has been removed
--	Select @miscprint = 'DBA Error: Mirroring has been removed from server ' + @@servername
--	Print @miscprint
--	raiserror(67016, 16, -1, @miscprint)
--	Select @need_to_alert = 'y'
--   end

   
   



--exec sp_whoIsActive
--exec sp_who2 active
