use master;

DECLARE	@Settings Table (ParamName VarChar(255),ParamValue VarChar(255))

INSERT INTO @Settings
Select  'ServerName' ,CAST(@@servername AS VarChar(255)) 
UNION ALL
Select  CAST('ProcessorCount' AS VarChar(255)) As ParamName, CAST(count(*) AS VarChar(255)) AS ParamValue from sys.dm_os_schedulers where is_online = 1 and scheduler_id < 255 
UNION ALL
Select  'ServerStart' ,CAST(convert(nvarchar,login_time) AS VarChar(255)) from sys.sysprocesses where spid=1
UNION ALL
Select  'JobCount'	,CAST(count(distinct job_id) AS VarChar(255)) from msdb..sysjobs
UNION ALL
Select'BuildClrVersion' ,CAST(convert(sysname, serverproperty('BuildClrVersion')) AS VarChar(255))
UNION ALL
Select'Collation' ,CAST(convert(sysname, serverproperty('Collation')) AS VarChar(255))
UNION ALL
Select'CollationID' ,CAST(convert(sysname, serverproperty('CollationID')) AS VarChar(255))
UNION ALL
Select'ComparisonStyle' ,CAST(convert(sysname, serverproperty('ComparisonStyle')) AS VarChar(255))
UNION ALL
Select'ComputerNamePhysicalNetBIOS' ,CAST(convert(sysname, serverproperty('ComputerNamePhysicalNetBIOS')) AS VarChar(255))
UNION ALL
Select'Edition' ,CAST(convert(sysname, serverproperty('Edition')) AS VarChar(255))
UNION ALL
Select'EditionID' ,CAST(convert(sysname, serverproperty('EditionID')) AS VarChar(255))
UNION ALL
Select'EngineEdition' ,CAST(convert(sysname, serverproperty('EngineEdition')) AS VarChar(255))
UNION ALL
Select'InstanceName' ,CAST(convert(sysname, serverproperty('InstanceName')) AS VarChar(255))
UNION ALL
Select'IsClustered' ,CAST(convert(sysname, serverproperty('IsClustered')) AS VarChar(255))
UNION ALL
Select'IsFullTextInstalled' ,CAST(convert(sysname, serverproperty('IsFullTextInstalled')) AS VarChar(255))
UNION ALL
Select'IsIntegratedSecurityOnly' ,CAST(convert(sysname, serverproperty('IsIntegratedSecurityOnly')) AS VarChar(255))
UNION ALL
Select'IsSingleUser' ,CAST(convert(sysname, serverproperty('IsSingleUser')) AS VarChar(255))
UNION ALL
Select'LCID' ,CAST(convert(sysname, serverproperty('LCID')) AS VarChar(255))
UNION ALL
Select'LicenseType' ,CAST(convert(sysname, serverproperty('LicenseType')) AS VarChar(255))
UNION ALL
Select'MachineName' ,CAST(convert(sysname, serverproperty('MachineName')) AS VarChar(255))
UNION ALL
Select'NumLicenses' ,CAST(convert(sysname, serverproperty('NumLicenses')) AS VarChar(255))
UNION ALL
Select'ProcessID' ,CAST(convert(sysname, serverproperty('ProcessID')) AS VarChar(255))
UNION ALL
Select'ProductVersion' ,CAST(convert(sysname, serverproperty('ProductVersion')) AS VarChar(255))
UNION ALL
Select'ProductLevel' ,CAST(convert(sysname, serverproperty('ProductLevel')) AS VarChar(255))
UNION ALL
Select'ResourceLastUpdateDateTime' ,CAST(convert(sysname, serverproperty('ResourceLastUpdateDateTime')) AS VarChar(255))
UNION ALL
Select'ServerName' ,CAST(convert(sysname, serverproperty('ServerName')) AS VarChar(255))
UNION ALL
Select'SqlCharSet' ,CAST(convert(sysname, serverproperty('SqlCharSet')) AS VarChar(255))
UNION ALL
Select'SqlCharSetName' ,CAST(convert(sysname, serverproperty('SqlCharSetName')) AS VarChar(255))
UNION ALL
Select'SqlSortOrder' ,CAST(convert(sysname, serverproperty('SqlSortOrder')) AS VarChar(255))
UNION ALL
Select'SqlSortOrderName' ,CAST(convert(sysname, serverproperty('SqlSortOrderName')) AS VarChar(255))
UNION ALL
Select'FilestreamShareName' ,CAST(convert(sysname, serverproperty('FilestreamShareName')) AS VarChar(255))
UNION ALL
Select'FilestreamConfiguredLevel' ,CAST(convert(sysname, serverproperty('FilestreamConfiguredLevel')) AS VarChar(255))
UNION ALL
Select'FilestreamEffectiveLevel' ,CAST(convert(sysname, serverproperty('FilestreamEffectiveLevel')) AS VarChar(255))

UPDATE	@Settings
SET	ParamValue = 'No'
WHERE	ParamName Like 'Is%'
AND	ParamValue = '0'

UPDATE	@Settings
SET	ParamValue = 'Yes'
WHERE	ParamName Like 'Is%'
AND	ParamValue != '0'

INSERT INTO @Settings
select Comment,CAST(Value AS VarChar(255)) from sys.sysconfigures
WHERE Comment Not Like 'Allow%'
AND	Comment NOT LIKE 'Disallow%'
AND	Comment NOT LIKE 'Show%'
AND	Comment NOT LIKE 'Create%'
AND	Comment NOT LIKE 'C2%'
AND	Comment NOT LIKE 'AWE%'
AND	Comment NOT LIKE 'CLR%'
AND	Comment NOT LIKE 'Common%'
AND	Comment NOT LIKE 'Enable%'
AND	Comment NOT LIKE 'Dedicated%'
AND	Comment NOT LIKE 'Priority%'
AND	Comment NOT LIKE 'Recovery%'
AND	Comment NOT LIKE 'Set%'
AND	Comment NOT LIKE 'Scan%'
AND	Comment NOT LIKE 'Transform%'
AND	Comment NOT LIKE 'Use%'

INSERT INTO @Settings
select Comment,CAST(CASE Value WHEN 0 THEN 'No' ELSE 'Yes' END AS VarChar(255)) from sys.sysconfigures
WHERE Comment  Like 'Allow%'
OR	Comment  LIKE 'Disallow%'
OR	Comment  LIKE 'Show%'
OR	Comment  LIKE 'Create%'
OR	Comment  LIKE 'C2%'
OR	Comment  LIKE 'AWE%'
OR	Comment  LIKE 'CLR%'
OR	Comment  LIKE 'Common%'
OR	Comment  LIKE 'Enable%'
OR	Comment  LIKE 'Dedicated%'
OR	Comment  LIKE 'Priority%'
OR	Comment  LIKE 'Recovery%'
OR	Comment  LIKE 'Set%'
OR	Comment  LIKE 'Scan%'
OR	Comment  LIKE 'Transform%'
OR	Comment  LIKE 'Use%'

SELECT * FROM @Settings
