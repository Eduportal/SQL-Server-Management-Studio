USE [DEPLcontrol]
GO
/****** Object:  UserDefinedFunction [dbo].[DBA_DashBoard_GearsTicket_HL]    Script Date: 10/4/2013 11:02:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[DBA_DashBoard_GearsTicket_HL] 
(
	@Gears_ID int
	,@UseRemote bit = 0 
)
RETURNS 
@Results TABLE 
(
	[Domain]		sysname
	,[SQLName]		sysname
	,[HandShake_Status]	VarChar(25)
	,[HandShake_Sql]	VarChar(25)
	,[HandShake_Agent]	VarChar(25)
	,[HandShake_DEPLjobs]	VarChar(25)
	,[Setup_Status]		VarChar(25)
	,[Restore_Status]	VarChar(25)
	,[Deploy_Status]	VarChar(25)
	,[End_Status]		VarChar(25)
	,[LogPath]		nVarChar(4000)
)
AS
BEGIN
	INSERT INTO	@Results
	SELECT		[domain]
			,[SQLname]
			,[HandShake_Status]
			,[HandShake_sql]
			,[HandShake_agent]
			,[HandShake_DEPLjobs]
			,[Setup_Status]
			,[Restore_Status]
			,[Deploy_Status]
			,[End_Status]
			,[LogPath]
	FROM		[DEPLcontrol].[dbo].[DBA_DashBoard_GearsTicket_HL_Local_Amer]
	WHERE		[Gears_id]=@Gears_ID
	
	IF @UseRemote = 0
	BEGIN
		INSERT INTO	@Results
		SELECT		[domain]
				,[SQLname]
				,[HandShake_Status]
				,[HandShake_sql]
				,[HandShake_agent]
				,[HandShake_DEPLjobs]
				,[Setup_Status]
				,[Restore_Status]
				,[Deploy_Status]
				,[End_Status]
				,[LogPath]
		FROM		[DEPLcontrol].[dbo].[DBA_DashBoard_GearsTicket_HL_Local_Stage]
		WHERE		[Gears_id]=@Gears_ID	
		
		INSERT INTO	@Results
		SELECT		[domain]
				,[SQLname]
				,[HandShake_Status]
				,[HandShake_sql]
				,[HandShake_agent]
				,[HandShake_DEPLjobs]
				,[Setup_Status]
				,[Restore_Status]
				,[Deploy_Status]
				,[End_Status]
				,[LogPath]
		FROM		[DEPLcontrol].[dbo].[DBA_DashBoard_GearsTicket_HL_Local_Prod]
		WHERE		[Gears_id]=@Gears_ID	
	END
	ELSE
	BEGIN
		INSERT INTO	@Results
		SELECT		[domain]
				,[SQLname]
				,[HandShake_Status]
				,[HandShake_sql]
				,[HandShake_agent]
				,[HandShake_DEPLjobs]
				,[Setup_Status]
				,[Restore_Status]
				,[Deploy_Status]
				,[End_Status]
				,[LogPath]
		FROM		[DEPLcontrol].[dbo].[DBA_DashBoard_GearsTicket_HL_Remote_Stage]
		WHERE		[Gears_id]=@Gears_ID	
		
		INSERT INTO	@Results
		SELECT		[domain]
				,[SQLname]
				,[HandShake_Status]
				,[HandShake_sql]
				,[HandShake_agent]
				,[HandShake_DEPLjobs]
				,[Setup_Status]
				,[Restore_Status]
				,[Deploy_Status]
				,[End_Status]
				,[LogPath]
		FROM		[DEPLcontrol].[dbo].[DBA_DashBoard_GearsTicket_HL_Remote_Prod]
		WHERE		[Gears_id]=@Gears_ID	
	END
	RETURN 
END

GO
