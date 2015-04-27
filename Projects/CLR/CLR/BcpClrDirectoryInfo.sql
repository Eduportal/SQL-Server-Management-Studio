

if exists (select * from sysobjects
           where  id = object_id('Bcp.ClrDirectoryInfo'))
BEGIN
	DROP FUNCTION Bcp.ClrDirectoryInfo
END
GO

CREATE FUNCTION [Bcp].[ClrDirectoryInfo](@FileOrDirectoryName [nvarchar](4000), @FileNameFilter [nvarchar](4000))
RETURNS  TABLE (
	[FileName] [nvarchar](800) NULL,
	[Extension] [nvarchar](32) NULL,
	[SizeInBytes] [int] NULL,
	[LastModifiedDate] [datetime] NULL,
	[LastAccessDate] [datetime] NULL,
	[CreationDate] [datetime] NULL,
	[IsReadOnly] [bit] NULL
)
AS 
EXTERNAL NAME [BcpTransfer].[UserDefinedFunctions].[ClrDirectoryInfo]
GO