if exists (select * from sysobjects
           where  id = object_id('Bcp.ClrDelete')
           and    objectproperty(id,'IsProcedure') = 1)
BEGIN
	DROP PROCEDURE Bcp.ClrDelete
END
GO

CREATE PROCEDURE Bcp.ClrDelete
	@FileLocation nvarchar(4000),
	@DoesExtendedLogging bit,
	@ProcessGUID uniqueidentifier
AS
/*
<DbDoc>
	<object
description="Copy a file from one place to another."
		>
		<parameters>
			<parameter name="@FileLocation" description="The location of the file to delete." />
			<parameter name="@DoesExtendedLogging" description="1=Do extended (diagnostic) logging. 0=Do standard amounts of logging." />
			<parameter name="@ProcessGUID" description="What is the ProcessGUID of the method that is calling this sproc? Used for Evt logging." />
		</parameters>
	</object>
</DbDoc>
*/
EXTERNAL NAME BcpTransfer.StoredProcedures.ClrDelete
GO

exec DbDoc.ObjectParse @ObjectName=ClrDelete, @SchemaName=Bcp
go