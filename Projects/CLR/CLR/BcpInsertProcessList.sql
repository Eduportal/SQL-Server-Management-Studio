if not exists (select * from sysobjects
           where  id = object_id('Bcp.InsertProcessList')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('create procedure Bcp.InsertProcessList as return')
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		D. Nambi
-- =============================================
ALTER PROCEDURE [Bcp].[InsertProcessList]
	  @ProcessID int
	 ,@ProcessStartTime datetime
	 ,@ProcessGUID uniqueidentifier
AS

/*
<DbDoc>
	<object
		description="Insert a single row into the Bcp.ProcessList table."
		>
		<parameters>
			<parameter name="@ProcessGUID" description="What is the ProcessGUID of the method that is calling this sproc? Defaults to newid()"/>
		</parameters>
	</object>
</DbDoc>
*/
BEGIN
	set nocount on;
	
	declare @eDef xml
			,@lRow smallint
			,@SpidBatchTime datetime
			,@ETypeKeyword varchar(32)
			,@EMsg nvarchar(max)
			
	set @eDef=
	(
		select @ProcessID as [@process-id]
				,@ProcessStartTime as [@process-start-time]
		for xml path ('parameter')
	)
	
	exec Evt.MessageHandle
		@MessageSpaceKeyword='EVT_BCP'
		,@MessageKeyword='EVT_INSRTPROC'
		,@TypeKeyword='EVT_START'
		,@ModuleName='Bcp.InsertProcessList'
		,@ProcessGUID=@ProcessGUID
		,@AdHocDefinition=@eDef
		
	begin try
		set @SpidBatchTime=
		(
			select top 1 last_request_end_time
			from sys.dm_exec_sessions
			where session_id=@@spid
		)
		
		
		if @SpidBatchTime is null
		begin
			exec Evt.MessageHandle
				@MessageSpaceKeyword='EVT_BCP'
				,@MessageKeyword='EVT_INSRTPROC'
				,@TypeKeyword='EVT_WARN'
				,@ModuleName='Bcp.InsertProcessList'
				,@ProcessGUID=@ProcessGUID
				,@AdHocMsg='SpidBatchTime parameter is null'
				,@AdHocDefinition=@eDef
		end
		
		insert into [Bcp].[ProcessList]
		(SpidNumber
		,SpidBatchTime
		,ProcessID
		,ProcessName
		,ProcessStartTime
		,ProcessGUID)
		select
		 @@spid
		,@SpidBatchTime
		,@ProcessID
		,'bcp'
		,@ProcessStartTime
		,@ProcessGUID
		
		set @lRow=@@rowcount
		
		set @eDef=
		(
			select @@spid as [@spid]
				,@SpidBatchTime as [@spid-batch-time]
				,@ProcessID as [@process-id]
				,@ProcessStartTime as [@process-start-time]
			for xml path ('parameter')
		)
	
		SET @ETypeKeyword='EVT_SUCCESS'
		SET @EMsg='Bcp.Export operation successful'
	END TRY
	BEGIN CATCH
		set @ETypeKeyword='EVT_FAIL'
		set @EMsg=N'try/catch error'
			+N':message='+error_message()
			+case when error_procedure() is null then N'' else N':procedure='+error_procedure() end
			+case when error_number() is null then N'' else N':error number='+cast(error_number() as nvarchar) end
			+case when error_line() is null then N'' else N':line number='+cast(error_line() as nvarchar) end
	END CATCH
	
	exec Evt.MessageHandle
	@MessageSpaceKeyword='EVT_BCP'
	,@MessageKeyword='EVT_INSRTPROC'
	,@TypeKeyword=@ETypeKeyword
	,@ProcessGUID=@ProcessGUID
	,@AdHocDefinition=@eDef
	,@AdHocMsg=@EMsg
END