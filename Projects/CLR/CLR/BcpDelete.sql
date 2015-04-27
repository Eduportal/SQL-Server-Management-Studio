if not exists (select * from sysobjects
           where  id = object_id('[Bcp].[Delete]')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('create procedure [Bcp].[Delete] as return')
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		D. Nambi
-- =============================================
ALTER PROCEDURE [Bcp].[Delete]
	 @FileLocation nvarchar(4000)
	,@ProcessGUID uniqueidentifier=null
AS

/*
<DbDoc>
	<object
		description="Delete file at a given location."
		>
		<parameters>
			<parameter name="@FileLocation" description="The location of the file to delete" />
			<parameter name="@ProcessGUID" description="What is the ProcessGUID of the method that is calling this sproc? Defaults to newid()"/>
		</parameters>
	</object>
</DbDoc>
*/
BEGIN
	set nocount on;

	DECLARE @DoesExtendedLogging bit
		,@EDef xml

	
	SET @DoesExtendedLogging=Cfg.GetBit('BcpTransfer', 'DoesExtendedLogging');
	SET @ProcessGUID=coalesce(@ProcessGUID, newid());
	SET @EDef=(
		select 
			@FileLocation as [@file-location]
			,@DoesExtendedLogging as [@does-extended-logging]
		for xml path ('parameter')
		)
	
	exec Evt.MessageHandle
		@MessageSpaceKeyword='EVT_BCP'
		,@MessageKeyword='EVT_DELETEFILE'
		,@TypeKeyword='EVT_START'
		,@ModuleName='Bcp.Delete'
		,@ProcessGUID=@ProcessGUID
		,@AdHocDefinition=@EDef
	
	EXEC [Bcp].[ClrDelete]
	@FileLocation=@FileLocation,
	@DoesExtendedLogging=@DoesExtendedLogging,
	@ProcessGUID=@ProcessGUID
END
go

exec DbDoc.ObjectParse @ObjectName=[Delete], @SchemaName=Bcp
go