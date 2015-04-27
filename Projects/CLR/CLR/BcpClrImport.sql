if exists (select * from sysobjects
           where  id = object_id('Bcp.ClrImport')
           and    objectproperty(id,'IsProcedure') = 1)
BEGIN
	DROP PROCEDURE Bcp.ClrImport
END
GO

CREATE PROCEDURE Bcp.ClrImport
	@FileLocation nvarchar(512),
	@ColumnDelimiter nvarchar(4000),
	@LineDelimiter nvarchar(4000),
	@DestinationServerName nvarchar(128),
	@DestinationDatabaseName nvarchar(128),
	@DestinationTable nvarchar(128),
	@ColumnMapping xml,
	@ProcessGUID uniqueidentifier
AS
/*
<DbDoc>
	<object
description="Export data to a file."
		>
		<parameters>
			<parameter name="@FileLocation" description="The location of the file to import from."/>
			<parameter name="@ColumnDelimiter" description="The column delimiter to use when exporting to a file." />
			<parameter name="@LineDelimiter" description="The row/line delimiter to use when exporting to a file." />
			<parameter name="@DestinationTable" description="The name of the table to import into." />
			<parameter name="@ProcessGUID" description="What is the ProcessGUID of the method that is calling this sproc? Used for Evt logging." />
		</parameters>
	</object>
</DbDoc>
*/
EXTERNAL NAME BcpTransfer.StoredProcedures.ClrImport
GO

exec DbDoc.ObjectParse @ObjectName=ClrImport, @SchemaName=Bcp
go