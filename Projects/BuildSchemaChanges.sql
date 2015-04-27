DROP	TABLE	[dbo].[BuildSchemaChanges]
GO
/****************************************************************************
-- PUT MOST RECENT MODIFICATION ENTRY ABOVE OTHER SO MOST RECENT IS FIRST
--
<CommentHeader>
	<VersionControl>
 		<DatabaseName></DatabaseName>				
		<SchemaName></SchemaName>
		<ObjectType>Table</ObjectType>
		<ObjectName>BuildSchemaChanges</ObjectName>
		<Version>1.0.0</Version>
		<Created By="Steve Ledridge" On="09/10/2011"/>
		<Modified By="" On="" Reason=""/>
	</VersionControl>
	<Purpose>Audit History of all DDL Changes</Purpose>
	<Description>This was Created in order to automate DB Object Versioning</Description>
	<Dependencies>
		<Object Type="" Name="" Version=""/>
	</Dependencies>
	<Parameters>
		<Parameter Type="" Name="" Desc=""/>
	</Parameters>
</CommentHeader>
*****************************************************************************/
CREATE	TABLE	[dbo].[BuildSchemaChanges]
	(
	[LogId]			[bigint] IDENTITY(1,1)	NOT NULL CONSTRAINT [PK_BuildSchemaChanges] PRIMARY KEY CLUSTERED,
	[EventType]		[sysname]		NOT NULL,
	[DatabaseName]		[sysname]		NOT NULL,
	[SchemaName]		[sysname]		NOT NULL,
	[ObjectName]		[sysname]		NOT NULL,
	[ObjectType]		[sysname]		NOT NULL,
	[SqlCommand]		[varchar](max)		NOT NULL,
	[EventDate]		[datetime]		NOT NULL CONSTRAINT [DF_BuildSchemaChanges_EventDate] DEFAULT (getdate()),
	[LoginName]		[sysname]		NOT NULL,
	[UserName]		[sysname]		NOT NULL,
	[VC_DatabaseName]	[sysname]		NULL,
	[VC_SchemaName]		[sysname]		NULL,
	[VC_ObjectType]		[sysname]		NULL,
	[VC_ObjectName]		[sysname]		NULL,
	[VC_Version]		[sysname]		NULL,
	[VC_CreatedBy]		[sysname]		NULL,
	[VC_CreatedOn]		[DateTime]		NULL,
	[VC_ModifiedBy]		[sysname]		NULL,
	[VC_ModifiedOn]		[sysname]		NULL
	)
GO		