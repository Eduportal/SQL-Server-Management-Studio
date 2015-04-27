if exists (select * from sysobjects
           where  id = object_id('Bcp.ClrTransfer')
           and    objectproperty(id,'IsProcedure') = 1)
BEGIN
	DROP PROCEDURE Bcp.ClrTransfer
END
GO

CREATE PROCEDURE Bcp.ClrTransfer
	@SourceServer nvarchar(4000),
	@SourceDatabase nvarchar(4000),
	@DestinationServer nvarchar(4000),
	@DestinationDatabase nvarchar(4000),
	@DestinationTable nvarchar(4000),
	@SelectStatement nvarchar(4000),
	@ColumnMappings xml,
	@BatchSize int,
	@ConnectionTimeout int,
	@UseOneTransaction bit,
	@UseMultipleTransactions bit,
	@DoTableLock bit,
	@CheckConstraints bit,
	@FireTriggers bit,
	@KeepIdentityValues bit,
	@KeepNulls bit,
	@TestMode bit,
	@UsesEvtLogging bit,
	@DoesExtendedLogging bit,
	@DoesRowCounts bit,
	@ProcessGUID uniqueidentifier
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
			<parameter name="@ColumnMappings" description="An XML parameter that contains the column mappings from the select statement's result columns to the destination table's columns. Is in the format <ColumnMapping></ColumnMapping>"/>
			<parameter name="@BatchSize" description="The size of the batches to be done via BCP. Note that the default is 0, which means all data will be transferred at once."/>
			<parameter name="@ConnectionTimeout" description="The connection timeout in sections for the source and destination connections. Increasing this value may potentially slow down the performance of the transfer, but improve reliability."/>
			<parameter name="@UseOneTransaction" description="Should a single transaction be used when transferring data? Doing so has the best integrity prospects, but will automatically roll back the copy on any errors."/>
			<parameter name="@UseMultipleTransactions" description="Should each internal batch have its own transaction? This option is overriden by the UseOneTransaction option."/>
			<parameter name="@DoTableLock" description="Should a table lock be put on the destination table?"/>
			<parameter name="@CheckConstraints" description="When loading the data into the destination table, should constraints be checked?"/>
			<parameter name="@FireTriggers" description="When loading data into the destination table, should triggers be fired?"/>
			<parameter name="@KeepIdentityValues" description="Should identity values from the source statement be kept?"/>
			<parameter name="@KeepNulls" description="Should nulls be propagated to the destination? Or should possible default values be allowed to populate results at the destination?"/>
			<parameter name="@TestMode" description="Run the procedure in test mode. Does everything but actually write the results to the destination table." />
			<parameter name="@UsesEvtLogging" description="Use the Evt reusable for log messages" />
			<parameter name="@DoesExtendedLogging" description="Do extended (diagnostic-) level logging. Useful for debugging purposes." />
			<parameter name="@DoesRowCounts" description="If enabled, has the source connection maintain connection statistics, to provide row counts. This introduces some overhead, which could slow down the transfer operation." />
			<parameter name="@ProcessGUID" description="What is the ProcessGUID of the method that is calling this sproc? Defaults to newid(). Used for Evt logging."/>
		</parameters>
	</object>
</DbDoc>
*/
EXTERNAL NAME BcpTransfer.StoredProcedures.ClrTransfer
GO

exec DbDoc.ObjectParse @ObjectName=ClrTransfer, @SchemaName=Bcp
go