select		*
                ,dbaadmin.dbo.dbaudf_GetFileProperty(FullPathName,'File','InternalName')	[InternalName]
                ,dbaadmin.dbo.dbaudf_GetFileProperty(FullPathName,'File','Comments')		[Comments]
                ,dbaadmin.dbo.dbaudf_GetFileProperty(FullPathName,'File','CompanyName')		[CompanyName]
                ,dbaadmin.dbo.dbaudf_GetFileProperty(FullPathName,'File','FileMajorPart')	[FileMajorPart]
                ,dbaadmin.dbo.dbaudf_GetFileProperty(FullPathName,'File','FileMinorPart')	[FileMinorPart]
                ,dbaadmin.dbo.dbaudf_GetFileProperty(FullPathName,'File','FileBuildPart')	[FileBuildPart]
                ,dbaadmin.dbo.dbaudf_GetFileProperty(FullPathName,'File','FilePrivatePart')	[FilePrivatePart]
                ,dbaadmin.dbo.dbaudf_GetFileProperty(FullPathName,'File','FileDescription')	[FileDescription]
                ,dbaadmin.dbo.dbaudf_GetFileProperty(FullPathName,'File','FileVersion')		[FileVersion]
                ,dbaadmin.dbo.dbaudf_GetFileProperty(FullPathName,'File','IsDebug')		[IsDebug]
                ,dbaadmin.dbo.dbaudf_GetFileProperty(FullPathName,'File','IsPatched')		[IsPatched]
                ,dbaadmin.dbo.dbaudf_GetFileProperty(FullPathName,'File','OriginalFilename')	[OriginalFilename]
                ,dbaadmin.dbo.dbaudf_GetFileProperty(FullPathName,'File','LegalCopyright')	[LegalCopyright]
                ,dbaadmin.dbo.dbaudf_GetFileProperty(FullPathName,'File','LegalTrademarks')	[LegalTrademarks]
                ,dbaadmin.dbo.dbaudf_GetFileProperty(FullPathName,'File','ProductMajorPart')	[ProductMajorPart]
                ,dbaadmin.dbo.dbaudf_GetFileProperty(FullPathName,'File','ProductMinorPart')	[ProductMinorPart]
                ,dbaadmin.dbo.dbaudf_GetFileProperty(FullPathName,'File','ProductBuildPart')	[ProductBuildPart]
                ,dbaadmin.dbo.dbaudf_GetFileProperty(FullPathName,'File','ProductPrivatePart')	[ProductPrivatePart]
                ,dbaadmin.dbo.dbaudf_GetFileProperty(FullPathName,'File','ProductName')		[ProductName]
                ,dbaadmin.dbo.dbaudf_GetFileProperty(FullPathName,'File','ProductVersion')	[ProductVersion]
                ,dbaadmin.dbo.dbaudf_GetFileProperty(FullPathName,'File','PrivateBuild')	[PrivateBuild]
                ,dbaadmin.dbo.dbaudf_GetFileProperty(FullPathName,'File','SpecialBuild')	[SpecialBuild]
                ,dbaadmin.dbo.dbaudf_GetFileProperty(FullPathName,'File','Language')		[Language]
                ,dbaadmin.dbo.dbaudf_GetFileProperty(FullPathName,'File','IsSpecialBuild')	[IsSpecialBuild]
                ,dbaadmin.dbo.dbaudf_GetFileProperty(FullPathName,'File','IsPrivateBuild')	[IsPrivateBuild]
                ,dbaadmin.dbo.dbaudf_GetFileProperty(FullPathName,'File','IsPreRelease')	[IsPreRelease]

SELECT		'ALTER ASSEMBLY [' + T3.name + '] FROM '''+ T2.Name
FROM		dbaadmin.dbo.dbaudf_DirectoryList2('C:\WINDOWS\Microsoft.NET\Framework\',null,1) T1
JOIN		sys.assembly_files T2
	ON	T1.Name = dbaadmin.dbo.dbaudf_GetFileFromPath(T2.name)
JOIN		sys.assemblies T3
	ON	T2.assembly_id = T3.assembly_id


FROM		dbaadmin.dbo.dbaudf_DirectoryList2('C:\windows\assembly',null,1)
WHERE		Name like 'System.Management.dll'

SELECT    dbaadmin.dbo.dbaudf_GetFileProperty('C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\System.Management.dll','File','FileVersion')



exec('ALTER ASSEMBLY [System.Management] FROM ''C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\System.Management.dll''')



select sa.name as AssemblyName,
        saf.name as Assemblylocation,
        case when charindex('', saf.name) = 0
            then 'ALTER ASSEMBLY [' + sa.name + '] FROM ''' --+ @DotNetFolder
            else 'ALTER ASSEMBLY [' + sa.name + '] FROM '''
        end + saf.name + (case right(saf.name, 4) when '.dll' then '' else '.dll' end) + ''''
        as AlterAssemblyCommand
from sys.assemblies sa
join sys.assembly_files saf
  on sa.assembly_id = saf.assembly_id
where sa.name <> ('Microsoft.SqlServer.Types')
  --and (sa.name like 'System.%' or sa.name like 'microsoft.%'