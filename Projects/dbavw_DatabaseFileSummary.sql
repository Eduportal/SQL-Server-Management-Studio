CREATE VIEW	dbavw_DatabaseFileSummary
AS
/****************************************************************************
<CommentHeader>
	<VersionControl>
 		<DatabaseName>dbaadmin</DatabaseName>				
		<SchemaName>dbo</SchemaName>
		<ObjectType>View</ObjectType>
		<ObjectName>dbavw_DatabaseFileSummary</ObjectName>
		<Version>1.0.0</Version>
		<Created By="Steve Ledridge" On="09/09/2011"/>
		<Modified By="" On="" Reason=""/>
	</VersionControl>
	<Purpose>Provide Summary of Drive Usage by Database Devices</Purpose>
	<Description>This was Created in order to detect if TempDB or Systsem Databases were on Dedicated Drives</Description>
	<Dependencies>
		<Object Type="" Name="" Version=""/>
	</Dependencies>
	<Parameters>
		<Parameter Type="" Name="" Desc=""/>
	</Parameters>
</CommentHeader>
*****************************************************************************/

SELECT		DB_NAME(database_id) AS [DatabaseName]
		,type_desc AS [DeviceType]
		,CASE 
			WHEN DB_NAME(database_id) IN ('master','model','msdb') THEN 'System'
			WHEN DB_NAME(database_id) IN ('tempdb') THEN 'Temp'
			WHEN DB_NAME(database_id) IN ('dbaadmin','dbaperf','deplinfo','dbacentral','gears','deplcontrol') THEN 'Operations'
			ELSE 'User' END AS [DatabaseType]
		,UPPER(LEFT(physical_name,1)) AS [Drive]
		,count(*) AS [Devices]
		,sum(size) AS [Size]
FROM		sys.master_files
GROUP BY	DB_NAME(database_id)
		,type_desc
		,CASE 
			WHEN DB_NAME(database_id) IN ('master','model','msdb') THEN 'System'
			WHEN DB_NAME(database_id) IN ('tempdb') THEN 'Temp'
			WHEN DB_NAME(database_id) IN ('dbaadmin','dbaperf','deplinfo','dbacentral','gears','deplcontrol') THEN 'Operations'
			ELSE 'User' END
		,UPPER(LEFT(physical_name,1))
GO