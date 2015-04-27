if not exists (select * from sysobjects
           where  id = object_id('Bcp.WriteFile')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('create procedure Bcp.WriteFile as return')
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		D. Nambi
-- Create date: 	2007-12-17
-- =============================================
ALTER PROCEDURE Bcp.WriteFile
	@TextToWrite nvarchar(max),
	@DestinationLocation nvarchar(4000),
	@AllowOverwrites bit=null,
	@ProcessGUID uniqueidentifier=null
AS
/*
<DbDoc>
	<object
		description="Transfer data via Bulk Copy (BCP)"
		>
		<parameters>
			<parameter name="@TextToWrite" description="The text to write to the given file location"/>
			<parameter name="@DestinationLocation" description="The UNC file location to write the file. Must include the file name and extension." />
			<parameter name="@AllowOverwrites" description="1=Overwrite a file if it is there. 0=Throw an error and do not write a file if it is there" />
			<parameter name="@ProcessGUID" description="What is the ProcessGUID of the method that is calling this sproc? Defaults to newid()"/>
		</parameters>
	</object>
</DbDoc>
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @UsesEvtLogging bit,
			@EDef xml
	
	SET @UsesEvtLogging=Cfg.GetBit('BcpTransfer', 'UseEvtLogging');
	SET @AllowOverwrites=coalesce(@AllowOverwrites, Cfg.GetBit('BcpTransfer','AllowOverwrites'));
	SET @ProcessGUID=coalesce(@ProcessGUID, newid());
	SET @EDef=(
		select
			@DestinationLocation as [@destination-location]
			,@AllowOverwrites as [@allow-overwrites]
		for xml path ('parameter')
		)
	
	if @UsesEvtLogging=1
	begin
		exec Evt.MessageHandle
		@MessageSpaceKeyword='EVT_BCP'
		,@MessageKeyword='EVT_WRITEFILE'
		,@TypeKeyword='EVT_START'
		,@ModuleName='Bcp.WriteFile'
		,@ProcessGUID=@ProcessGUID
		,@AdHocDefinition=@EDef
	end


    EXEC Bcp.ClrWriteFile
	@TextToWrite=@TextToWrite,
	@DestinationLocation=@DestinationLocation,
	@AllowOverwrites=@AllowOverwrites,
	@UsesEvtLogging=@UsesEvtLogging,
	@ProcessGUID=@ProcessGUID
  
END
go

exec DbDoc.ObjectParse @ObjectName=WriteFile, @SchemaName=Bcp
go