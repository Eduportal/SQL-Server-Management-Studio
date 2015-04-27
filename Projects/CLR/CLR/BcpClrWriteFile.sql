if exists (select * from sysobjects
           where  id = object_id('Bcp.ClrWriteFile')
           and    objectproperty(id,'IsProcedure') = 1)
BEGIN
	DROP PROCEDURE Bcp.ClrWriteFile
END
GO

CREATE PROCEDURE Bcp.ClrWriteFile
	@TextToWrite nvarchar(max),
	@DestinationLocation nvarchar(4000),
	@AllowOverwrites bit,
	@UsesEvtLogging bit,
	@ProcessGUID uniqueidentifier
AS
/*
<DbDoc>
	<object
description="Write the given text to a file."
		>
		<parameters>
			<parameter name="@TextToWrite" description="All of the text to write to the given file location."/>
			<parameter name="@DestinationLocation" description="The location of the file to write to." />
			<parameter name="@AllowOverwrites" description="1=Overwrite the file if it exists. 0=Do not overwrite an existing file, error if it already exists." />
			<parameter name="@UsesEvtLogging" description="1=Use Evt logs to write log messages. 0=Print the log messages to the screen." />
			<parameter name="@ProcessGUID" description="What is the ProcessGUID of the method that is calling this sproc? Used for Evt logging." />
		</parameters>
	</object>
</DbDoc>
*/
EXTERNAL NAME BcpTransfer.StoredProcedures.ClrWriteFile
GO

exec DbDoc.ObjectParse @ObjectName=ClrWriteFile, @SchemaName=Bcp
go