if not exists (select * from sysobjects
           where  id = object_id('Bcp.Export')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('create procedure Bcp.Export as return')
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		D. Nambi
-- Create date: 	2007-12-15
-- =============================================
ALTER PROCEDURE Bcp.Export
	 @SelectStatement nvarchar(4000)
	,@ColumnDelimiter nvarchar(32)=null
	,@LineDelimiter nvarchar(32)=null
	,@DestinationLocation nvarchar(4000)
	,@AllowOverwrites bit=null
	,@ConnectionTimeout int=null
	,@ProcessGUID uniqueidentifier=null
	,@UseSafeExport bit=null
AS

/*
<DbDoc>
	<object
		description="Export data via SELECT statement to a given file location."
		>
		<parameters>
			<parameter name="@SelectStatement" description="The command to run against this database to return the result set to write out."/>
			<parameter name="@ColumnDelimiter" description="The character(s) to use as a column delimiter." />
			<parameter name="@LineDelimiter" description="The character(s) to use as a line/row delimiter." />
			<parameter name="@DestinationLocation" description="The UNC file location to write the file. Must include the file name and extension." />
			<parameter name="@AllowOverwrites" description="1=Overwrite a file if it is there. 0=Throw an error and do not write a file if it is there" />
			<parameter name="@ProcessGUID" description="What is the ProcessGUID of the method that is calling this sproc? Defaults to newid()"/>
		</parameters>
	</object>
</DbDoc>
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @UsesEvtLogging bit
			,@DoesExtendedLogging bit
			,@ESpace varchar(32)
			,@EMessage varchar(32)
			,@EModule sysname
			,@EDef xml
			,@ETypeKeyword varchar(16)
			,@EMsg nvarchar(max)
			,@lServerName nvarchar(128)
			,@lDatabaseName nvarchar(128)
			,@lConnTimeout int
			,@lSafeExportMaxErrors int
			,@lSafeExportFormatEnum smallint

	SET @lServerName=@@servername
	SET @lDatabaseName=db_name()
	SET @lConnTimeout=coalesce(@ConnectionTimeout,Cfg.GetInt('BcpTransfer','ConnectionTimeout'))
	SET @UsesEvtLogging=Cfg.GetBit('BcpTransfer','UseEvtLogging');
	SET @DoesExtendedLogging=Cfg.GetBit('BcpTransfer', 'DoesExtendedLogging');
	SET @ColumnDelimiter=coalesce(@ColumnDelimiter, Cfg.GetString('BcpTransfer','ColumnDelimiter'));
	SET @LineDelimiter=coalesce(@LineDelimiter, Cfg.GetString('BcpTransfer','RowDelimiter'));
	SET @AllowOverwrites=coalesce(@AllowOverwrites, Cfg.GetBit('BcpTransfer','AllowOverwrites'));
	SET @UseSafeExport=coalesce(@UseSafeExport, Cfg.GetBit('BcpTransfer','UseSafeExport'));
	SET @lSafeExportMaxErrors=Cfg.GetInt('BcpTransfer','SafeExportMaxErrors');
	SET @lSafeExportFormatEnum=convert(smallint, Cfg.GetInt('BcpTransfer','SafeExportFormatEnum'));
	SET @ProcessGUID=coalesce(@ProcessGUID, newid());
	SET @EModule=N'Bcp.Export'
	SET @ESpace=N'EVT_BCP'
	SET @EMessage=N'EVT_EXPORT'
	SET @ETypeKeyword='EVT_START'
	SET @EMsg=N'Begin Bcp.Export operation'
	SET @EDef=(
		select
		 @DestinationLocation as [@destination-location]
		,@AllowOverwrites as [@allow-overwrites]
		,@lConnTimeout as [@connection-timeout]
		,@ColumnDelimiter as [@column-delimiter]
		,@LineDelimiter as [@line-delimiter]
		,@UseSafeExport as [@use-safe-export]
		,@SelectStatement as [select-statement]
		for xml path ('parameter')
		)
		
		
	IF @UsesEvtLogging=1
	BEGIN
		exec Evt.MessageHandle
		@MessageSpaceKeyword=@ESpace
		,@MessageKeyword=@EMessage
		,@TypeKeyword=@ETypeKeyword
		,@ModuleName=@EModule
		,@ProcessGUID=@ProcessGUID
		,@AdHocDefinition=@EDef
		,@AdHocMsg=@EMsg
	END
	ELSE
	BEGIN
		PRINT 'EXEC Bcp.Export
			@SelectStatement=' + @SelectStatement
			+ '
			,@ColumnDelimiter=' + @ColumnDelimiter
			+ '
			,@LineDelimiter=' + @LineDelimiter
			+ '
			,@DestinationLocation=' + @DestinationLocation
			+ '
			,@AllowOverwrites=' + convert(nvarchar, @AllowOverwrites)
			+ '
			,@ProcessGUID=' + convert(nvarchar, @ProcessGUID)
			+'
			,@UseSafeExport='+ convert(nvarchar, @UseSafeExport)
			+'
			,@SafeExportMaxErrors='+convert(nvarchar,@lSafeExportMaxErrors)
			+'
			,@SafeExportFormatEnum='+convert(nvarchar,@lSafeExportFormatEnum)
	END

	BEGIN TRY

		EXEC Bcp.ClrExport
		@SourceServer=@lServerName,
		@SourceDatabase=@lDatabaseName,
		@SelectStatement=@SelectStatement,
		@ColumnDelimiter=@ColumnDelimiter,
		@LineDelimiter=@LineDelimiter,
		@DestinationLocation=@DestinationLocation,
		@AllowOverwrites=@AllowOverwrites,
		@UsesEvtLogging=@UsesEvtLogging,
		@DoesExtendedLogging=@DoesExtendedLogging,
		@ProcessGUID=@ProcessGUID,
		@ConnectionTimeout=@lConnTimeout,
		@UseSafeExport=@UseSafeExport,
		@SafeExportMaxErrors=@lSafeExportMaxErrors,
		@SafeExportFormatEnum=@lSafeExportFormatEnum
		
	
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
	
	IF @UsesEvtLogging=1
	BEGIN
		exec Evt.MessageHandle
		@MessageSpaceKeyword=@ESpace
		,@MessageKeyword=@EMessage
		,@TypeKeyword=@ETypeKeyword
		,@ModuleName=@EModule
		,@ProcessGUID=@ProcessGUID
		,@AdHocDefinition=@EDef
		,@AdHocMsg=@EMsg
	END
	ELSE
	BEGIN
		PRINT @EMsg
	END
END
go

exec DbDoc.ObjectParse @ObjectName=Export, @SchemaName=Bcp
go