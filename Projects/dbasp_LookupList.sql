USE [dbaadmin]
GO
CREATE PROCEDURE [dbo].[dbasp_LookupList]
		(
		@ServerName		sysname	= ''
		,@SQLname			sysname = ''
		,@ENVname			sysname = ''
		,@ENVnum			sysname	= ''
		,@DBname			sysname = ''
		,@AppName			sysname = ''
		,@Active			CHAR(1) = 'Y'
		,@ReturnField		sysname = 'ALL'
		)
  as
set nocount on
/***************************************************************
 **  Stored Procedure dbasp_ServerList                  
 **  Written by Steve Ledridge, Getty Images                
 **  March 29, 2010                                      
 **
 **  This procedure creates a list of servers use to populate 
 **  autocompletes or list boxes.
 ***************************************************************/

--	======================================================================================
--	Revision History
--	Date		Author     				Desc
--	==========	====================	==============================================
--	03/29/2010	Steve Ledridge			New process
--	======================================================================================
/***

DECLARE	 @Servername		sysname
		,@SQLname			sysname
		,@ENVname			sysname
		,@ENVnum			sysname
		,@DBname			sysname
		,@AppName			sysname
		,@Active			CHAR(1)
		,@ReturnField		sysname

SELECT	 @Servername		= ''
		,@SQLname			= ''
		,@ENVname			= ''
		,@ENVnum			= ''
		,@DBname			= ''
		,@AppName			= ''
		,@Active			= 'Y'
		,@ReturnField		= 'SQLName'

--***/

----------------  initial values  -------------------

-- CLEAN UP NULLS AND APPEND %
SELECT	@Servername		= COALESCE(@Servername,'')+'%'
SELECT	@SQLname		= COALESCE(@SQLname,'')+'%'
SELECT	@DBname			= COALESCE(@DBname,'')+'%'
SELECT	@ENVname		= COALESCE(@ENVname,'')+'%'
SELECT	@ENVnum			= COALESCE(@ENVnum,'')+'%'
SELECT	@AppName		= COALESCE(@AppName,'')+'%'
SELECT	@Active			= COALESCE(@Active,'Y')
SELECT	@ReturnField	= COALESCE(@ReturnField,'ALL')

IF		@Active != 'N'
	SET	@Active = 'Y'

--  Create table variable
declare @Results	table
					(
					RecID		INT IDENTITY(1,1) PRIMARY KEY
					,ServerName	sysname
					,SQLName	sysname
					,DBName		sysname
					,ENVname	sysname
					,ENVnum		sysname
					,AppName	sysname
					)

/****************************************************************
 *                MainLine
 ***************************************************************/

INSERT INTO	@Results
SELECT		DISTINCT
			si.ServerName
			,si.SQLName
			,di.DBName
			,di.ENVname
			,di.ENVnum
			,di.Appl_desc
FROM		dbaadmin.dbo.DBA_ServerInfo si WITH(NOLOCK)
INNER JOIN	dbaadmin.dbo.DBA_DBInfo di WITH(NOLOCK)
	ON		si.SQLName = si.SQLName
WHERE		si.Active = @Active
	AND		si.ServerName LIKE @ServerName
	AND		si.SQLName LIKE @SQLName
	AND		di.DBName LIKE @DBName
	AND		di.ENVname LIKE @ENVname
	AND		di.ENVnum LIKE @ENVnum
	AND		di.Appl_desc LIKE @AppName

-----------------------------------------------------------------------------------------------------------------
--  Finalization  -----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

label99:
IF @ReturnField = 'ALL'
	SELECT * FROM @Results
ELSE
	SELECT		DISTINCT
				CASE @ReturnField
				WHEN 'ServerName'	THEN ServerName
				WHEN 'SQLName'		THEN SQLName
				WHEN 'DBName'		THEN DBName
				WHEN 'ENVname'		THEN ENVname
				WHEN 'ENVnum'		THEN ENVnum
				WHEN 'AppName'		THEN AppName
				END Results
	FROM		@Results			


GO


