if not exists (select * from sysobjects
           where  id = object_id('Bcp.GetProcessList')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('create procedure Bcp.GetProcessList as return')
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		D. Nambi
-- =============================================
ALTER PROCEDURE [Bcp].[GetProcessList]
	@ProcessGUID uniqueidentifier=null
AS

/*
<DbDoc>
	<object
		description="Insert a single row into the Bcp.ProcessList table."
		>
		<parameters>
		</parameters>
	</object>
</DbDoc>
*/
BEGIN
	set nocount on;
	
	declare @lRow int
	
	exec Evt.MessageHandle
		@MessageSpaceKeyword='EVT_BCP'
		,@MessageKeyword='EVT_GETPROC'
		,@TypeKeyword='EVT_START'
		,@ModuleName='Bcp.GetProcessList'
		,@ProcessGUID=@ProcessGUID
	
	select 	 p.ProcessID
			,p.ProcessName
			,p.ProcessStartTime
	from [Bcp].[ProcessList] p
	left outer join sys.dm_exec_sessions s
	on p.SpidNumber=s.session_id
	where s.session_id is null
	or p.SpidBatchTime <= s.last_request_end_time
	
	set @lRow=@@rowcount;
	
	exec Evt.MessageHandle
		@MessageSpaceKeyword='EVT_BCP'
		,@MessageKeyword='EVT_GETPROC'
		,@TypeKeyword='EVT_START'
		,@ModuleName='Bcp.GetProcessList'
		,@ProcessGUID=@ProcessGUID
		,@RowsAffected=@lRow


END
go

exec DbDoc.ObjectParse @ObjectName=GetProcessList, @SchemaName=Bcp
go