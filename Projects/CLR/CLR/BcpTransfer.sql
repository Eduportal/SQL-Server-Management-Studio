if not exists (select * from sysobjects
           where  id = object_id('Bcp.Transfer')
           and    objectproperty(id,'IsProcedure') = 1)
   exec ('create procedure Bcp.Transfer as return')
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		D. Nambi
-- Create date: 2007-08-29
-- Description:	Stored procedure that pulls data from Cfg and the caller 
-- and then passes it to the CLR sproc Bcp.ClrTransfer(), which does the bulk copy.
-- =============================================
ALTER PROCEDURE Bcp.Transfer
	@SourceServer nvarchar(4000)
  ,@SourceDatabase nvarchar(4000)
  ,@DestinationServer nvarchar(4000)
  ,@DestinationDatabase nvarchar(4000)
  ,@DestinationTable nvarchar(4000)
  ,@SelectStatement nvarchar(4000)
  ,@ColumnMappings XML
  ,@BatchSize int = 0
  ,@ConnectionTimeout int = 300
  ,@UseOneTransaction bit = true
  ,@UseMultipleTransactions bit = false
  ,@DoTableLock bit = true
  ,@CheckConstraints bit = true
  ,@FireTriggers bit = true
  ,@KeepIdentityValues bit = true
  ,@KeepNulls bit = true
  ,@ProcessGUID uniqueidentifier
AS
/*
<DbDoc>
	<object
		description="Transfer data via Bulk Copy (BCP)"
		>
		<parameters>
			<parameter name="@SourceServer" description="The hostname of the database server that contains the source data"/>
			<parameter name="@SourceDatabase" description="The name of the database that contains the source data"/>
			<parameter name="@DestinationServer" description="The hostname of the database server that is the destination for the data"/>
			<parameter name="@DestinationDatabase" description="The name of the database that is the destination for the data"/>
			<parameter name="@DestinationTable" description="The name of the table (optionally including schema) that is the destination for the data"/>
			<parameter name="@SelectStatement" description="A select statement that retrieves the data to be moved. The statement can be very intricate, but must not include any SQL injection keywords (DROP, INSERT, ALTER, GRANT, TRUNCATE, DELETE, etc)"/>
			<parameter name="@ColumnMappings" description="An XML parameter that contains the column mappings from the select statement's result columns to the destination table's columns. See internal comments for xml definition"/>
			<parameter name="@BatchSize" description="The size of the batches to be done via BCP. Note that the default is 0, which means all data will be transferred at once."/>
			<parameter name="@ConnectionTimeout" description="The connection timeout in sections for the source and destination connections. Increasing this value may potentially slow down the performance of the transfer, but improve reliability."/>
			<parameter name="@UseOneTransaction" description="Should a single transaction be used when transferring data? Doing so has the best integrity prospects, but will automatically roll back the copy on any errors."/>
			<parameter name="@UseMultipleTransactions" description="Should each internal batch have its own transaction? This option is overriden by the UseOneTransaction option."/>
			<parameter name="@DoTableLock" description="Should a table lock be put on the destination table?"/>
			<parameter name="@CheckConstraints" description="When loading the data into the destination table, should constraints be checked?"/>
			<parameter name="@FireTriggers" description="When loading data into the destination table, should triggers be fired?"/>
			<parameter name="@KeepIdentityValues" description="Should identity values from the source statement be kept?"/>
			<parameter name="@KeepNulls" description="Should nulls be propagated to the destination? Or should possible default values be allowed to populate results at the destination?"/>
			<parameter name="@ProcessGUID" description="What is the ProcessGUID of the method that is calling this sproc? Defaults to newid()"/>
		</parameters>
	</object>
</DbDoc>

The @ColumnMapping schema is in the format
<ColumnMapping>
	<Column SourceColumn="[Column Name or alias]" DestinationColumn="[Column Name or alias]"
</ColumnMapping>
*/
BEGIN
	SET NOCOUNT ON;

	DECLARE @UsesEvtLogging bit
			,@DoesExtendedLogging bit
			,@TestMode bit
			,@DoesRowCounts bit
			,@EDef xml

	SELECT 	@UsesEvtLogging = Cfg.GetBit('BcpTransfer','UseEvtLogging'),
		@DoesExtendedLogging = Cfg.GetBit('BcpTransfer','DoesExtendedLogging'),
		@TestMode = Cfg.GetBit('BcpTransfer','IsInTestMode'),
		@DoesRowCounts = Cfg.GetBit('BcpTransfer','DoesRowCounts')
		
	SET @EDef=(
		select
			@SourceServer as [@source-server]
			,@SourceDatabase as [@source-database]
			,@DestinationServer as [@destination-server]
			,@DestinationDatabase as [@destination-database]
			,@DestinationTable as [@destination-table]
			,@BatchSize as [@batch-size]
			,@DoTableLock as [@do-table-lock]
			,@ConnectionTimeout as [@connection-timeout]
			,@FireTriggers as [@fire-triggers]
			,@CheckConstraints as [@check-constraints]
			,@KeepIdentityValues as [@keep-identity-values]
			,@KeepNulls as [@keep-nulls]
			,@UseOneTransaction as [@use-one-transaction]
			,@UseMultipleTransactions as [@use-multiple-transactions]
			,@DoesRowCounts as [@does-row-counts]
			,@DoesExtendedLogging as [@do-extended-logging]
			,@SelectStatement as [select-statement]
			,@ColumnMappings as [column-mapping]
		for xml path ('parameter')
		)
		
	if @UsesEvtLogging=1
	begin
		exec Evt.MessageHandle
		@MessageSpaceKeyword='EVT_BCP'
		,@MessageKeyword='EVT_TRANSFER'
		,@TypeKeyword='EVT_START'
		,@ModuleName='Bcp.Transfer'
		,@ProcessGUID=@ProcessGUID
		,@AdHocDefinition=@EDef
	end

    EXECUTE Bcp.ClrTransfer
   @SourceServer=@SourceServer
  ,@SourceDatabase=@SourceDatabase
  ,@DestinationServer=@DestinationServer
  ,@DestinationDatabase=@DestinationDatabase
  ,@DestinationTable=@DestinationTable
  ,@SelectStatement=@SelectStatement
  ,@ColumnMappings=@ColumnMappings
  ,@BatchSize=@BatchSize
  ,@ConnectionTimeout=@ConnectionTimeout
  ,@UseOneTransaction=@UseOneTransaction
  ,@UseMultipleTransactions=@UseMultipleTransactions
  ,@DoTableLock=@DoTableLock
  ,@CheckConstraints=@CheckConstraints
  ,@FireTriggers=@FireTriggers
  ,@KeepIdentityValues=@KeepIdentityValues
  ,@KeepNulls=@KeepNulls
  ,@TestMode=@TestMode
  ,@UsesEvtLogging=@UsesEvtLogging
  ,@DoesExtendedLogging=@DoesExtendedLogging
  ,@DoesRowCounts=@DoesRowCounts
  ,@ProcessGUID=@ProcessGUID
  
END
go

exec DbDoc.ObjectParse @ObjectName=Transfer, @SchemaName=Bcp
go