USE [dbaadmin]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_APP_NAME]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[dbaudf_APP_NAME]
GO

USE [dbaadmin]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[dbaudf_APP_NAME] 
	(
		@AgentPartName sysname = NULL
	)
RETURNS VarChar(1024)
AS
BEGIN
	DECLARE	@P1			INT
			,@P2		INT
			,@JobID		sysname
			,@JobName	sysname
			,@StepID	sysname
			,@StepName	sysname
			,@APPName	VarChar(1024)
			
	SET		@APPName = APP_NAME()		
	IF		@APPName Like 'SQLAgent - TSQL JobStep%'
	BEGIN
		SELECT	@P1			= CHARINDEX('Job 0x',@APPName)+5
				,@P2		= CHARINDEX(': Step',@APPName)+6
				
		SELECT	@JobID		= CAST(sj.job_id as sysname)
				,@JobName	= sj.name
				,@StepID	= sjs.step_id
				,@StepName	= sjs.step_name
				,@APPName	= CASE @AgentPartName
								WHEN 'JobID'	THEN @JobID
								WHEN 'JobName'	THEN @JobName
								WHEN 'StepID'	THEN @StepID
								WHEN 'StepName'	THEN @StepName
								ELSE 'SQLAgent - TSQL Job ['
										+ sj.name 
										+ '] Step '
										+ CAST(sjs.step_id as VarChar(4)) 
										+ ' [' 
										+ sjs.step_name 
										+ ']' END
		FROM	msdb..sysjobs sj WITH(NOLOCK)
		JOIN	msdb..sysjobsteps sjs WITH(NOLOCK)
			ON	sj.job_id = sjs.job_id
		WHERE	sj.job_id =
				CAST(
				 SUBSTRING(@APPName,@P1+7,2)
				+SUBSTRING(@APPName,@P1+5,2)
				+SUBSTRING(@APPName,@P1+3,2)
				+SUBSTRING(@APPName,@P1+1,2)
				+'-'
				+SUBSTRING(@APPName,@P1+11,2)
				+SUBSTRING(@APPName,@P1+9,2)
				+'-'
				+SUBSTRING(@APPName,@P1+15,2)
				+SUBSTRING(@APPName,@P1+13,2)
				+'-'
				+SUBSTRING(@APPName,@P1+17,2)
				+SUBSTRING(@APPName,@P1+19,2)
				+'-'
				+SUBSTRING(@APPName,@P1+21,2)
				+SUBSTRING(@APPName,@P1+23,2)
				+SUBSTRING(@APPName,@P1+25,2)
				+SUBSTRING(@APPName,@P1+27,2)		
				+SUBSTRING(@APPName,@P1+29,2)
				+SUBSTRING(@APPName,@P1+31,2)
				AS 	UniqueIdentifier)
			AND	sjs.step_id	= CAST(SUBSTRING(@APPName,@P2,CHARINDEX(')',@APPName,@P2)-@P2)AS INT)	
	END
		
	RETURN @APPName
END

GO

EXEC sys.sp_addextendedproperty @name=N'BuildApplication', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'dbaudf_APP_NAME'
GO

EXEC sys.sp_addextendedproperty @name=N'BuildBranch', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'dbaudf_APP_NAME'
GO

EXEC sys.sp_addextendedproperty @name=N'BuildNumber', @value=N'' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'dbaudf_APP_NAME'
GO

EXEC sys.sp_addextendedproperty @name=N'DeplFileName', @value=NULL , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'dbaudf_APP_NAME'
GO

EXEC sys.sp_addextendedproperty @name=N'Version', @value=N'1.0.0' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'dbaudf_APP_NAME'
GO


