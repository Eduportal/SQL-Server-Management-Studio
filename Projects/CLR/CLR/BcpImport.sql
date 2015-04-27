if not exists (select * from sysobjects
           where  id = object_id('Bcp.Import')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('create procedure Bcp.Import as return')
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		D. Nambi
-- Create date: 	2007-12-15
-- =============================================
ALTER PROCEDURE Bcp.Import
	 @FileLocation nvarchar(512)
	,@ColumnDelimiter nvarchar(32)=null
	,@LineDelimiter nvarchar(32)=null
	,@DestinationTable nvarchar(128)
	,@ProcessGUID uniqueidentifier=null
	,@UseSafeImport bit=null
	,@TestMode bit=0
AS

/*
<DbDoc>
	<object
		description="Import data into a given location using "
		>
		<parameters>
			<parameter name="@FileLocation" description="The location of the file to import"/>
			<parameter name="@ColumnDelimiter" description="The character(s) to use as a column delimiter." />
			<parameter name="@LineDelimiter" description="The character(s) to use as a line/row delimiter." />
			<parameter name="@ProcessGUID" description="What is the ProcessGUID of the method that is calling this sproc? Defaults to newid()"/>
			<parameter name="@UseSafeImport" description="1=Use hex-based text for all text columns, requires Bcp.Import to load. 0=use raw text for all text columns, requires BULK INSERT to load" />
		</parameters>
	</object>
</DbDoc>


ColumnMapping schema:
<ColumnMapping>
	<Column
		DestinationColumn="[Column Name or alias]"
		ColumnNumber="[ordinal position of the column]"
		DataTypeNET="[the .NET datatype (System.Decimal, etc)]"
	/>
</ColumnMapping>
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @DoesExtendedLogging bit
			,@ESpace varchar(32)
			,@EMessage varchar(32)
			,@EModule sysname
			,@EDef xml
			,@ETypeKeyword varchar(16)
			,@EMsg nvarchar(max)
			,@lServerName nvarchar(128)
			,@lDatabaseName nvarchar(128)
			,@lCmd nvarchar(max)
			,@cT nchar(2)

	SET @cT=nchar(13)+nchar(10)
	SET @lServerName=@@servername
	SET @lDatabaseName=db_name();
	SET @DoesExtendedLogging=Cfg.GetBit('BcpTransfer', 'DoesExtendedLogging');
	SET @ColumnDelimiter=coalesce(@ColumnDelimiter, Cfg.GetString('BcpTransfer','ColumnDelimiter'));
	SET @LineDelimiter=coalesce(@LineDelimiter, Cfg.GetString('BcpTransfer','RowDelimiter'));
	set @UseSafeImport=coalesce(@UseSafeImport, Cfg.GetBit('BcpTransfer','UseSafeImport'));
	SET @ProcessGUID=coalesce(@ProcessGUID, newid());
	SET @EModule=N'Bcp.Import'
	SET @ESpace=N'EVT_BCP'
	SET @EMessage=N'EVT_IMPORT'
	SET @ETypeKeyword='EVT_START'
	SET @EMsg=N'Begin Bcp.Import operation'+case when @UseSafeImport=1 then ' using safe import' else 'using BULK INSERT' end
	SET @EDef=(
		select
		 @FileLocation as [@file-location]
		,@DestinationTable as [@destination-table]
		,@UseSafeImport as [@use-safe-import]
		,@ColumnDelimiter as [@column-delimiter]
		,@LineDelimiter as [@line-delimiter]
		,@TestMode as [@test-mode]
		for xml path ('parameter')
		)
		
	exec Evt.MessageHandle
	@MessageSpaceKeyword=@ESpace
	,@MessageKeyword=@EMessage
	,@TypeKeyword=@ETypeKeyword
	,@ModuleName=@EModule
	,@ProcessGUID=@ProcessGUID
	,@AdHocDefinition=@EDef
	,@AdHocMsg=@EMsg
		

	BEGIN TRY

		if @UseSafeImport=1
		begin
			set @lCmd='BULK INSERT '+@DestinationTable
			+@cT+'FROM '''+@FileLocation+''''
			+@cT+'WITH ('
			+@cT+'DATAFILETYPE=''widenative'''
			+@cT+',TABLOCK'
			+@cT+')'
		end
		else
		begin
			set @lCmd='BULK INSERT '+@DestinationTable
			+@cT+'FROM '''+@FileLocation+''''
			+@cT+'WITH ('
			+@cT+'FIELDTERMINATOR='''+@ColumnDelimiter+''''
			+@cT+',ROWTERMINATOR='''+@LineDelimiter+''''
			+@cT+',DATAFILETYPE=''widechar'''
			+@cT+',TABLOCK'
			+@cT+')'
		end
	
		
		
		if @TestMode=1
		begin
			print @lCmd
		end
		else
		begin
			exec (@lCmd)
		end

		SET @ETypeKeyword='EVT_SUCCESS'
		SET @EMsg='Bcp.Import operation successful'
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
	@MessageSpaceKeyword=@ESpace
	,@MessageKeyword=@EMessage
	,@TypeKeyword=@ETypeKeyword
	,@ModuleName=@EModule
	,@ProcessGUID=@ProcessGUID
	,@AdHocDefinition=@EDef
	,@AdHocMsg=@EMsg

END
go

exec DbDoc.ObjectParse @ObjectName=Export, @SchemaName=Bcp
go