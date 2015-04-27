

SELECT *

FROM        sys.assembly_modules am
		INNER JOIN  sys.assemblies asmbly
			ON  asmbly.assembly_id = am.assembly_id


select * FRom  sys.assemblies


select * From sys.assemblies
select * From sys.assembly_files
select * From sys.assembly_references


SELECT		 ASSEMBLYPROPERTY('System.Management', 'CultureInfo')		CultureInfo
		,ASSEMBLYPROPERTY('System.Management', 'PublicKey')		PublicKey
		,ASSEMBLYPROPERTY('System.Management', 'MvID')			MvID
		,ASSEMBLYPROPERTY('System.Management', 'VersionMajor')		VersionMajor
		,ASSEMBLYPROPERTY('System.Management', 'VersionMinor')		VersionMinor
		,ASSEMBLYPROPERTY('System.Management', 'VersionBuild')		VersionBuild
		,ASSEMBLYPROPERTY('System.Management', 'VersionRevision')	VersionRevision
		,ASSEMBLYPROPERTY('System.Management', 'SimpleName')		SimpleName
		,ASSEMBLYPROPERTY('System.Management', 'Architecture')		Architecture
		,ASSEMBLYPROPERTY('System.Management', 'CLRName')		CLRName



SELECT		ASSEMBLYPROPERTY('System.Management', 'MvID')			MvID
		,dbaadmin.dbo.dbaudf_GetFileProperty('C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\System.Management.dll','File','MVID')

C:\windows\assembly\GAC_MSIL\System.Management\2.0.0.0__b03f5f7f11d50a3a\System.Management.dll


DECLARE		@AssemblyName		VarChar(8000)
DECLARE		@AlterCommand		VarChar(8000)
DECLARE		@MSG			VarChar(8000)
DECLARE		AssemblyCursor		CURSOR
FOR
-- SELECT QUERY FOR CURSOR
SELECT		'ALTER ASSEMBLY [' + T3.name + '] FROM '''+ T2.Name + ''''
		,T3.Name
FROM		dbaadmin.dbo.dbaudf_DirectoryList2('C:\WINDOWS\Microsoft.NET\Framework\',null,1) T1
JOIN		sys.assembly_files T2
	ON	T1.Name = dbaadmin.dbo.dbaudf_GetFileFromPath(T2.name)
JOIN		sys.assemblies T3
	ON	T2.assembly_id = T3.assembly_id 

OPEN AssemblyCursor;
FETCH AssemblyCursor INTO @AlterCommand,@AssemblyName;
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		---------------------------- 
		---------------------------- CURSOR LOOP TOP
	
		BEGIN TRY
			exec(@AlterCommand)
			SET @MSG = 'Sucessfully Updated Assembly %s'
			RAISERROR (@MSG,-1,-1,@AssemblyName) WITH NOWAIT
		END TRY
		BEGIN CATCH
	
			SET @MSG = CASE ERROR_NUMBER()
				    WHEN 6285 THEN 'No update necessary (MVID match) for %s'
				    WHEN 6501 THEN 'Physical assembly not found at specified location (SQL Error 6501) %s'
				    ELSE ERROR_MESSAGE() + ' (SQL Error ' + convert(varchar(10), ERROR_NUMBER()) + ')  %s'
				    END
			RAISERROR (@MSG,-1,-1,@AssemblyName) WITH NOWAIT
		END CATCH

		---------------------------- CURSOR LOOP BOTTOM
		----------------------------
	END
 	FETCH NEXT FROM AssemblyCursor INTO @AlterCommand,@AssemblyName;
END
CLOSE AssemblyCursor;
DEALLOCATE AssemblyCursor;





ALTER ASSEMBLY [Accessibility] FROM 'C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\accessibility.dll'
ALTER ASSEMBLY [Microsoft.JScript] FROM 'C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\microsoft.jscript.dll'
ALTER ASSEMBLY [Microsoft.Vsa] FROM 'C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\microsoft.vsa.dll'
ALTER ASSEMBLY [System.Configuration.Install] FROM 'C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\system.configuration.install.dll'
ALTER ASSEMBLY [System.Drawing] FROM 'C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\system.drawing.dll'
ALTER ASSEMBLY [System.Management] FROM 'C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\System.Management.dll'
ALTER ASSEMBLY [System.Runtime.Serialization.Formatters.Soap] FROM 'C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\system.runtime.serialization.formatters.soap.dll'
ALTER ASSEMBLY [System.Windows.Forms] FROM 'C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\system.windows.forms.dll'