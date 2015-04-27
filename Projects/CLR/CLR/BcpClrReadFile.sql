if exists (select * from sysobjects
           where  id = object_id('Bcp.ClrReadFile')
           and    objectproperty(id,'IsProcedure') = 1)
BEGIN
	DROP PROCEDURE Bcp.ClrReadFile
END
GO

CREATE PROCEDURE Bcp.ClrReadFile
	@FileLocation nvarchar(4000),
	@ProcessGUID uniqueidentifier,
	@FileContent nvarchar(max) output
AS
/*
<DbDoc>
	<object
description="Read the given text from a file."
		>
	</object>
</DbDoc>
*/
EXTERNAL NAME BcpTransfer.StoredProcedures.ClrReadFile
GO

exec DbDoc.ObjectParse @ObjectName=ClrReadFile, @SchemaName=Bcp
go