if exists (select * from sysobjects
           where  id = object_id('Bcp.ClrExport')
           and    objectproperty(id,'IsProcedure') = 1)
BEGIN
	DROP PROCEDURE Bcp.ClrExport
END
GO

CREATE PROCEDURE Bcp.ClrExport
	@SourceServer nvarchar(4000),
	@SourceDatabase nvarchar(4000),
	@SelectStatement nvarchar(4000),
	@ColumnDelimiter nvarchar(4000),
	@LineDelimiter nvarchar(4000),
	@DestinationLocation nvarchar(4000),
	@AllowOverwrites bit,
	@UsesEvtLogging bit,
	@DoesExtendedLogging bit,
	@ProcessGUID uniqueidentifier,
	@ConnectionTimeout int,
	@UseSafeExport bit,
	@SafeExportMaxErrors int,
	@SafeExportFormatEnum smallint
AS
/*
<DbDoc>
	<object
description="Export data to a file."
		>
		<parameters>
			<parameter name="@SelectStatement" description="A select statement that retrieves the data to be written to a file."/>
			<parameter name="@ColumnDelimiter" description="The column delimiter to use when exporting to a file." />
			<parameter name="@LineDelimiter" description="The row/line delimiter to use when exporting to a file." />
			<parameter name="@DestinationLocation" description="The location of the file to write to." />
			<parameter name="@AllowOverwrites" description="1=Overwrite the file if it exists. 0=Do not overwrite an existing file, error if it already exists." />
			<parameter name="@UsesEvtLogging" description="1=Use Evt logs to write log messages. 0=Print the log messages to the screen." />
			<parameter name="@DoesExtendedLogging" description="1=Do extended (diagnostic) logging. 0=Do standard amounts of logging." />
			<parameter name="@ProcessGUID" description="What is the ProcessGUID of the method that is calling this sproc? Used for Evt logging." />
		</parameters>
	</object>
</DbDoc>
*/
EXTERNAL NAME BcpTransfer.StoredProcedures.ClrExport
GO

exec DbDoc.ObjectParse @ObjectName=ClrExport, @SchemaName=Bcp
go