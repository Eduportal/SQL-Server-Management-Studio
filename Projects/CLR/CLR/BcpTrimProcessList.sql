if not exists (select * from sysobjects
           where  id = object_id('Bcp.TrimProcessList')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('create procedure Bcp.TrimProcessList as return')
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		D. Nambi
-- =============================================
ALTER PROCEDURE [Bcp].[TrimProcessList]
	  @MinProcessStartTime datetime
	  ,@ProcessGUID uniqueidentifier=null
AS

/*
<DbDoc>
	<object
		description="Deletes everything out of the ProcessList table with that has a ProcessStartTime less than the given parameter"
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
		,@MessageKeyword='EVT_TRIMPROC'
		,@TypeKeyword='EVT_START'
		,@ModuleName='Bcp.TrimProcessList'
		,@ProcessGUID=@ProcessGUID
	
	
	delete from [Bcp].[ProcessList]
	where ProcessStartTime <= @MinProcessStartTime
	
	set @lRow=@@rowcount;

	exec Evt.MessageHandle
		@MessageSpaceKeyword='EVT_BCP'
		,@MessageKeyword='EVT_TRIMPROC'
		,@TypeKeyword='EVT_SUCCESS'
		,@ModuleName='Bcp.TrimProcessList'
		,@ProcessGUID=@ProcessGUID
		,@RowsAffected=@lRow

END
go

exec DbDoc.ObjectParse @ObjectName=TrimProcessList, @SchemaName=Bcp
go