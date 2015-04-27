if exists (select * from sysobjects
           where  id = object_id('Bcp.ClrComputeHash')
           and    objectproperty(id,'IsProcedure') = 1)
BEGIN
	DROP PROCEDURE Bcp.ClrComputeHash
END
GO

CREATE PROCEDURE Bcp.ClrComputeHash
	@FileLocation nvarchar(4000),
	@UsesEvtLogging bit,
	@DoesExtendedLogging bit,
	@ProcessGUID uniqueidentifier,
	@HashValue uniqueidentifier output
AS
/*
<DbDoc>
	<object
description="Compute the MD5 hash of a file."
		>
		<parameters>
			<parameter name="@FileLocation" description="The location of the file to compute a hash for."/>
			<parameter name="@UsesEvtLogging" description="Use the Evt reusable for log messages" />
			<parameter name="@DoesExtendedLogging" description="Do extended (diagnostic-) level logging. Useful for debugging purposes." />
			<parameter name="@ProcessGUID" description="What is the ProcessGUID of the method that is calling this sproc? Defaults to newid(). Used for Evt logging."/>
			<parameter name="@HashValue" description="Outputs the MD5 hash value of the file as a GUID (128-bit hex value)" />
		</parameters>
	</object>
</DbDoc>
*/
EXTERNAL NAME BcpTransfer.StoredProcedures.ClrComputeHash
GO

exec DbDoc.ObjectParse @ObjectName=ClrComputeHash, @SchemaName=Bcp
go