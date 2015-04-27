if exists (select * from sysobjects
           where  id = object_id('Bcp.ClrCopy')
           and    objectproperty(id,'IsProcedure') = 1)
BEGIN
	DROP PROCEDURE Bcp.ClrCopy
END
GO

CREATE PROCEDURE Bcp.ClrCopy
	@SourceLocation nvarchar(4000),
	@DestinationLocation nvarchar(4000),
	@AllowOverwrites bit,
	@DoesExtendedLogging bit,
	@ProcessGUID uniqueidentifier
AS
/*
<DbDoc>
	<object
description="Copy a file from one place to another."
		>
		<parameters>
			<parameter name="@SourceLocation" description="The location of the file to copy from." />
			<parameter name="@DestinationLocation" description="The location of the file to copy to." />
			<parameter name="@AllowOverwrites" description="1=Overwrite the file if it exists. 0=Do not overwrite an existing file, error if it already exists." />
			<parameter name="@DoesExtendedLogging" description="1=Do extended (diagnostic) logging. 0=Do standard amounts of logging." />
			<parameter name="@ProcessGUID" description="What is the ProcessGUID of the method that is calling this sproc? Used for Evt logging." />
		</parameters>
	</object>
</DbDoc>
*/
EXTERNAL NAME BcpTransfer.StoredProcedures.ClrCopy
GO

exec DbDoc.ObjectParse @ObjectName=ClrCopy, @SchemaName=Bcp
go