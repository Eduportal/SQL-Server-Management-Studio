
SET NOCOUNT ON
DECLARE @Type char(12) 
DECLARE @Version VarChar(10)
DECLARE @SubType char(12)
DECLARE @Name char(55) 
DECLARE @SubName char(55)
DECLARE @LastType char(12) 
DECLARE @LastSubType char(12)
DECLARE @LastName char(55) 
DECLARE @LastSubName char(55)
DECLARE @level int, @line char(67)
DECLARE @ReturnData	Table (
	RowID	int 		IDENTITY(1, 1),
	Type	Char(12),
	Name	Char(55),
	SubType	Char(12),
	SubName	Char(55),
	Version	VarChar(10))
DECLARE Parent_Cursor CURSOR
FOR Select Distinct Cast(RTRIM(Lvl1ObjectType) + 's _____________' As Char(12)) AS Type, Cast(Lvl1ObjectName As Char(55)) As Name, Cast(COALESCE(RTRIM(Lvl2ObjectType) + 's _____________',' ') As Char(12)) AS SubType, Cast(COALESCE(Lvl2ObjectName,' ') As Char(55)) As SubName, 0 AS ReleaseVersion  

FROM (Select CAST(Lvl1ObjectType AS VARCHAR(100)) AS Lvl1ObjectType,CAST(Lvl1ObjectName AS VARCHAR(100)) AS Lvl1ObjectName,CAST(Lvl2ObjectType AS VARCHAR(100)) AS Lvl2ObjectType,CAST(Lvl2ObjectName AS VARCHAR(100)) AS Lvl2ObjectName From (Select Case sysobjects.type
	When 'U' Then 'Table'
	When 'V' Then 'View'
	When 'TF' Then 'Function'
	When 'FN' Then 'Function'
	When 'P' Then 'Procedure'
	Else sysobjects.type
	End As Lvl1ObjectType 
	, Sysobjects.name As Lvl1ObjectName
	, Null As Lvl2ObjectType
	, Null As Lvl2ObjectName
From Sysobjects 
Where SysObjects.Category & 2 = 0 and Parent_obj = 0)DBAListObjectsLvl1
UNION
Select CAST(Lvl1ObjectType AS VARCHAR(100)) AS Lvl1ObjectType,CAST(Lvl1ObjectName AS VARCHAR(100)) AS Lvl1ObjectName,CAST(Lvl2ObjectType AS VARCHAR(100)) AS Lvl2ObjectType,CAST(Lvl2ObjectName AS VARCHAR(100)) AS Lvl2ObjectName From (Select Case sysobjects.type
	When 'U' Then 'Table'
	When 'V' Then 'View'
	When 'TF' Then 'Function'
	When 'FN' Then 'Function'
	Else sysobjects.type
	End As Lvl1ObjectType 
	, Sysobjects.name As Lvl1ObjectName
	, 'Column' As Lvl2ObjectType
	,SysColumns.name As Lvl2ObjectName
From Sysobjects Inner Join SysColumns On Sysobjects.id = SysColumns.id 
Where SysObjects.Category & 2 = 0 AND SysColumns.name Not like '@%' and SysObjects.Type in ('V','U'))DBAListObjectsColumns
UNION
Select CAST(Lvl1ObjectType AS VARCHAR(100)) AS Lvl1ObjectType,CAST(Lvl1ObjectName AS VARCHAR(100)) AS Lvl1ObjectName,CAST(Lvl2ObjectType AS VARCHAR(100)) AS Lvl2ObjectType,CAST(Lvl2ObjectName AS VARCHAR(100)) AS Lvl2ObjectName From (Select 	 ParentObjects.Lvl1ObjectType
	, ParentObjects.Lvl1ObjectName
	, Case sysobjects.type
	When 'C' Then 'Constraint'
	When 'D' Then 'Constraint'
	When 'F' Then 'Constraint'
	When 'K' Then 'Constraint'
	When 'TR' Then 'Trigger'
	Else sysobjects.type
	End As Lvl2ObjectType 
	, Sysobjects.name As Lvl2ObjectName
From Sysobjects Inner Join (Select Sysobjects.ID
		, Case sysobjects.type
		When 'U' Then 'Table'
		When 'V' Then 'View'
		When 'TF' Then 'Function'
		When 'FN' Then 'Function'
		When 'P' Then 'Procedure'
		Else sysobjects.type
		End As Lvl1ObjectType 
		, Sysobjects.name As Lvl1ObjectName
	From Sysobjects
Where SysObjects.Category & 2 = 0 and Parent_obj = 0)
ParentObjects ON SysObjects.parent_obj = ParentObjects.id
Where SysObjects.Category & 2 = 0 and Parent_obj <> 0)DBAListObjectsLvl2
UNION
Select CAST(Lvl1ObjectType AS VARCHAR(100)) AS Lvl1ObjectType,CAST(Lvl1ObjectName AS VARCHAR(100)) AS Lvl1ObjectName,CAST(Lvl2ObjectType AS VARCHAR(100)) AS Lvl2ObjectType,CAST(Lvl2ObjectName AS VARCHAR(100)) AS Lvl2ObjectName From (Select 	ParentObjects.Lvl1ObjectType
	, ParentObjects.Lvl1ObjectName
	, 'Index' As Lvl2ObjectType 
	, sysindexes.name As Lvl2ObjectName
From sysindexes Inner Join (Select Sysobjects.ID
		, Case sysobjects.type
		When 'U' Then 'Table'
		When 'V' Then 'View'
		When 'TF' Then 'Function'
		When 'FN' Then 'Function'
		When 'P' Then 'Procedure'
		Else sysobjects.type
		End As Lvl1ObjectType 
		, Sysobjects.name As Lvl1ObjectName
	From Sysobjects
Where SysObjects.Category & 2 = 0 and Parent_obj = 0 AND type <> 'TF')
ParentObjects ON sysindexes.id = ParentObjects.id
Where sysindexes.indid not in (0,255) and sysindexes.status&0x1800 = 0 and sysindexes.status not in (10485856,8388704))DBAListObjectsIndexes)DBAListObjectsWithReleaseVersions

OPEN Parent_Cursor
FETCH NEXT FROM Parent_Cursor INTO @Type,@Name,@SubType,@SubName,@Version
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN

	If @Type = @LastType and @Type Not Like ' '
	   Set @Type = '        \___'
	Else
	   BEGIN
	   Set @LastType = @Type
	   Insert @ReturnData
		Select ' ',' ',' ',' ',' '
	   END

	If @Name = @LastName and @Name Not Like ' '
	   BEGIN
	   Set @Name = '     \_________________________________________________'
	   Set @Type = '        |   '
	   END
	Else
	   BEGIN
	   If @SubType Not Like ' '
		Set @Name = RTRIM(@Name) + '  ________________________________________________________'
	   
	   Set @LastName = @Name
	   END

	If @SubType = @LastSubType and @SubType Not Like ' '
	   BEGIN
	   Set @SubType = '        \___'
	   Set @Name = '     |'
	   Set @Type = '        |   '
	   END
	Else
	   Set @LastSubType = @SubType


	If @SubName = @LastSubName and @SubName Not Like ' '
	   BEGIN
	   Set @SubName = ' '
	   Set @SubType = ' '
	   Set @Name = ' '
	   Set @Type = ' '
	   END
	Else
	   Set @LastSubName = @SubName

Insert @ReturnData
	Select @Type,@Name,@SubType,@SubName,@Version

	END
	FETCH NEXT FROM Parent_Cursor INTO @Type,@Name,@SubType,@SubName,@Version
END

CLOSE Parent_Cursor
DEALLOCATE Parent_Cursor

Select RTRIM(Type + Name + SubType + SubName) + Case Version WHEN '3.00' Then ' ' When ' ' Then ' ' When Null Then ' ' Else ' ('+Version+')' End As RowData From @ReturnData Order By RowID


