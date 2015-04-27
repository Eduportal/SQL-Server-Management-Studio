if not exists (select * from sysobjects
           where  id = object_id('Bcp.Copy')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('create procedure Bcp.Copy as return')
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		D. Nambi
-- =============================================
ALTER PROCEDURE [Bcp].[Copy]
	 @SourceLocation nvarchar(4000)
	,@DestinationLocation nvarchar(4000)
	,@AllowOverwrites bit=null
	,@ProcessGUID uniqueidentifier=null
AS

/*
<DbDoc>
	<object
		description="Copy data to a given file location."
		>
		<parameters>
			<parameter name="@SourceLocation" description="The location of the file to copy from." />
			<parameter name="@DestinationLocation" description="The UNC file location to write the file. Must include the file name and extension." />
			<parameter name="@AllowOverwrites" description="1=Overwrite a file if it is there. 0=Throw an error and do not write a file if it is there" />
			<parameter name="@ProcessGUID" description="What is the ProcessGUID of the method that is calling this sproc? Defaults to newid()"/>
		</parameters>
	</object>
</DbDoc>
*/
BEGIN
	set nocount on;

	DECLARE @DoesExtendedLogging bit
			,@EDef xml
			,@ETypeKeyword varchar(32)
			,@EMsg nvarchar(max)

	
	SET @DoesExtendedLogging=Cfg.GetBit('BcpTransfer', 'DoesExtendedLogging');
	SET @AllowOverwrites=coalesce(@AllowOverwrites, Cfg.GetBit('BcpTransfer','AllowOverwrites'));
	SET @ProcessGUID=coalesce(@ProcessGUID, newid());
	SET @EDef=(
			select
				@SourceLocation as [@source-location]
				,@DestinationLocation as [@destination-location]
				,@AllowOverwrites as [@allow-overwrites]
				,@DoesExtendedLogging as [@does-extended-logging]
			for xml path ('parameter')
			)
	
	exec Evt.MessageHandle
		@MessageSpaceKeyword='EVT_BCP'
		,@MessageKeyword='EVT_COPYFILE'
		,@TypeKeyword='EVT_START'
		,@ModuleName='Bcp.Copy'
		,@ProcessGUID=@ProcessGUID
		,@AdHocDefinition=@EDef
	BEGIN TRY
	
		EXEC [Bcp].[ClrCopy]
		@SourceLocation=@SourceLocation,
		@DestinationLocation=@DestinationLocation,
		@AllowOverwrites=@AllowOverwrites,
		@DoesExtendedLogging=@DoesExtendedLogging,
		@ProcessGUID=@ProcessGUID
	
		SET @ETypeKeyword='EVT_SUCCESS'
		SET @EMsg='Bcp.Copy operation successful'
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
	,@MessageKeyword='EVT_COPYFILE'
	,@TypeKeyword=@ETypeKeyword
	,@ModuleName='Bcp.Copy'
	,@ProcessGUID=@ProcessGUID
	,@AdHocDefinition=@EDef
	,@AdHocMsg=@EMsg
END
go

exec DbDoc.ObjectParse @ObjectName=Copy, @SchemaName=Bcp
go