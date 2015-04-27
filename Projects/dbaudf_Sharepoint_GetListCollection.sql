USE [dbaadmin]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[dbaudf_Sharepoint_GetListCollection]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
DROP FUNCTION [dbo].[dbaudf_Sharepoint_GetListCollection]
/****************************************************************************
-- PUT MOST RECENT MODIFICATION ENTRY ABOVE OTHER SO MOST RECENT IS FIRST
--
<CommentHeader>
	<Purpose>Drop Before Creating</Purpose>
</CommentHeader>
*****************************************************************************/
END
GO

USE [dbaadmin]
GO

CREATE FUNCTION [dbo].[dbaudf_Sharepoint_GetListCollection](@url [nvarchar](4000))
/****************************************************************************
-- PUT MOST RECENT MODIFICATION ENTRY ABOVE OTHER SO MOST RECENT IS FIRST
--
<CommentHeader>
	<VersionControl>
 		<DatabaseName>dbaadmin</DatabaseName>				
		<SchemaName></SchemaName>
		<ObjectType>Trigger</ObjectType>
		<ObjectName>tr_AuditDDLChange</ObjectName>
		<Version>1.0.0</Version>
		<Created By="Steve Ledridge" On="09/10/2010"/>
		<Modified By="Steve Ledridge" On="03/10/2011" Reason="Another test for the most recent reason"/>
		<Modified By="Steve Ledridge" On="03/10/2011" Reason="Just testing if this stuff is picked up"/>
	</VersionControl>
	<Purpose>Generate Audit History of all DDL Changes</Purpose>
	<Description>This was Created in order to automate DB Object Versioning</Description>
	<Dependencies>
		<Object Type="Table" Name="BuildSchemaChanges" VersionCompare=">=" Version="1.0.0"/>
	</Dependencies>
	<Parameters>
		<Parameter Type="" Name="" Desc=""/>
	</Parameters>
	<Permissions>
		<Perm Type="" Priv="" To="" With=""/>
	</Permissions>
</CommentHeader>
*****************************************************************************/ 
RETURNS  TABLE (
	[Name] [nvarchar](4000) NULL,
	[Title] [nvarchar](4000) NULL,
	[URL] [nvarchar](4000) NULL
) WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [GettyImages.Operations.CLRTools].[GettyImages.Operation.SharePointList].[dbaudf_Sharepoint_GetListCollection]
GO


