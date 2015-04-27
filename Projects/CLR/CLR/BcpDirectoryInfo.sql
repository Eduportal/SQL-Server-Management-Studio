if exists (select * from sysobjects
           where  id = object_id('Bcp.DirectoryInfo'))
BEGIN
   DROP FUNCTION Bcp.DirectoryInfo
END
go

-- =============================================
-- Author:		D. Nambi
-- Create date:	 2007-12-18
-- Description:	Table-valued function that returns a list of files for a given location and file match.
-- =============================================
CREATE FUNCTION Bcp.DirectoryInfo
	(
	 @FileOrDirectoryLocation nvarchar(4000)
	,@FileNameFilter nvarchar(128)=null
	)
RETURNS @r TABLE (
	[FileName] nvarchar(800) NULL,
	[Extension] nvarchar(32) NULL,
	[SizeInBytes] int NULL,
	[LastModifiedDate] datetime NULL,
	[LastAccessDate] datetime NULL,
	[CreationDate] datetime NULL,
	[IsReadOnly] bit NULL
)
AS
/*
<DbDoc>
	<object
description="Return a list of files and their information for the given directory or file path."
		>
		<parameters>
			<parameter name="@FileOrDirectoryLocation" description="The location of the file or directory to return a file list for."/>
			<parameter name="@FileNameFilter" description="The optional file filter (such as *.* to use when filtering out files to return." />
		</parameters>
	</object>
</DbDoc>
*/
BEGIN
	SET @FileNameFilter=coalesce(@FileNameFilter, Cfg.GetString('BcpTransfer','FileNameFilter'));

	INSERT INTO @r
		(
		FileName
		,Extension
		,SizeInBytes
		,LastModifiedDate
		,LastAccessDate
		,CreationDate
		,IsReadOnly
		)
	SELECT
		 FileName
		,Extension
		,SizeInBytes
		,LastModifiedDate
		,LastAccessDate
		,CreationDate
		,IsReadOnly
	FROM Bcp.ClrDirectoryInfo
		(
		 @FileOrDirectoryLocation
		,@FileNameFilter
		)
		
	return
END
GO


exec DbDoc.ObjectParse @ObjectName=DirectoryInfo, @SchemaName=Bcp
go