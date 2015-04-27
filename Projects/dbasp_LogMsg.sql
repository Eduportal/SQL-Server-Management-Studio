USE [dbaadmin]
GO

/****** Object:  StoredProcedure [dbasp_LogMsg]    Script Date: 04/06/2010 18:18:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbasp_LogMsg]
@ModuleName sysname
,@MessageKeyword varchar(32)
,@TypeKeyword varchar(16)=null
,@AdHocMsg nvarchar(max)=null
,@AdHocDefinition xml=null
,@RowsAffected int=null
,@ProcessGUID uniqueidentifier=null
,@LogPublisherMessage bit=null
,@SuppressRaiseError bit=0
,@Diagnose bit=null
,@TestMode bit=null
as
/*
<DbDoc>
	<object description="Internal handler for printing log messages and logging them locally"/>
</DbDoc>
*/
begin
	set nocount on
	declare
	@cLogDBName sysname
	,@cLogSysuser sysname
	,@cLogModuleVersion nvarchar(32)
	,@cESpace varchar(32)
	,@lRC int

	set @cLogDBName=db_name()
	set @cLogSysuser=system_user
	set @cLogModuleVersion= '0.01' --DbDoc.GetVersion(N'NDX')
	set @cESpace='EVT_NDX'
	if @ProcessGUID is null set @ProcessGUID=newid()
	if @Diagnose is null set @Diagnose=1
	if @LogPublisherMessage is null set @LogPublisherMessage=1

	if @Diagnose=1
		print @ModuleName+N': '
			+cast(current_timestamp as nvarchar)
			--+N': type='+coalesce([Evt].[TypeGetName](@TypeKeyword),N'(undefined)')
			+N': type='+coalesce(@TypeKeyword,N'(undefined)')
			+case when @RowsAffected is null then N'' else
				N': rowcount='+cast(@RowsAffected as nvarchar)
				end
			+case when @AdHocMsg is null then N'' else
				N': '+@AdHocMsg
				end



	--exec @lRC=[Evt].[MessageHandle]
	--	@MessageSpaceKeyword=@cESpace
	--	,@MessageKeyword=@MessageKeyword
	--	,@TypeKeyword=@TypeKeyword
	--	,@ModuleName=@ModuleName
	--	,@ProcessGUID=@ProcessGUID
	--	,@AdHocMsg=@AdHocMsg
	--	,@AdHocDefinition=@AdHocDefinition
	--	,@RowsAffected=@RowsAffected
	--	,@SuppressRaiseError=@SuppressRaiseError
	--	,@SuppressLog=@TestMode

	return @lRC
end

GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'description' , N'SCHEMA',N'dbo', N'PROCEDURE',N'dbasp_LogMsg', NULL,NULL))
EXEC sys.sp_addextendedproperty @name=N'description', @value=N'Internal handler for printing log messages and logging them locally' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'dbasp_LogMsg'
GO


