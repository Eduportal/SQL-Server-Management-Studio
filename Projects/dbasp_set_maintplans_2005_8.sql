
USE [dbaadmin]
GO

if OBJECT_ID('[dbo].[dbasp_set_maintplans]') IS NOT NULL
	DROP PROCEDURE [dbo].[dbasp_set_maintplans]
GO
CREATE PROCEDURE [dbo].[dbasp_set_maintplans]

/***************************************************************
 **  Stored Procedure dbasp_set_maintplans                  
 **  Written by Jim Wilson, Getty Images                
 **  August 05, 2004                                      
 **  
 **  This sproc is set up to;
 ** 
 **  Create and/or reset the standard maintenance plans used
 **  for SQL DBA daily and weekly maintenance processing.
 **  In normal SQL DBA maintenance processing, maintenance plans
 **  are only used as a means to obtain a list of databases to process. 
 ***************************************************************/
  as
  SET NOCOUNT ON

--	======================================================================================
--	Revision History
--	Date		Author     		Desc
--	==========	====================	=============================================
--	08/05/2004	Jim Wilson		New process.
--	08/17/2004	Jim Wilson		Added check to the backup_nocheck table.
--	02/15/2006	Jim Wilson		Modified for sql2005.  This process uses the legacy tables in msdb.
--	02/11/2008	Jim Wilson		Added skip for DB's not online.
--	04/30/2008	Jim Wilson		Added fix for dbaadmin and systeminfo owner and recovery option.
--	12/15/2008	David Spriggs		Added code for new No_Check table.
--	10/09/2009	Jim Wilson		Updated code for DB systeminfo to DEPLinfo.
--	05/20/2010	Steve Ledridge		Complete Rewrite.
--						* Added Calls to dbasp_LogEvent which replaced all print statements
--						* Added Section to Force Recovery Plan based on Logic and No_Check
--							NEW No_Check Type : ForcedRecoveryModel
--							formated as follows:
--								[NoCheck_type]	= ForcedRecoveryModel
--								[detail01]	= Database Name
--								[detail02]	= 'NO' (Do Not Change), 'YES' (Force to Simple), 'VALUE' (USE detail03 Value)
--								[detail03]	= NULL,'SIMPLE' (same as Using 'YES' in detail02),'FULL','BULK-LOGED'
--						* Added population of tranlog plan
--						* Re-wrote both Sections for Adding Pland and Plan Members
--							to use a Single SET-Based Insert of missing records.
--						* Changed Plan Member Logic to start by flushing all members out of
--							the standard plans before re-inserting them to make sure they
--							dont exist in plans that they shouldnt belong to. This assumes
--							that the no_check table represents databases that should not
--							be backed up at all rather than left as they are. If we want
--							to force mebers into groups that are not selected by the logic
--							we will need to change the way the 'BACKUP' NoCheck_Type is used.
--
--	======================================================================================

-----------------  declares  ------------------
DECLARE
	 @miscprint		nvarchar(4000)
	,@PlanID 		uniqueidentifier
	,@PlanID_full		uniqueidentifier
	,@PlanID_simple		uniqueidentifier
	,@PlanID_tranlog	uniqueidentifier
	,@cmd			nvarchar(1000)
	,@ForcedRecoveryScript	varchar(max)

DECLARE
	 @cu10DBName		sysname
	,@cu10DBId		smallint
	,@cu10DBStatus		int

DECLARE
	 @cu11DBName		sysname
	,@cu11DBId		smallint
	,@cu11DBStatus		int

--------------------------------------------------
-- DECLARE ALL cE VARIABLES AT HEAD OF PROCCESS --
--------------------------------------------------
DECLARE	@cEModule		sysname
	,@cECategory		sysname
	,@cEEvent		sysname
	,@cEGUID		uniqueidentifier
	,@cEMessage		nvarchar(max)
	,@cE_ThrottleType	VarChar(50)
	,@cE_ThrottleNumber	INT
	,@cE_ThrottleGrouping	VarChar(255)
	,@cE_ForwardTo		VarChar(2048)
	,@cE_RedirectTo		VarChar(2048)
	,@cEStat_Rows		BigInt
	,@cEStat_Duration	FLOAT
	,@cERE_ForceScreen	BIT
	,@cERE_Severity		INT
	,@cERE_State		INT
	,@cERE_With		VarChar(2048)
	,@cEMail_Subject	VarChar(2048)
	,@cEMail_To		VarChar(2048)
	,@cEMail_CC		VarChar(2048)
	,@cEMail_BCC		VarChar(2048)
	,@cEMail_Urgent		BIT
	,@cEFile_Name		VarChar(2048)
	,@cEFile_Path		VarChar(2048)
	,@cEFile_OverWrite	BIT
	,@cEPage_Subject	VarChar(2048)
	,@cEPage_To		VarChar(2048)
	,@cEMethod_Screen	BIT
	,@cEMethod_TableLocal	BIT
	,@cEMethod_TableCentral	BIT
	,@cEMethod_RaiseError	BIT
	,@cEMethod_EMail	BIT
	,@cEMethod_File		BIT
	,@cEMethod_Twitter	BIT
	,@cEMethod_DBAPager	BIT
		

----------------  initial values  -------------------

--  Create table variables
declare @DBnames table	(name		sysname
			,dbid		smallint
			,status		int
			)

--------------------------------------------------
--           SET GLOBAL cE VARIABLES            --
--------------------------------------------------
SELECT	@cEModule		= COALESCE(object_name(@@Procid),App_Name())	
	,@cEGUID		= NEWID()

--  Main Processing  -------------------------------------------------------------------


--  Fix owner and options for databases
--------------------------------------------------
--            SET EVENT cE VARIABLES            --
--------------------------------------------------
SELECT	@cECategory		= 'ForceDBRecoverModel'
	,@cEEvent		= 'CHECK'
	,@cEMessage		= 'Checking if Changes Are Needed'
	
--------------------------------------------------
--            CALL LOG EVENT SPROC              --
--------------------------------------------------
exec dbaadmin.dbo.[dbasp_LogEvent]
			 @cEModule
			,@cECategory
			,@cEEvent
			,@cEGUID
			,@cEMessage
--------------------------------------------------
--                    DONE                      --
--------------------------------------------------

SELECT		@ForcedRecoveryScript = @ForcedRecoveryScript 
		+ 'ALTER DATABASE ' + QUOTENAME([DBName]) 
		+ ' SET RECOVERY ' + REPLACE([ForcedRecovery],'-','_') 
		+ CHAR(13) + CHAR(10)
		+ CASE [Is_OperationsDB]
			WHEN 1 THEN 'ALTER AUTHORIZATION ON DATABASE::' 
					+ QUOTENAME([DBName]) + ' TO sa'
					+ CHAR(13) + CHAR(10)
			ELSE ''
			END
FROM		(
		SELECT		[DBName]
				, [CurRecovery]
				, CASE	WHEN [NoCkeck_Setting] = 'VALUE'
					THEN [NoCkeck_Value]
					
					WHEN [NoCkeck_Setting] = 'YES'
					THEN N'SIMPLE'
					
					WHEN [NoCkeck_Setting] = 'NO'
					THEN [CurRecovery]
					
					WHEN [Is_SystemDB] = 1
					THEN N'SIMPLE'
					
					WHEN [Is_OperationsDB] = 1
					THEN N'SIMPLE'
					
					WHEN [ENVname] != 'production'
					THEN N'SIMPLE'
						
					ELSE [CurRecovery]
					END AS [ForcedRecovery]
				,[Is_SystemDB]
				,[Is_OperationsDB]
				,[NoCkeck_Setting]
				,[NoCkeck_Value]
				,[ENVname]					
		FROM		(		
				SELECT		name AS [DBName]
						, CAST(Databasepropertyex(name,'Recovery') AS sysname) AS [CurRecovery]		
						, CASE  WHEN [T1].[database_id] < 5	THEN 1 
							WHEN [T1].[name] = 'aspnetdb'	THEN 1
							WHEN [T1].[name] like 'aspstate%' THEN 1
							ELSE 0 
							END AS [Is_SystemDB]
						, CASE	[T1].[name]
							WHEN	'dbaadmin'		THEN 1
							WHEN	'dbacentral'		THEN 1
							WHEN	'dbaperf'		THEN 1
							WHEN	'dbaperf_reports'	THEN 1
							WHEN	'deplcontrol'		THEN 1
							WHEN	'deplinfo'		THEN 1
							WHEN	'deploymaster'		THEN 1
							WHEN	'gears'			THEN 1
							WHEN	'operations'		THEN 1
							WHEN	'runbook'		THEN 1
							WHEN	'runbook05'		THEN 1
							WHEN	'sprocket'		THEN 1
							WHEN	'SQLdmRepository'	THEN 1
							WHEN	'MetricsOps'		THEN 1
							WHEN	'AutoTracking'		THEN 1
							ELSE	0
							END AS [Is_OperationsDB]
						, [T2].[detail02] AS [NoCkeck_Setting]
						, [T2].[detail03] AS [NoCkeck_Value]
						, [T3].[env_detail] AS [ENVname]
				FROM		[master].[sys].[databases] [T1]
				LEFT JOIN	[dbo].[No_Check] [T2]
					ON	[T1].[name] = [T2].[detail01]
					AND	[T2].[NoCheck_type] = 'ForcedRecoveryModel'
				LEFT JOIN	[dbaadmin].[dbo].[Local_ServerEnviro] [T3]
					ON	[env_type] = 'ENVname'
				) [Data]
		) [Data]
WHERE		[CurRecovery] != [ForcedRecovery]		

IF @@ROWCOUNT > 0 
BEGIN
	--------------------------------------------------
	--            SET EVENT cE VARIABLES        --
	--------------------------------------------------
	SELECT	@cEEvent		= 'START'
		,@cEMessage		= REPLACE(@ForcedRecoveryScript,CHAR(13)+CHAR(10), '; ')
		
	--------------------------------------------------
	--            CALL LOG EVENT SPROC              --
	--------------------------------------------------
	exec dbaadmin.dbo.[dbasp_LogEvent]
				 @cEModule
				,@cECategory
				,@cEEvent
				,@cEGUID
				,@cEMessage
	--------------------------------------------------
	--                    DONE                      --
	--------------------------------------------------


		--------------------------------------------------
		--                     DO IT                    --
		--------------------------------------------------
		BEGIN TRY
			--------------------------------------------------
			--            SET EVENT cE VARIABLES            --
			--------------------------------------------------
			-- VALUES USED UNLESS CATCH BLOCK CALLED
			SELECT	@cEEvent		= 'DONE'
				,@cEMessage		= 'Changes Were Applied'
				,@cEMethod_RaiseError	= 0	
		
			EXEC		(@ForcedRecoveryScript)
		END TRY
		BEGIN CATCH
			--------------------------------------------------
			--            SET EVENT cE VARIABLES            --
			--------------------------------------------------
			-- VALUES ONLY USED FOR ERROR
			SELECT	@cEEvent		= 'FAIL'
				,@cEMessage		= 'Changes Were NOT Applied: ' 
							+ REPLACE(@ForcedRecoveryScript,CHAR(13)+CHAR(10), '; ')
				,@cERE_Severity		= 10
				,@cERE_State		= 1
				,@cERE_With		= 'WITH NOWAIT,LOG'
				,@cEMethod_RaiseError	= 1
		END CATCH
		--------------------------------------------------
		--                    DONE                      --
		--------------------------------------------------		

	
	--------------------------------------------------
	--            CALL LOG EVENT SPROC              --
	--------------------------------------------------
	exec dbaadmin.dbo.[dbasp_LogEvent]
				 @cEModule
				,@cECategory
				,@cEEvent
				,@cEGUID
				,@cEMessage
				,@cERE_Severity
				,@cERE_State
				,@cERE_With
				,@cEMethod_RaiseError
	--------------------------------------------------
	--                    DONE                      --
	--------------------------------------------------
END	
ELSE
BEGIN
	--------------------------------------------------
	--            SET EVENT cE VARIABLES            --
	--------------------------------------------------
	SELECT	@cEEvent		= 'DONE'
		,@cEMessage		= 'No Changes Were Needed'
		
	--------------------------------------------------
	--            CALL LOG EVENT SPROC              --
	--------------------------------------------------
	exec dbaadmin.dbo.[dbasp_LogEvent]
				 @cEModule
				,@cECategory
				,@cEEvent
				,@cEGUID
				,@cEMessage
	--------------------------------------------------
	--                    DONE                      --
	--------------------------------------------------
END


--------------------------------------------------
--            SET EVENT cE VARIABLES            --
--------------------------------------------------
SELECT	@cECategory		= 'FixMainenancePlans'
	,@cEEvent		= 'CHECK'
	,@cEMessage		= 'Checking if Standard Plans Exists'
	
--------------------------------------------------
--            CALL LOG EVENT SPROC              --
--------------------------------------------------
exec dbaadmin.dbo.[dbasp_LogEvent]
			 @cEModule
			,@cECategory
			,@cEEvent
			,@cEGUID
			,@cEMessage
--------------------------------------------------
--                    DONE                      --
--------------------------------------------------



SET		@cEMessage = ''

SELECT		@cEMessage = @cEMessage + [SplitValue]+','
FROM		dbo.dbaudf_split('Mplan_sys_all,Mplan_user_all,Mplan_user_defrag,Mplan_user_full,Mplan_user_simple,Mplan_user_tranlog',',')
WHERE		[SplitValue] NOT IN (select [plan_name] from msdb.dbo.sysdbmaintplans)
SET		@cEMessage = REPLACE(@cEMessage + '|',',|','')

IF		@cEMessage != ''
BEGIN
	--------------------------------------------------
	--            SET EVENT cE VARIABLES            --
	--------------------------------------------------
	SELECT	@cECategory		= 'FixMainenancePlans'
		,@cEEvent		= 'START'
		,@cEMessage		= @cEMessage + ' Plans Need to be Created.'
		
	--------------------------------------------------
	--            CALL LOG EVENT SPROC              --
	--------------------------------------------------
	exec dbaadmin.dbo.[dbasp_LogEvent]
				 @cEModule
				,@cECategory
				,@cEEvent
				,@cEGUID
				,@cEMessage
	--------------------------------------------------
	--                    DONE                      --
	--------------------------------------------------



	--------------------------------------------------
	--                     DO IT                    --
	--------------------------------------------------
	BEGIN TRY
		--------------------------------------------------
		--            SET EVENT cE VARIABLES            --
		--------------------------------------------------
		-- VALUES USED UNLESS CATCH BLOCK CALLED
		SELECT	@cEEvent		= 'DONE'
			,@cEMessage		= 'Changes Were Applied'
			,@cEMethod_RaiseError	= 0	
	
		insert into	msdb.dbo.sysdbmaintplans (plan_id,plan_name,date_created,owner,max_history_rows,remote_history_server,max_remote_history_rows,user_defined_1,user_defined_2,user_defined_3,user_defined_4)
		SELECT		plan_id,plan_name,date_created,owner,max_history_rows,remote_history_server,max_remote_history_rows,user_defined_1,user_defined_2,user_defined_3,user_defined_4
		FROM		(
				SELECT	NEWID(),N'Mplan_sys_all',getdate(),N'sa',1000,N'',0,NULL,NULL,NULL,NULL
				UNION ALL
				SELECT	NEWID(),N'Mplan_user_all',getdate(),N'sa',1000,N'',0,NULL,NULL,NULL,NULL
				UNION ALL
				SELECT	NEWID(),N'Mplan_user_defrag',getdate(),N'sa',1000,N'',0,NULL,NULL,NULL,NULL
				UNION ALL
				SELECT	NEWID(),N'Mplan_user_full',getdate(),N'sa',1000,N'',0,NULL,NULL,NULL,NULL
				UNION ALL
				SELECT	NEWID(),N'Mplan_user_simple',getdate(),N'sa',1000,N'',0,NULL,NULL,NULL,NULL
				UNION ALL
				SELECT	NEWID(),N'Mplan_user_tranlog',getdate(),N'sa',1000,N'',0,NULL,NULL,NULL,NULL
				) Plans(plan_id,plan_name,date_created,owner,max_history_rows,remote_history_server,max_remote_history_rows,user_defined_1,user_defined_2,user_defined_3,user_defined_4)
		WHERE		[plan_name] NOT IN (select [plan_name] from msdb.dbo.sysdbmaintplans)
	END TRY
	BEGIN CATCH
		--------------------------------------------------
		--            SET EVENT cE VARIABLES            --
		--------------------------------------------------
		-- VALUES ONLY USED FOR ERROR
		SELECT	@cEEvent		= 'FAIL'
			,@cEMessage		= 'Changes Were NOT Applied: ' 
						+ REPLACE(dbo.Concatenate([SplitValue]+',')+' Plans Failed to Create.',', Plans Failed to Create.',' Plans Failed to Create.')
			,@cERE_Severity		= 10
			,@cERE_State		= 1
			,@cERE_With		= 'WITH NOWAIT,LOG'
			,@cEMethod_RaiseError	= 1
		FROM	dbo.dbaudf_split('Mplan_sys_all,Mplan_user_all,Mplan_user_defrag,Mplan_user_full,Mplan_user_simple,Mplan_user_tranlog',',')
		WHERE	[SplitValue] NOT IN (select [plan_name] from msdb.dbo.sysdbmaintplans)

	END CATCH

	--------------------------------------------------
	--            CALL LOG EVENT SPROC              --
	--------------------------------------------------
	exec dbaadmin.dbo.[dbasp_LogEvent]
				 @cEModule
				,@cECategory
				,@cEEvent
				,@cEGUID
				,@cEMessage
	--------------------------------------------------
	--                    DONE                      --
	--------------------------------------------------	
END
ELSE
BEGIN
	--------------------------------------------------
	--            SET EVENT cE VARIABLES            --
	--------------------------------------------------
	SELECT	@cECategory		= 'FixMainenancePlans'
		,@cEEvent		= 'DONE'
		,@cEMessage		= 'No Plans Need to be Created.'
		
	--------------------------------------------------
	--            CALL LOG EVENT SPROC              --
	--------------------------------------------------
	exec dbaadmin.dbo.[dbasp_LogEvent]
				 @cEModule
				,@cECategory
				,@cEEvent
				,@cEGUID
				,@cEMessage
	--------------------------------------------------
	--                    DONE                      --
	--------------------------------------------------
END		

--  Set standard maint plan members

--------------------------------------------------
--            SET EVENT cE VARIABLES            --
--------------------------------------------------
SELECT	@cECategory		= 'FixMainenancePlanMembers'
	,@cEEvent		= 'START'
	,@cEMessage		= 'Reset all Members for the Standard Plans except ''Mplan_user_defrag''.'
	
--------------------------------------------------
--            CALL LOG EVENT SPROC              --
--------------------------------------------------
exec dbaadmin.dbo.[dbasp_LogEvent]
			 @cEModule
			,@cECategory
			,@cEEvent
			,@cEGUID
			,@cEMessage
--------------------------------------------------
--                    DONE                      --
--------------------------------------------------

	--------------------------------------------------
	--            SET EVENT cE VARIABLES            --
	--------------------------------------------------
	SELECT	@cEEvent		= 'START'
		,@cEMessage		= 'Remove all Members for the Standard Plans except ''Mplan_user_defrag''.'
		
	--------------------------------------------------
	--            CALL LOG EVENT SPROC              --
	--------------------------------------------------
	exec dbaadmin.dbo.[dbasp_LogEvent]
				 @cEModule
				,@cECategory
				,@cEEvent
				,@cEGUID
				,@cEMessage
	--------------------------------------------------
	--                    DONE                      --
	--------------------------------------------------

	DELETE		msdb.dbo.sysdbmaintplan_databases
	WHERE		plan_id IN (SELECT plan_id FROM msdb.dbo.sysdbmaintplans WHERE plan_name IN ('Mplan_sys_all','Mplan_user_all','Mplan_user_full','Mplan_user_simple','Mplan_user_tranlog'))

	--------------------------------------------------
	--            SET EVENT cE VARIABLES            --
	--------------------------------------------------
	SELECT	@cEEvent		= 'DONE'
		,@cEMessage		= 'Remove all Members for the Standard Plans except ''Mplan_user_defrag''.'
		
	--------------------------------------------------
	--            CALL LOG EVENT SPROC              --
	--------------------------------------------------
	exec dbaadmin.dbo.[dbasp_LogEvent]
				 @cEModule
				,@cECategory
				,@cEEvent
				,@cEGUID
				,@cEMessage
	--------------------------------------------------
	--                    DONE                      --
	--------------------------------------------------


	--------------------------------------------------
	--            SET EVENT cE VARIABLES            --
	--------------------------------------------------
	SELECT	@cEEvent		= 'START'
		,@cEMessage		= 'Add all Members for the Standard Plans except ''Mplan_user_defrag''.'
		
	--------------------------------------------------
	--            CALL LOG EVENT SPROC              --
	--------------------------------------------------
	exec dbaadmin.dbo.[dbasp_LogEvent]
				 @cEModule
				,@cECategory
				,@cEEvent
				,@cEGUID
				,@cEMessage
	--------------------------------------------------
	--                    DONE                      --
	--------------------------------------------------
		
	insert into	msdb.dbo.sysdbmaintplan_databases (plan_id, database_name)
	SELECT		PlanDB.*
	FROM		(
			SELECT	plan_id,N'All System Databases' 
			FROM	msdb.dbo.sysdbmaintplans 
			WHERE	plan_name = N'Mplan_sys_all'

			UNION ALL		
			SELECT	T2.plan_id, T1.name
			From	master.sys.sysdatabases T1
			JOIN	msdb.dbo.sysdbmaintplans T2
			  ON	T2.plan_name = N'Mplan_user_all'
			WHERE	T1.DBID > 4	
			  AND	T1.name NOT IN (SELECT detail01 FROM dbo.No_Check where  NoCheck_type='BACKUP')

			UNION ALL		
			SELECT	T2.plan_id, T1.name
			From	master.sys.sysdatabases T1
			JOIN	msdb.dbo.sysdbmaintplans T2
			  ON	T2.plan_name = N'Mplan_user_simple'
			WHERE	T1.DBID > 4	
			  AND	T1.name NOT IN (SELECT detail01 FROM dbo.No_Check where  NoCheck_type='BACKUP')
			  AND	databaseproperty(T1.name, 'IsTrunclog') = 1

			UNION ALL		
			SELECT	T2.plan_id, T1.name
			From	master.sys.sysdatabases T1
			JOIN	msdb.dbo.sysdbmaintplans T2
			  ON	T2.plan_name = N'Mplan_user_full'
			WHERE	T1.DBID > 4	
			  AND	T1.name NOT IN (SELECT detail01 FROM dbo.No_Check where  NoCheck_type='BACKUP')
			  AND	databaseproperty(T1.name, 'IsTrunclog') != 1

			UNION ALL		
			SELECT	T2.plan_id, T1.name
			From	master.sys.sysdatabases T1
			JOIN	msdb.dbo.sysdbmaintplans T2
			  ON	T2.plan_name = N'Mplan_user_tranlog'
			WHERE	T1.DBID > 4	
			  AND	T1.name NOT IN (SELECT detail01 FROM dbo.No_Check where  NoCheck_type='BACKUP')
			  AND	databaseproperty(T1.name, 'IsTrunclog') != 1
			) PlanDB(plan_id,database_name)
	LEFT JOIN	msdb.dbo.sysdbmaintplan_databases MPD
		ON	PlanDB.plan_id = MPD.plan_id
		AND	PlanDB.database_name = MPD.database_name
	WHERE		MPD.plan_id IS NULL
		AND	databasepropertyex(PlanDB.database_name,'Status') = 'ONLINE'

	--------------------------------------------------
	--            SET EVENT cE VARIABLES            --
	--------------------------------------------------
	SELECT	@cEEvent		= 'DONE'
		,@cEMessage		= 'Add all Members for the Standard Plans except ''Mplan_user_defrag''.'
		
	--------------------------------------------------
	--            CALL LOG EVENT SPROC              --
	--------------------------------------------------
	exec dbaadmin.dbo.[dbasp_LogEvent]
				 @cEModule
				,@cECategory
				,@cEEvent
				,@cEGUID
				,@cEMessage
	--------------------------------------------------
	--                    DONE                      --
	--------------------------------------------------
--------------------------------------------------
--            SET EVENT cE VARIABLES            --
--------------------------------------------------
SELECT	@cEEvent		= 'DONE'
	,@cEMessage		= 'All Standard Plan Members, except ''Mplan_user_defrag'', Have Been Reset.'
	
--------------------------------------------------
--            CALL LOG EVENT SPROC              --
--------------------------------------------------
exec dbaadmin.dbo.[dbasp_LogEvent]
			 @cEModule
			,@cECategory
			,@cEEvent
			,@cEGUID
			,@cEMessage
--------------------------------------------------
--                    DONE                      --
--------------------------------------------------	
---------------------------  Finalization  -----------------------

GO

