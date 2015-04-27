

DECLARE		@TSQL		VarChar(max)
SET			@TSQL		=
'SELECT		getdate() AS [CaptureDate]
			,'''+@@SERVERNAME+''' AS [Origin]
			,(SELECT * From DBA_ServerInfo		WHERE SQLName = RunBook.SQLName FOR XML AUTO,TYPE,ROOT(''DBA_ServerInfo''),XMLSCHEMA)
			,(SELECT * From DBA_ClusterInfo		WHERE SQLName = RunBook.SQLName FOR XML AUTO,TYPE,ROOT(''DBA_ClusterInfo''),XMLSCHEMA)
			,(SELECT * From DBA_CommentInfo		WHERE SQLName = RunBook.SQLName FOR XML AUTO,TYPE,ROOT(''DBA_CommentInfo''),XMLSCHEMA)
			,(SELECT * From DBA_DBInfo			WHERE SQLName = RunBook.SQLName FOR XML AUTO,TYPE,ROOT(''DBA_DBInfo''),XMLSCHEMA)
			,(SELECT * From DBA_DeplInfo		WHERE SQLName = RunBook.SQLName FOR XML AUTO,TYPE,ROOT(''DBA_DeplInfo''),XMLSCHEMA)
			,(SELECT * From DBA_DiskInfo		WHERE SQLName = RunBook.SQLName FOR XML AUTO,TYPE,ROOT(''DBA_DiskInfo''),XMLSCHEMA)
			,(SELECT * From DBA_DiskPerfinfo	WHERE SQLName = RunBook.SQLName FOR XML AUTO,TYPE,ROOT(''DBA_DiskPerfinfo''),XMLSCHEMA)
			,(SELECT * From DBA_UserLoginInfo	WHERE SQLName = RunBook.SQLName FOR XML AUTO,TYPE,ROOT(''DBA_UserLoginInfo''),XMLSCHEMA)
FROM		dbo.DBA_ServerInfo RunBook FOR XML AUTO,TYPE,ROOT(''DBA_RunBooks'')'

EXEC (@TSQL)



SET NOCOUNT ON
IF OBJECT_ID('tempdb..#XMLSCHEMA')	IS NOT NULL	DROP TABLE #XMLSCHEMA
IF OBJECT_ID('tempdb..#XMLDATA')	IS NOT NULL	DROP TABLE #XMLDATA


DECLARE			@XML		XML
				,@XML2		XML
				,@TSQL		VarChar(max)
				,@TableName	sysname
			
CREATE TABLE	#XMLSCHEMA
				([TableName]	sysname NULL
				,[ColumnName]	sysname NULL
				,[type]			sysname NULL
				,[base]			sysname NULL
				,[value1]		sysname NULL
				,[value2]		sysname NULL)

CREATE TABLE	#XMLDATA
				([TableName]	sysname NULL
				,[XMLData]		XML NULL)

SET			@XML		=  
'<DBA_RunBooks>
  <RunBook CaptureDate="2011-10-24T20:34:05.323" Origin="SEAFRESQLBOA">
    <DBA_ServerInfo>
      <xsd:schema xmlns:schema="urn:schemas-microsoft-com:sql:SqlRowSet85" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:sqltypes="http://schemas.microsoft.com/sqlserver/2004/sqltypes" targetNamespace="urn:schemas-microsoft-com:sql:SqlRowSet85" elementFormDefault="qualified">
        <xsd:import namespace="http://schemas.microsoft.com/sqlserver/2004/sqltypes" schemaLocation="http://schemas.microsoft.com/sqlserver/2004/sqltypes/sqltypes.xsd" />
        <xsd:element name="DBA_ServerInfo">
          <xsd:complexType>
            <xsd:attribute name="SQLServerID" type="sqltypes:int" use="required" />
            <xsd:attribute name="ServerName" use="required">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="ServerType">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="SQLName" use="required">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="SQLEnv">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="Active" use="required">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="Filescan" use="required">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="SQLmail" use="required">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="modDate" type="sqltypes:datetime" />
            <xsd:attribute name="SQLver">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="500" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="SQLinstallDate" type="sqltypes:datetime" />
            <xsd:attribute name="SQLinstallBy">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="SQLrecycleDate">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="SQLSvcAcct">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="SQLAgentAcct">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="SQLStartupParms">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="SQLScanforStartupSprocs">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="dbaadmin_Version">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="dbaperf_Version">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="DEPLinfo_Version">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="backup_type">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="LiteSpeed">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="RedGate">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="awe_enabled">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="MAXdop_value">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="5" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="Memory">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="SQLmax_memory">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="20" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="tempdb_filecount">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="10" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="FullTextCat">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="Assemblies">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="Mirroring">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="Repl_Flag">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="LogShipping">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="LinkedServers">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="ReportingSvcs">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="LocalPasswords">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="DEPLstatus">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="IndxSnapshot_process">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="IndxSnapshot_inverval">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="CLR_state">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="FrameWork_ver">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="FrameWork_dir">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="PowerShell">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="OracleClient">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="TNSnamesPath">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="DomainName">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="iscluster">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="SAN">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="Port">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="10" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="Location">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="IPnum">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="CPUphysical">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="CPUcore">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="CPUlogical">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="CPUtype">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="OSname">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="OSver">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="OSinstallDate">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="OSuptime">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="MDACver">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="IEver">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="AntiVirus_type">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="AntiVirus_Excludes">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="boot_3gb">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="boot_pae">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="boot_userva">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="Pagefile_maxsize">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="Pagefile_available">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="Pagefile_inuse">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="Pagefile_path">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="TimeZone">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="SystemModel">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="MOMverifyDate" type="sqltypes:datetime" />
          </xsd:complexType>
        </xsd:element>
      </xsd:schema>
      <DBA_ServerInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet85" SQLServerID="1" ServerName="SEAFRESQLBOA" ServerType="SQL Server" SQLName="SEAFRESQLBOA" SQLEnv="production" Active="y" Filescan="Y" SQLmail="Y" modDate="2011-10-23T20:51:33.083" SQLver="Microsoft SQL Server 2005 - 9.00.3042.00 (Intel X86) &#x9;Feb 9 2007 22:47:07 &#x9;Copyright (c) 1988-2005 Microsoft Corporation&#x9;Enterprise Edition on Windows NT 5.2 (Build 3790: Service Pack 2)" SQLinstallDate="2007-03-22T10:40:00.440" SQLrecycleDate="2011-10-21 21:21:14" SQLSvcAcct="SQLAdminProduction" SQLAgentAcct="SQLAdminProduction" SQLStartupParms="-g512;-lE:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\mastlog.ldf;-eE:\Microsoft SQL Server\MSSQL.1\MSSQL\LOG\ERRORLOG;-dE:\Microso" SQLScanforStartupSprocs="n" dbaadmin_Version="20110921" dbaperf_Version="20110922" DEPLinfo_Version="20110915" backup_type="RedGate" LiteSpeed="n" RedGate="y" awe_enabled="y" MAXdop_value="0" Memory="32,767 MB" SQLmax_memory="29184" tempdb_filecount="8" FullTextCat="y" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" LinkedServers="n" ReportingSvcs="n" LocalPasswords="n" DEPLstatus="n" IndxSnapshot_process="n" IndxSnapshot_inverval="na" CLR_state="clr enabled = 0, locked CLR version with mscoree" FrameWork_ver="" FrameWork_dir="" PowerShell="y" OracleClient="na" TNSnamesPath="na" DomainName="AMER" iscluster="y" SAN="y" Port="1433" IPnum="10.196.3.41" CPUphysical="4 physical" CPUcore="8 cores" CPUlogical="16 logical" CPUtype="x86 Family 15 Model 4 Stepping 8 GenuineIntel ~3002 Mhz" OSname="Microsoft(R) Windows(R) Server 2003, Enterprise Edition" OSver="5.2.3790 Service Pack 2 Build 3790" OSinstallDate="2/5/2007, 5:40:41 PM" OSuptime="2011-10-21 19:25:05" MDACver="2.82.3959.0" IEver="6.0.3790.3959" AntiVirus_type="na" AntiVirus_Excludes=" " boot_3gb="n" boot_pae="y" boot_userva="n" Pagefile_maxsize="44,449 MB" Pagefile_available="31,995 MB" Pagefile_inuse="12,454 MB" Pagefile_path="c:\pagefile.sys;d:\pagefile.sys;" TimeZone="(GMT-08:00) Pacific Time (US &amp; Canada)" SystemModel="IBM IBM x3850-[88634RU]-" MOMverifyDate="2011-06-06T10:00:00" />
    </DBA_ServerInfo>
    <DBA_ClusterInfo>
      <xsd:schema xmlns:schema="urn:schemas-microsoft-com:sql:SqlRowSet86" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:sqltypes="http://schemas.microsoft.com/sqlserver/2004/sqltypes" targetNamespace="urn:schemas-microsoft-com:sql:SqlRowSet86" elementFormDefault="qualified">
        <xsd:import namespace="http://schemas.microsoft.com/sqlserver/2004/sqltypes" schemaLocation="http://schemas.microsoft.com/sqlserver/2004/sqltypes/sqltypes.xsd" />
        <xsd:element name="DBA_ClusterInfo">
          <xsd:complexType>
            <xsd:attribute name="SQLName" use="required">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="ClusterName">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="ClusterIP">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="ClusterVer">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="ClusterSvcAcct">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="modDate" type="sqltypes:datetime" />
            <xsd:attribute name="Quorumgroup">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="Quorumgroup_node">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="Quorumgroup_status">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="DTCgroup">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="DTCgroup_node">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="DTCgroup_status">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="VirtSrv01">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="VirtSrv01_node">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="VirtSrv01_status">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="VirtSrv02">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="VirtSrv02_node">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="VirtSrv02_status">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="VirtSrv03">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="VirtSrv03_node">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="VirtSrv03_status">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="VirtSrv04">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="VirtSrv04_node">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="VirtSrv04_status">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="VirtSrv05">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="VirtSrv05_node">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="VirtSrv05_status">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="clustNode01">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="clustNode01_IP">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="clustNode01_status">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="clustNode02">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="clustNode02_IP">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="clustNode02_status">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="clustNode03">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="clustNode03_IP">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="clustNode03_status">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="clustNode04">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="clustNode04_IP">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="clustNode04_status">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="clustNode05">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="clustNode05_IP">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="clustNode05_status">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
          </xsd:complexType>
        </xsd:element>
      </xsd:schema>
      <DBA_ClusterInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet86" SQLName="SEAFRESQLBOA" ClusterName="SEAFRESQLBO" ClusterIP="10.196.3.40" ClusterVer="5.2 (Build 3790: Service Pack 2)" ClusterSvcAcct="amer.gettywan.com\seafresqlboclusvc" modDate="2011-10-23T20:51:42.880" Quorumgroup="Cluster Group" Quorumgroup_node="SEAFRESQLBO01" Quorumgroup_status="Online" DTCgroup="Cluster Group" DTCgroup_node="SEAFRESQLBO01" DTCgroup_status="Online" VirtSrv01="PBX-ClusterGroup-SEAFRESQLBO01 SEAFRESQLBO01" VirtSrv01_node="Online" VirtSrv01_status="" VirtSrv02="PBX-ClusterGroup-seafresqlbo02 SEAFRESQLBO02" VirtSrv02_node="Online" VirtSrv02_status="" VirtSrv03="SEAFRESQLBOA" VirtSrv03_node="SEAFRESQLBO01" VirtSrv03_status="Online" VirtSrv04="" VirtSrv04_node="" VirtSrv04_status="" VirtSrv05="" VirtSrv05_node="" VirtSrv05_status="" clustNode01="SEAFRESQLBO01" clustNode01_IP="10.196.6.140" clustNode01_status="Up" clustNode02="SEAFRESQLBO02" clustNode02_IP="10.196.6.141" clustNode02_status="Up" clustNode03="" clustNode03_IP="" clustNode03_status="" clustNode04="" clustNode04_IP="" clustNode04_status="" clustNode05="" clustNode05_IP="" clustNode05_status="" />
    </DBA_ClusterInfo>
    <DBA_CommentInfo>
      <xsd:schema xmlns:schema="urn:schemas-microsoft-com:sql:SqlRowSet87" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:sqltypes="http://schemas.microsoft.com/sqlserver/2004/sqltypes" targetNamespace="urn:schemas-microsoft-com:sql:SqlRowSet87" elementFormDefault="qualified">
        <xsd:import namespace="http://schemas.microsoft.com/sqlserver/2004/sqltypes" schemaLocation="http://schemas.microsoft.com/sqlserver/2004/sqltypes/sqltypes.xsd" />
        <xsd:element name="DBA_CommentInfo">
          <xsd:complexType>
            <xsd:attribute name="SQLName" use="required">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="CommentNum" type="sqltypes:int" use="required" />
            <xsd:attribute name="CommentTitle">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="CommentText">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:ntext" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52" />
              </xsd:simpleType>
            </xsd:attribute>
          </xsd:complexType>
        </xsd:element>
      </xsd:schema>
    </DBA_CommentInfo>
    <DBA_DBInfo>
      <xsd:schema xmlns:schema="urn:schemas-microsoft-com:sql:SqlRowSet88" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:sqltypes="http://schemas.microsoft.com/sqlserver/2004/sqltypes" targetNamespace="urn:schemas-microsoft-com:sql:SqlRowSet88" elementFormDefault="qualified">
        <xsd:import namespace="http://schemas.microsoft.com/sqlserver/2004/sqltypes" schemaLocation="http://schemas.microsoft.com/sqlserver/2004/sqltypes/sqltypes.xsd" />
        <xsd:element name="DBA_DBInfo">
          <xsd:complexType>
            <xsd:attribute name="SQLName" use="required">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="DBName" use="required">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="status">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="CreateDate" type="sqltypes:datetime" />
            <xsd:attribute name="ENVname">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="ENVnum">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="Appl_desc">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="BaselineFolder">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="BaselineServername">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="BaselineDate">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="build">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="data_size_MB">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="18" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="log_size_MB">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="18" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="row_count" type="sqltypes:bigint" />
            <xsd:attribute name="RecovModel">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="FullTextCat">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="Trustworthy">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="Assemblies">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="Mirroring">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="Repl_Flag">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="LogShipping">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="ReportingSvcs">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="StartupSprocs">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="modDate" type="sqltypes:datetime" />
            <xsd:attribute name="DBCompat">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="10" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="DEPLstatus">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
          </xsd:complexType>
        </xsd:element>
      </xsd:schema>
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="anthillpro3" status="ONLINE" CreateDate="2009-11-17T11:09:40.003" ENVname="production" ENVnum="production" Appl_desc="" BaselineFolder="" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="302.00" log_size_MB="57.00" row_count="11297" RecovModel="FULL" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-04T20:51:02.220" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="Cert" status="ONLINE" CreateDate="2008-11-04T20:24:22.010" ENVname="production" ENVnum="production" Appl_desc="SSL Tool Manager" BaselineFolder="CERT" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="2.50" log_size_MB="1.00" row_count="7163" RecovModel="FULL" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:07.320" DBCompat="80" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="dbaadmin" status="ONLINE" CreateDate="2011-01-11T13:27:05.943" ENVname="production" ENVnum="production" Appl_desc="" BaselineFolder="" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="20110921" data_size_MB="18.00" log_size_MB="83.00" row_count="32847" RecovModel="SIMPLE" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:07.443" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="dbaperf" status="ONLINE" CreateDate="2010-03-16T20:50:04.567" ENVname="production" ENVnum="production" Appl_desc="" BaselineFolder="" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="20110922" data_size_MB="10789.00" log_size_MB="47.00" row_count="9169841" RecovModel="SIMPLE" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:07.570" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="DEPLinfo" status="ONLINE" CreateDate="2009-03-12T20:50:28.010" ENVname="production" ENVnum="production" Appl_desc="" BaselineFolder="" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="20110915" data_size_MB="6.00" log_size_MB="1.00" row_count="6241" RecovModel="SIMPLE" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:07.693" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="EcoraAuditorDB41" status="ONLINE" CreateDate="2008-11-04T20:23:48.603" ENVname="production" ENVnum="production" Appl_desc="" BaselineFolder="" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="1475.44" log_size_MB="0.49" row_count="9455871" RecovModel="FULL" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:08.430" DBCompat="80" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="EcoraAuditorDB45" status="ONLINE" CreateDate="2008-11-04T20:23:11.180" ENVname="production" ENVnum="production" Appl_desc="" BaselineFolder="" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="1500.00" log_size_MB="0.49" row_count="2327975" RecovModel="SIMPLE" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:08.723" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="EDS" status="ONLINE" CreateDate="2008-11-04T20:30:35.230" ENVname="production" ENVnum="production" Appl_desc="" BaselineFolder="" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="17.94" log_size_MB="3.38" row_count="113793" RecovModel="FULL" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:08.850" DBCompat="80" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="Enlighten" status="ONLINE" CreateDate="2008-11-04T20:29:40.410" ENVname="production" ENVnum="production" Appl_desc="" BaselineFolder="" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="11.19" log_size_MB="1.00" row_count="121728" RecovModel="FULL" FullTextCat="y" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:08.990" DBCompat="80" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="EnlightenASP" status="ONLINE" CreateDate="2008-11-04T20:26:22.870" ENVname="production" ENVnum="production" Appl_desc="" BaselineFolder="" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="2.38" log_size_MB="0.49" row_count="4916" RecovModel="FULL" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:09.117" DBCompat="80" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="gBudget" status="ONLINE" CreateDate="2008-11-04T20:27:47.243" ENVname="production" ENVnum="production" Appl_desc="" BaselineFolder="" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="14.63" log_size_MB="1.00" row_count="45282" RecovModel="FULL" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:09.240" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="GettyImagesICM" status="ONLINE" CreateDate="2011-06-16T15:06:00.210" ENVname="production" ENVnum="production" Appl_desc="Varicent" BaselineFolder="ICM" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="4867.19" log_size_MB="1228.81" row_count="7477965" RecovModel="FULL" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:10.020" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="GIOTS" status="ONLINE" CreateDate="2008-11-04T20:27:59.713" ENVname="production" ENVnum="production" Appl_desc="" BaselineFolder="" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="8.25" log_size_MB="1.00" row_count="6906" RecovModel="SIMPLE" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:10.147" DBCompat="80" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="HDBB" status="ONLINE" CreateDate="2008-11-04T20:24:56.290" ENVname="production" ENVnum="production" Appl_desc="" BaselineFolder="" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="3.00" log_size_MB="1.00" row_count="8428" RecovModel="FULL" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:10.270" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="IncidentReports" status="ONLINE" CreateDate="2008-11-04T20:28:57.967" ENVname="production" ENVnum="production" Appl_desc="" BaselineFolder="" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="1024.00" log_size_MB="128.00" row_count="38703" RecovModel="FULL" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:10.397" DBCompat="80" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="PerfAnalysis" status="ONLINE" CreateDate="2008-11-04T20:26:11.713" ENVname="production" ENVnum="production" Appl_desc="" BaselineFolder="" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="2.19" log_size_MB="0.49" row_count="4488" RecovModel="SIMPLE" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:10.507" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="ReportServer" status="ONLINE" CreateDate="2008-11-04T20:17:04.557" ENVname="production" ENVnum="production" Appl_desc="" BaselineFolder="" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="82.19" log_size_MB="0.49" row_count="12850" RecovModel="FULL" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="y" StartupSprocs="n" modDate="2011-10-04T20:51:07.220" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="ReportServerTempDB" status="ONLINE" CreateDate="2008-11-04T20:17:57.870" ENVname="production" ENVnum="production" Appl_desc="" BaselineFolder="" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="5.19" log_size_MB="0.49" row_count="3613" RecovModel="FULL" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="y" StartupSprocs="n" modDate="2011-10-04T20:51:07.347" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="sqlnexus" status="OFFLINE" CreateDate="2008-11-04T20:26:00.057" ENVname="production" ENVnum="production" Appl_desc="" BaselineFolder="" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="0.00" log_size_MB="0.00" row_count="4488" RecovModel="SIMPLE" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:10.537" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="STS_Config_TFS" status="ONLINE" CreateDate="2008-11-04T20:18:47.387" ENVname="production" ENVnum="production" Appl_desc="" BaselineFolder="" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="3.19" log_size_MB="0.49" row_count="4442" RecovModel="FULL" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-04T20:51:07.597" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="STS_Content_TFS" status="ONLINE" CreateDate="2008-11-04T20:19:36.807" ENVname="production" ENVnum="production" Appl_desc="" BaselineFolder="" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="210.19" log_size_MB="0.49" row_count="52000" RecovModel="FULL" FullTextCat="y" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-04T20:51:07.720" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="SystemInfo" status="OFFLINE" CreateDate="2008-11-04T20:08:07.657" ENVname="production" ENVnum="production" Appl_desc="" BaselineFolder="" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="0.00" log_size_MB="0.00" row_count="4488" RecovModel="SIMPLE" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:10.553" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="TfsActivityLogging" status="ONLINE" CreateDate="2008-11-04T20:13:15.470" ENVname="production" ENVnum="production" Appl_desc="TFS" BaselineFolder="TFS" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="160.81" log_size_MB="0.49" row_count="3330" RecovModel="FULL" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-04T20:51:07.987" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="TfsBuild" status="ONLINE" CreateDate="2008-11-04T20:14:19.043" ENVname="production" ENVnum="production" Appl_desc="TFS" BaselineFolder="TFS" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="650.63" log_size_MB="0.49" row_count="5062635" RecovModel="FULL" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-04T20:51:08.110" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="TfsIntegration" status="ONLINE" CreateDate="2008-11-04T20:12:19.483" ENVname="production" ENVnum="production" Appl_desc="TFS" BaselineFolder="TFS" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="63.69" log_size_MB="2.75" row_count="10103" RecovModel="FULL" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-04T20:51:08.250" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="TfsVersionControl" status="ONLINE" CreateDate="2008-11-04T20:01:11.547" ENVname="production" ENVnum="production" Appl_desc="TFS" BaselineFolder="TFS" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="133295.00" log_size_MB="0.49" row_count="1927991706" RecovModel="FULL" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-04T20:51:08.377" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="TfsWarehouse" status="ONLINE" CreateDate="2008-11-04T20:22:26.760" ENVname="production" ENVnum="production" Appl_desc="TFS" BaselineFolder="TFS" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="2808.94" log_size_MB="0.49" row_count="7560326" RecovModel="FULL" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-04T20:51:08.517" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="TfsWorkItemTracking" status="ONLINE" CreateDate="2008-11-04T20:09:39.297" ENVname="production" ENVnum="production" Appl_desc="TFS" BaselineFolder="TFS" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="750.94" log_size_MB="1.00" row_count="1067516" RecovModel="FULL" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-04T20:51:08.673" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="TfsWorkItemTrackingAttachments" status="ONLINE" CreateDate="2008-11-04T20:11:25.313" ENVname="production" ENVnum="production" Appl_desc="TFS" BaselineFolder="TFS" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="1452.25" log_size_MB="0.49" row_count="9218" RecovModel="FULL" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-04T20:51:08.797" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="GettyImagesICM_old" status="ONLINE" CreateDate="2011-06-16T14:54:38.380" ENVname="production" ENVnum="production" Appl_desc="" BaselineFolder="" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="45920.19" log_size_MB="77.50" row_count="69103723" RecovModel="FULL" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-17T20:51:13.643" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="anthillpro3_Retired_20111005" status="OFFLINE" CreateDate="2011-10-05T10:27:45.240" ENVname="production" ENVnum="production" Appl_desc="" BaselineFolder="" BaselineServername="SEAPSQLDBA01" data_size_MB="0.00" log_size_MB="0.00" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:07.193" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="ReportServer_Retired_20111005" status="OFFLINE" CreateDate="2011-10-05T14:12:53.437" ENVname="production" ENVnum="production" Appl_desc="" BaselineFolder="" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="0.00" log_size_MB="0.00" row_count="4488" RecovModel="SIMPLE" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:10.520" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="ReportServerTempDB_Retired_20111005" status="OFFLINE" CreateDate="2011-10-05T13:43:32.103" ENVname="production" ENVnum="production" Appl_desc="" BaselineFolder="" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="0.00" log_size_MB="0.00" row_count="4488" RecovModel="SIMPLE" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:10.520" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="STS_Config_TFS_Retired_20111005" status="OFFLINE" CreateDate="2011-10-05T10:34:29.770" ENVname="production" ENVnum="production" Appl_desc="" BaselineFolder="" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="0.00" log_size_MB="0.00" row_count="4488" RecovModel="SIMPLE" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:10.537" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="STS_Content_TFS_Retired_20111005" status="OFFLINE" CreateDate="2011-10-05T10:34:33.240" ENVname="production" ENVnum="production" Appl_desc="" BaselineFolder="" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="0.00" log_size_MB="0.00" row_count="4488" RecovModel="SIMPLE" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:10.553" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="TfsActivityLogging_Retired_20111005" status="OFFLINE" CreateDate="2011-10-05T10:27:53.507" ENVname="production" ENVnum="production" Appl_desc="TFS" BaselineFolder="TFS" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="0.00" log_size_MB="0.00" row_count="4488" RecovModel="SIMPLE" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:10.570" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="TfsBuild_Retired_20111005" status="OFFLINE" CreateDate="2011-10-05T10:27:59.523" ENVname="production" ENVnum="production" Appl_desc="TFS" BaselineFolder="TFS" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="0.00" log_size_MB="0.00" row_count="4488" RecovModel="SIMPLE" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:10.570" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="TfsIntegration_Retired_20111005" status="OFFLINE" CreateDate="2011-10-05T10:28:05.053" ENVname="production" ENVnum="production" Appl_desc="TFS" BaselineFolder="TFS" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="0.00" log_size_MB="0.00" row_count="4488" RecovModel="SIMPLE" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:10.617" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="TfsVersionControl_Retired_20111005" status="OFFLINE" CreateDate="2011-10-05T10:28:10.773" ENVname="production" ENVnum="production" Appl_desc="TFS" BaselineFolder="TFS" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="0.00" log_size_MB="0.00" row_count="4488" RecovModel="SIMPLE" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:10.647" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="TfsWarehouse_Retired_20111005" status="OFFLINE" CreateDate="2011-10-05T10:28:17.460" ENVname="production" ENVnum="production" Appl_desc="TFS" BaselineFolder="TFS" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="0.00" log_size_MB="0.00" row_count="4488" RecovModel="SIMPLE" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:10.693" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="TfsWorkItemTracking_Retired_20111005" status="OFFLINE" CreateDate="2011-10-05T10:28:23.647" ENVname="production" ENVnum="production" Appl_desc="TFS" BaselineFolder="TFS" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="0.00" log_size_MB="0.00" row_count="4488" RecovModel="SIMPLE" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:10.723" DBCompat="90" DEPLstatus="n" />
      <DBA_DBInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet88" SQLName="SEAFRESQLBOA" DBName="TfsWorkItemTrackingAttachments_Retired_20111005" status="OFFLINE" CreateDate="2011-10-05T10:28:31.223" ENVname="production" ENVnum="production" Appl_desc="TFS" BaselineFolder="TFS" BaselineServername="SEAPSQLDBA01" BaselineDate="" build="" data_size_MB="0.00" log_size_MB="0.00" row_count="4488" RecovModel="SIMPLE" FullTextCat="n" Trustworthy="n" Assemblies="n" Mirroring="n" Repl_Flag="n" LogShipping="n" ReportingSvcs="n" StartupSprocs="n" modDate="2011-10-23T20:51:10.723" DBCompat="90" DEPLstatus="n" />
    </DBA_DBInfo>
    <DBA_DeplInfo>
      <xsd:schema xmlns:schema="urn:schemas-microsoft-com:sql:SqlRowSet89" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:sqltypes="http://schemas.microsoft.com/sqlserver/2004/sqltypes" targetNamespace="urn:schemas-microsoft-com:sql:SqlRowSet89" elementFormDefault="qualified">
        <xsd:import namespace="http://schemas.microsoft.com/sqlserver/2004/sqltypes" schemaLocation="http://schemas.microsoft.com/sqlserver/2004/sqltypes/sqltypes.xsd" />
        <xsd:element name="DBA_DeplInfo">
          <xsd:complexType>
            <xsd:attribute name="DeplInfoId" type="sqltypes:bigint" use="required" />
            <xsd:attribute name="Domain">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:varchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="50" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="Enviro_Type">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:varchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="50" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="ServerName">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:varchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="50" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="SQLName">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:varchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="50" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="DBName">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:varchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="50" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="Build_Number">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:varchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="50" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="Build_Date">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:varchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="20" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="Baseline_Date">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:varchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="20" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="Record_Date">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:varchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="20" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
          </xsd:complexType>
        </xsd:element>
      </xsd:schema>
    </DBA_DeplInfo>
    <DBA_DiskInfo>
      <xsd:schema xmlns:schema="urn:schemas-microsoft-com:sql:SqlRowSet90" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:sqltypes="http://schemas.microsoft.com/sqlserver/2004/sqltypes" targetNamespace="urn:schemas-microsoft-com:sql:SqlRowSet90" elementFormDefault="qualified">
        <xsd:import namespace="http://schemas.microsoft.com/sqlserver/2004/sqltypes" schemaLocation="http://schemas.microsoft.com/sqlserver/2004/sqltypes/sqltypes.xsd" />
        <xsd:element name="DBA_DiskInfo">
          <xsd:complexType>
            <xsd:attribute name="SQLName" use="required">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="Active" use="required">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="DriveName" use="required">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="DriveSize" type="sqltypes:int" />
            <xsd:attribute name="DriveFree" type="sqltypes:int" />
            <xsd:attribute name="DriveFree_pct" type="sqltypes:int" />
            <xsd:attribute name="GrowthPerWeekMB" type="sqltypes:int" />
            <xsd:attribute name="DriveFullWks" type="sqltypes:int" />
            <xsd:attribute name="modDate" type="sqltypes:datetime" />
          </xsd:complexType>
        </xsd:element>
      </xsd:schema>
      <DBA_DiskInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet90" SQLName="SEAFRESQLBOA" Active="y" DriveName="C" DriveSize="20002" DriveFree="7030" DriveFree_pct="35" GrowthPerWeekMB="109" DriveFullWks="64" modDate="2011-10-23T20:51:33.117" />
      <DBA_DiskInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet90" SQLName="SEAFRESQLBOA" Active="y" DriveName="D" DriveSize="49881" DriveFree="36562" DriveFree_pct="73" GrowthPerWeekMB="1188" DriveFullWks="30" modDate="2011-10-23T20:51:33.130" />
      <DBA_DiskInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet90" SQLName="SEAFRESQLBOA" Active="y" DriveName="E" DriveSize="376624" DriveFree="347510" DriveFree_pct="92" GrowthPerWeekMB="0" DriveFullWks="1000" modDate="2011-10-23T20:51:33.130" />
      <DBA_DiskInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet90" SQLName="SEAFRESQLBOA" Active="y" DriveName="F" DriveSize="171191" DriveFree="169521" DriveFree_pct="99" GrowthPerWeekMB="0" DriveFullWks="1000" modDate="2011-10-23T20:51:33.147" />
      <DBA_DiskInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet90" SQLName="SEAFRESQLBOA" Active="y" DriveName="G" DriveSize="171191" DriveFree="117579" DriveFree_pct="68" GrowthPerWeekMB="4026" DriveFullWks="29" modDate="2011-10-23T20:51:33.147" />
      <DBA_DiskInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet90" SQLName="SEAFRESQLBOA" Active="y" DriveName="Q" DriveSize="1018" DriveFree="1006" DriveFree_pct="98" GrowthPerWeekMB="0" DriveFullWks="1000" modDate="2011-10-23T20:51:33.163" />
      <DBA_DiskInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet90" SQLName="SEAFRESQLBOA" Active="y" DriveName="T" DriveSize="20480" DriveFree="4415" DriveFree_pct="21" GrowthPerWeekMB="0" DriveFullWks="1000" modDate="2011-10-23T20:51:33.163" />
      <DBA_DiskInfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet90" SQLName="SEAFRESQLBOA" Active="y" DriveName="M" DriveSize="68471" DriveFree="68404" DriveFree_pct="99" GrowthPerWeekMB="0" DriveFullWks="1000" modDate="2011-10-23T20:51:33.147" />
    </DBA_DiskInfo>
    <DBA_DiskPerfinfo>
      <xsd:schema xmlns:schema="urn:schemas-microsoft-com:sql:SqlRowSet91" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:sqltypes="http://schemas.microsoft.com/sqlserver/2004/sqltypes" targetNamespace="urn:schemas-microsoft-com:sql:SqlRowSet91" elementFormDefault="qualified">
        <xsd:import namespace="http://schemas.microsoft.com/sqlserver/2004/sqltypes" schemaLocation="http://schemas.microsoft.com/sqlserver/2004/sqltypes/sqltypes.xsd" />
        <xsd:element name="DBA_DiskPerfinfo">
          <xsd:complexType>
            <xsd:attribute name="SQLname" use="required">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="MasterPath">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="500" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="Master_Push_BytesSec" type="sqltypes:bigint" />
            <xsd:attribute name="Master_Pull_BytesSec" type="sqltypes:bigint" />
            <xsd:attribute name="MDFPath">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="500" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="MDF_Push_BytesSec" type="sqltypes:bigint" />
            <xsd:attribute name="MDF_Pull_BytesSec" type="sqltypes:bigint" />
            <xsd:attribute name="LDFPath">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="500" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="LDF_Push_BytesSec" type="sqltypes:bigint" />
            <xsd:attribute name="LDF_Pull_BytesSec" type="sqltypes:bigint" />
            <xsd:attribute name="TempdbPath">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="500" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="Tempdb_Push_BytesSec" type="sqltypes:bigint" />
            <xsd:attribute name="Tempdb_Pull_BytesSec" type="sqltypes:bigint" />
            <xsd:attribute name="CreateDate" type="sqltypes:datetime" use="required" />
          </xsd:complexType>
        </xsd:element>
      </xsd:schema>
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="21103300" Master_Pull_BytesSec="198142318" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="241337344" MDF_Pull_BytesSec="175645810" LDFPath="F:\log" LDF_Push_BytesSec="241337344" LDF_Pull_BytesSec="241337344" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="266376759" Tempdb_Pull_BytesSec="220600862" CreateDate="2011-09-10T20:52:36.877" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="16293366" Master_Pull_BytesSec="171648182" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="249315438" MDF_Pull_BytesSec="321783125" LDFPath="F:\log" LDF_Push_BytesSec="241337344" LDF_Pull_BytesSec="297213477" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="175645810" Tempdb_Pull_BytesSec="214712939" CreateDate="2011-09-16T20:52:55.897" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="32050112" Master_Pull_BytesSec="227247969" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="167828472" MDF_Pull_BytesSec="321783125" LDFPath="F:\log" LDF_Push_BytesSec="335190755" LDF_Pull_BytesSec="285944720" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="336124434" Tempdb_Pull_BytesSec="336124434" CreateDate="2011-10-07T20:52:49.383" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="321783125" Master_Pull_BytesSec="157736826" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="336124434" MDF_Pull_BytesSec="241337344" LDFPath="F:\log" LDF_Push_BytesSec="203145912" LDF_Pull_BytesSec="257289279" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="249315438" Tempdb_Pull_BytesSec="336124434" CreateDate="2011-10-08T20:52:09.303" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="75701801" Master_Pull_BytesSec="249315438" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="175645810" MDF_Pull_BytesSec="214712939" LDFPath="F:\log" LDF_Push_BytesSec="171648182" LDF_Pull_BytesSec="285944720" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="321783125" Tempdb_Pull_BytesSec="350781023" CreateDate="2011-10-20T16:58:29.083" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="208769328" Master_Pull_BytesSec="234308100" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="386758564" MDF_Pull_BytesSec="234308100" LDFPath="F:\log" LDF_Push_BytesSec="249315438" LDF_Pull_BytesSec="309406851" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="309406851" Tempdb_Pull_BytesSec="308615529" CreateDate="2011-10-20T20:52:21.633" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="80445781" Master_Pull_BytesSec="249315438" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="220600862" MDF_Pull_BytesSec="297213477" LDFPath="F:\log" LDF_Push_BytesSec="336124434" LDF_Pull_BytesSec="321783125" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="321783125" Tempdb_Pull_BytesSec="297213477" CreateDate="2011-10-21T20:52:40.913" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="72867555" Master_Pull_BytesSec="297213477" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="208769328" MDF_Pull_BytesSec="309406851" LDFPath="F:\log" LDF_Push_BytesSec="183946146" LDF_Pull_BytesSec="309406851" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="179566476" Tempdb_Pull_BytesSec="276129684" CreateDate="2011-10-22T20:52:27.037" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="130877084" Master_Pull_BytesSec="297213477" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="309406851" MDF_Pull_BytesSec="220600862" LDFPath="F:\log" LDF_Push_BytesSec="220600862" LDF_Pull_BytesSec="241337344" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="309406851" Tempdb_Pull_BytesSec="367892292" CreateDate="2011-09-03T20:52:40.090" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="151403603" Master_Pull_BytesSec="285944720" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="160891562" MDF_Pull_BytesSec="275499251" LDFPath="F:\log" LDF_Push_BytesSec="350781023" LDF_Pull_BytesSec="367892292" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="321783125" Tempdb_Pull_BytesSec="285944720" CreateDate="2011-09-11T20:52:46.500" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="21513402" Master_Pull_BytesSec="276129684" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="157530903" MDF_Pull_BytesSec="350781023" LDFPath="F:\log" LDF_Push_BytesSec="220600862" LDF_Pull_BytesSec="208769328" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="321783125" Tempdb_Pull_BytesSec="336124434" CreateDate="2011-09-17T20:52:47.360" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="198142318" Master_Pull_BytesSec="297213477" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="151403603" MDF_Pull_BytesSec="309406851" LDFPath="F:\log" LDF_Push_BytesSec="321783125" LDF_Pull_BytesSec="309406851" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="179566476" Tempdb_Pull_BytesSec="198142318" CreateDate="2011-09-20T20:52:04.657" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="214712939" Master_Pull_BytesSec="309406851" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="145735111" MDF_Pull_BytesSec="309406851" LDFPath="F:\log" LDF_Push_BytesSec="188544800" LDF_Pull_BytesSec="321783125" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="214712939" Tempdb_Pull_BytesSec="309406851" CreateDate="2011-09-29T20:51:54.227" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="56387229" Master_Pull_BytesSec="214712939" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="321783125" MDF_Pull_BytesSec="249315438" LDFPath="F:\log" LDF_Push_BytesSec="151403603" LDF_Pull_BytesSec="321783125" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="266376759" Tempdb_Pull_BytesSec="321783125" CreateDate="2011-10-11T20:52:12.200" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="367892292" Master_Pull_BytesSec="227247969" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="115251835" MDF_Pull_BytesSec="309406851" LDFPath="F:\log" LDF_Push_BytesSec="321783125" LDF_Pull_BytesSec="351803708" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="220600862" Tempdb_Pull_BytesSec="276129684" CreateDate="2011-10-13T20:52:34.410" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="175645810" Master_Pull_BytesSec="297213477" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="276129684" MDF_Pull_BytesSec="198142318" LDFPath="F:\log" LDF_Push_BytesSec="171648182" LDF_Pull_BytesSec="214712939" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="321783125" Tempdb_Pull_BytesSec="309406851" CreateDate="2011-09-24T20:52:06.150" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="188250658" Master_Pull_BytesSec="297213477" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="321783125" MDF_Pull_BytesSec="110401346" LDFPath="F:\log" LDF_Push_BytesSec="257289279" LDF_Pull_BytesSec="309406851" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="321783125" Tempdb_Pull_BytesSec="308615529" CreateDate="2011-09-27T20:52:29.800" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="188544800" Master_Pull_BytesSec="183946146" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="154505341" MDF_Pull_BytesSec="321783125" LDFPath="F:\log" LDF_Push_BytesSec="351803708" LDF_Pull_BytesSec="285944720" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="179566476" Tempdb_Pull_BytesSec="198142318" CreateDate="2011-10-01T20:52:12.307" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="309406851" Master_Pull_BytesSec="101658527" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="164398735" MDF_Pull_BytesSec="321783125" LDFPath="F:\log" LDF_Push_BytesSec="171648182" LDF_Pull_BytesSec="188544800" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="321783125" Tempdb_Pull_BytesSec="203488485" CreateDate="2011-10-06T20:52:48.740" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="175390511" Master_Pull_BytesSec="309406851" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="214712939" MDF_Pull_BytesSec="285944720" LDFPath="F:\log" LDF_Push_BytesSec="234308100" LDF_Pull_BytesSec="234308100" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="386758564" Tempdb_Pull_BytesSec="198142318" CreateDate="2011-09-09T20:53:15.110" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="20219281" Master_Pull_BytesSec="266376759" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="198142318" MDF_Pull_BytesSec="285944720" LDFPath="F:\log" LDF_Push_BytesSec="179566476" LDF_Pull_BytesSec="179566476" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="285944720" Tempdb_Pull_BytesSec="321783125" CreateDate="2011-09-18T20:51:57.250" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="351803708" Master_Pull_BytesSec="104384664" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="120668672" MDF_Pull_BytesSec="309406851" LDFPath="F:\log" LDF_Push_BytesSec="321783125" LDF_Pull_BytesSec="234308100" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="208769328" Tempdb_Pull_BytesSec="285944720" CreateDate="2011-09-19T20:52:14.807" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="164398735" Master_Pull_BytesSec="285944720" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="203488485" MDF_Pull_BytesSec="297213477" LDFPath="F:\log" LDF_Push_BytesSec="175645810" LDF_Pull_BytesSec="297213477" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="214712939" Tempdb_Pull_BytesSec="227247969" CreateDate="2011-08-26T20:52:16.800" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="321783125" Master_Pull_BytesSec="110401346" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="87759034" MDF_Pull_BytesSec="220600862" LDFPath="F:\log" LDF_Push_BytesSec="214712939" LDF_Pull_BytesSec="309406851" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="321783125" Tempdb_Pull_BytesSec="309406851" CreateDate="2011-08-27T20:52:28.150" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="22648024" Master_Pull_BytesSec="285944720" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="135582777" MDF_Pull_BytesSec="285944720" LDFPath="F:\log" LDF_Push_BytesSec="336124434" LDF_Pull_BytesSec="193069875" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="241337344" Tempdb_Pull_BytesSec="321783125" CreateDate="2011-08-28T20:52:43.530" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="336124434" Master_Pull_BytesSec="198142318" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="94198807" MDF_Pull_BytesSec="285944720" LDFPath="F:\log" LDF_Push_BytesSec="285944720" LDF_Pull_BytesSec="321783125" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="188544800" Tempdb_Pull_BytesSec="164175063" CreateDate="2011-08-31T20:51:44.530" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="179566476" Master_Pull_BytesSec="336124434" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="203488485" MDF_Pull_BytesSec="309406851" LDFPath="F:\log" LDF_Push_BytesSec="193069875" LDF_Pull_BytesSec="188544800" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="276129684" Tempdb_Pull_BytesSec="220600862" CreateDate="2011-09-01T20:52:38.710" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="135582777" Master_Pull_BytesSec="309406851" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="386758564" MDF_Pull_BytesSec="285944720" LDFPath="F:\log" LDF_Push_BytesSec="249315438" LDF_Pull_BytesSec="321783125" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="297213477" Tempdb_Pull_BytesSec="266376759" CreateDate="2011-09-04T20:52:34.453" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="227247969" Master_Pull_BytesSec="183946146" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="160891562" MDF_Pull_BytesSec="297213477" LDFPath="F:\log" LDF_Push_BytesSec="309406851" LDF_Pull_BytesSec="351803708" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="188544800" Tempdb_Pull_BytesSec="175645810" CreateDate="2011-09-06T20:52:04.847" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="175645810" Master_Pull_BytesSec="214712939" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="145735111" MDF_Pull_BytesSec="321783125" LDFPath="F:\log" LDF_Push_BytesSec="160891562" LDF_Pull_BytesSec="297213477" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="297213477" Tempdb_Pull_BytesSec="321783125" CreateDate="2011-09-05T20:52:27.380" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="351803708" Master_Pull_BytesSec="115251835" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="198142318" MDF_Pull_BytesSec="285944720" LDFPath="F:\log" LDF_Push_BytesSec="145735111" LDF_Pull_BytesSec="285944720" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="336124434" Tempdb_Pull_BytesSec="309406851" CreateDate="2011-09-12T20:51:58.007" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="336124434" Master_Pull_BytesSec="84858419" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="108808541" MDF_Pull_BytesSec="164398735" LDFPath="F:\log" LDF_Push_BytesSec="214712939" LDF_Pull_BytesSec="227247969" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="297213477" Tempdb_Pull_BytesSec="309406851" CreateDate="2011-09-14T20:53:17.253" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="386758564" Master_Pull_BytesSec="179566476" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="167828472" MDF_Pull_BytesSec="309406851" LDFPath="F:\log" LDF_Push_BytesSec="227247969" LDF_Pull_BytesSec="321783125" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="208769328" Tempdb_Pull_BytesSec="257839042" CreateDate="2011-09-21T20:53:03.107" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="234308100" Master_Pull_BytesSec="297213477" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="214712939" MDF_Pull_BytesSec="309406851" LDFPath="F:\log" LDF_Push_BytesSec="386758564" LDF_Pull_BytesSec="336124434" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="154307764" Tempdb_Pull_BytesSec="285944720" CreateDate="2011-09-15T20:52:29.680" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="309406851" Master_Pull_BytesSec="193069875" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="145735111" MDF_Pull_BytesSec="321783125" LDFPath="F:\log" LDF_Push_BytesSec="198142318" LDF_Pull_BytesSec="249315438" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="208769328" Tempdb_Pull_BytesSec="297213477" CreateDate="2011-09-23T20:52:13.063" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="276129684" Master_Pull_BytesSec="164398735" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="241337344" MDF_Pull_BytesSec="297213477" LDFPath="F:\log" LDF_Push_BytesSec="336124434" LDF_Pull_BytesSec="257839042" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="321783125" Tempdb_Pull_BytesSec="198142318" CreateDate="2011-10-03T20:52:50.710" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="309406851" Master_Pull_BytesSec="309406851" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="198142318" MDF_Pull_BytesSec="321783125" LDFPath="F:\log" LDF_Push_BytesSec="336124434" LDF_Pull_BytesSec="321783125" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="321783125" Tempdb_Pull_BytesSec="309406851" CreateDate="2011-10-04T20:52:20.127" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="105849712" Master_Pull_BytesSec="143141959" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="276129684" MDF_Pull_BytesSec="227247969" LDFPath="F:\log" LDF_Push_BytesSec="276129684" LDF_Pull_BytesSec="297213477" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="220600862" Tempdb_Pull_BytesSec="257839042" CreateDate="2011-10-14T20:52:04.333" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="367892292" Master_Pull_BytesSec="122630764" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="126619802" MDF_Pull_BytesSec="164398735" LDFPath="F:\log" LDF_Push_BytesSec="321783125" LDF_Pull_BytesSec="220600862" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="198142318" Tempdb_Pull_BytesSec="309406851" CreateDate="2011-10-15T20:52:28.543" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="124657719" Master_Pull_BytesSec="154505341" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="234308100" MDF_Pull_BytesSec="276129684" LDFPath="F:\log" LDF_Push_BytesSec="227247969" LDF_Pull_BytesSec="309406851" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="321783125" Tempdb_Pull_BytesSec="220600862" CreateDate="2011-10-16T20:52:09.077" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="208769328" Master_Pull_BytesSec="249315438" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="309406851" MDF_Pull_BytesSec="145735111" LDFPath="F:\log" LDF_Push_BytesSec="234308100" LDF_Pull_BytesSec="241337344" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="276129684" Tempdb_Pull_BytesSec="386758564" CreateDate="2011-10-17T20:52:26.003" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="179566476" Master_Pull_BytesSec="321783125" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="148606738" MDF_Pull_BytesSec="257289279" LDFPath="F:\log" LDF_Push_BytesSec="227247969" LDF_Pull_BytesSec="241337344" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="208769328" Tempdb_Pull_BytesSec="249315438" CreateDate="2011-10-18T20:51:49.100" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="367892292" Master_Pull_BytesSec="234308100" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="117040419" MDF_Pull_BytesSec="297213477" LDFPath="F:\log" LDF_Push_BytesSec="208769328" LDF_Pull_BytesSec="257289279" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="220600862" Tempdb_Pull_BytesSec="309406851" CreateDate="2011-09-07T20:51:54.373" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="234308100" Master_Pull_BytesSec="321783125" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="193069875" MDF_Pull_BytesSec="285944720" LDFPath="F:\log" LDF_Push_BytesSec="214712939" LDF_Pull_BytesSec="241337344" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="183946146" Tempdb_Pull_BytesSec="227247969" CreateDate="2011-08-29T20:52:23.080" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="183946146" Master_Pull_BytesSec="297213477" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="321783125" MDF_Pull_BytesSec="227247969" LDFPath="F:\log" LDF_Push_BytesSec="249315438" LDF_Pull_BytesSec="351803708" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="321783125" Tempdb_Pull_BytesSec="257839042" CreateDate="2011-09-22T20:52:05.870" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="367892292" Master_Pull_BytesSec="175390511" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="126619802" MDF_Pull_BytesSec="309406851" LDFPath="F:\log" LDF_Push_BytesSec="297213477" LDF_Pull_BytesSec="266376759" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="321783125" Tempdb_Pull_BytesSec="309406851" CreateDate="2011-09-25T20:52:15.717" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="266376759" Master_Pull_BytesSec="171648182" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="126619802" MDF_Pull_BytesSec="309406851" LDFPath="F:\log" LDF_Push_BytesSec="266376759" LDF_Pull_BytesSec="203488485" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="183946146" Tempdb_Pull_BytesSec="227247969" CreateDate="2011-10-05T20:52:46.813" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="386758564" Master_Pull_BytesSec="160891562" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="336124434" MDF_Pull_BytesSec="105849712" LDFPath="F:\log" LDF_Push_BytesSec="336124434" LDF_Pull_BytesSec="297213477" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="335190755" Tempdb_Pull_BytesSec="309406851" CreateDate="2011-10-10T20:51:57.063" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="297213477" Master_Pull_BytesSec="142972360" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="143141959" MDF_Pull_BytesSec="160891562" LDFPath="F:\log" LDF_Push_BytesSec="214331566" LDF_Pull_BytesSec="309406851" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="160891562" Tempdb_Pull_BytesSec="203145912" CreateDate="2011-09-26T20:52:30.207" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="351803708" Master_Pull_BytesSec="80445781" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="321783125" MDF_Pull_BytesSec="297213477" LDFPath="F:\log" LDF_Push_BytesSec="321783125" LDF_Pull_BytesSec="309406851" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="297213477" Tempdb_Pull_BytesSec="297213477" CreateDate="2011-08-25T20:52:22.877" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="241337344" Master_Pull_BytesSec="308615529" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="179566476" MDF_Pull_BytesSec="297213477" LDFPath="F:\log" LDF_Push_BytesSec="321783125" LDF_Pull_BytesSec="183946146" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="183946146" Tempdb_Pull_BytesSec="227247969" CreateDate="2011-09-28T20:52:13.633" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="26631796" Master_Pull_BytesSec="241337344" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="234308100" MDF_Pull_BytesSec="171648182" LDFPath="F:\log" LDF_Push_BytesSec="351803708" LDF_Pull_BytesSec="227247969" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="321783125" Tempdb_Pull_BytesSec="336124434" CreateDate="2011-10-02T20:52:12.837" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="102959617" Master_Pull_BytesSec="175645810" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="309406851" MDF_Pull_BytesSec="154505341" LDFPath="F:\log" LDF_Push_BytesSec="297213477" LDF_Pull_BytesSec="168062217" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="160891562" Tempdb_Pull_BytesSec="160891562" CreateDate="2011-09-08T20:52:20.537" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="183946146" Master_Pull_BytesSec="308615529" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="321783125" MDF_Pull_BytesSec="154505341" LDFPath="F:\log" LDF_Push_BytesSec="179566476" LDF_Pull_BytesSec="208769328" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="227247969" Tempdb_Pull_BytesSec="321783125" CreateDate="2011-10-09T20:52:41.460" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="111937543" Master_Pull_BytesSec="183946146" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="168062217" MDF_Pull_BytesSec="297213477" LDFPath="F:\log" LDF_Push_BytesSec="220600862" LDF_Pull_BytesSec="321783125" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="193069875" Tempdb_Pull_BytesSec="227247969" CreateDate="2011-10-12T20:52:21.807" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="85824091" Master_Pull_BytesSec="297213477" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="367892292" MDF_Pull_BytesSec="249315438" LDFPath="F:\log" LDF_Push_BytesSec="276129684" LDF_Pull_BytesSec="297213477" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="276129684" Tempdb_Pull_BytesSec="309406851" CreateDate="2011-10-23T20:52:22.037" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="203488485" Master_Pull_BytesSec="86811994" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="321783125" MDF_Pull_BytesSec="198142318" LDFPath="F:\log" LDF_Push_BytesSec="297213477" LDF_Pull_BytesSec="321783125" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="198142318" Tempdb_Pull_BytesSec="309406851" CreateDate="2011-08-24T20:52:41.733" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="351803708" Master_Pull_BytesSec="151403603" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="110401346" MDF_Pull_BytesSec="321783125" LDFPath="F:\log" LDF_Push_BytesSec="203488485" LDF_Pull_BytesSec="203488485" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="135582777" Tempdb_Pull_BytesSec="297213477" CreateDate="2011-08-30T20:52:34.090" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="336124434" Master_Pull_BytesSec="257839042" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="135582777" MDF_Pull_BytesSec="249315438" LDFPath="F:\log" LDF_Push_BytesSec="309406851" LDF_Pull_BytesSec="309406851" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="266376759" Tempdb_Pull_BytesSec="309406851" CreateDate="2011-09-02T20:51:48.557" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="208769328" Master_Pull_BytesSec="276129684" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="157736826" MDF_Pull_BytesSec="285944720" LDFPath="F:\log" LDF_Push_BytesSec="309406851" LDF_Pull_BytesSec="297213477" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="309406851" Tempdb_Pull_BytesSec="367892292" CreateDate="2011-09-13T20:52:24.580" />
      <DBA_DiskPerfinfo xmlns="urn:schemas-microsoft-com:sql:SqlRowSet91" SQLname="SEAFRESQLBOA" MasterPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\DATA" Master_Push_BytesSec="208769328" Master_Pull_BytesSec="309406851" MDFPath="E:\Microsoft SQL Server\MSSQL.1\MSSQL\Data" MDF_Push_BytesSec="336124434" MDF_Pull_BytesSec="193069875" LDFPath="F:\log" LDF_Push_BytesSec="241337344" LDF_Pull_BytesSec="309406851" TempdbPath="T:\mssql.1\data" Tempdb_Push_BytesSec="321783125" Tempdb_Pull_BytesSec="309406851" CreateDate="2011-09-30T20:52:48.677" />
    </DBA_DiskPerfinfo>
    <DBA_UserLoginInfo>
      <xsd:schema xmlns:schema="urn:schemas-microsoft-com:sql:SqlRowSet92" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:sqltypes="http://schemas.microsoft.com/sqlserver/2004/sqltypes" targetNamespace="urn:schemas-microsoft-com:sql:SqlRowSet92" elementFormDefault="qualified">
        <xsd:import namespace="http://schemas.microsoft.com/sqlserver/2004/sqltypes" schemaLocation="http://schemas.microsoft.com/sqlserver/2004/sqltypes/sqltypes.xsd" />
        <xsd:element name="DBA_UserLoginInfo">
          <xsd:complexType>
            <xsd:attribute name="SQLName" use="required">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="Active" use="required">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="ULname">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="ULtype">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="ULsubname">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="DBname">
              <xsd:simpleType sqltypes:sqlTypeAlias="[dbaadmin].[sys].[sysname]">
                <xsd:restriction base="sqltypes:nvarchar" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="128" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="SYSadmin">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="DBOflag">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="DirectGrants">
              <xsd:simpleType>
                <xsd:restriction base="sqltypes:char" sqltypes:localeId="1033" sqltypes:sqlCompareOptions="IgnoreCase IgnoreKanaType IgnoreWidth" sqltypes:sqlSortId="52">
                  <xsd:maxLength value="1" />
                </xsd:restriction>
              </xsd:simpleType>
            </xsd:attribute>
            <xsd:attribute name="SQL_createDate" type="sqltypes:datetime" />
            <xsd:attribute name="modDate" type="sqltypes:datetime" />
          </xsd:complexType>
        </xsd:element>
      </xsd:schema>
    </DBA_UserLoginInfo>
  </RunBook>
</DBA_RunBooks>'


--SELECT		@XML2 = x.query('.') 
--FROM		@XML.nodes('*/*[2]') a(x)

-- RETURNS EACH CHILD TABLE
SELECT		x.value('*[1]/@Origin','sysname') [Origin]
			,x.value('*[1]/@CaptureDate','datetime') [CaptureDate]
FROM		@XML.nodes('*') a(x)

-- RETURNS EACH SERVER AND ITS CHILD TABLES
SELECT		x.query('.') [Data]
FROM		@XML.nodes('*/*') a(x)
IF @@ROWCOUNT > 1 
	PRINT 'XML Contains Multiple RunBook Sets'


-- RETURNS EACH CHILD TABLE
INSERT INTO	#XMLDATA
SELECT		x.value('*[1]/*[2]/@name','sysname') [TableName]
			,x.query('.') [Data]
FROM		@XML.nodes('*/*[1]/*') a(x)

----------------------------------------
--	CURSOR THROUGH EACH TABLE IN SET
----------------------------------------

DECLARE TableCursor CURSOR
FOR
-- RETURNS EACH CHILD TABLE
SELECT		[TableName]
			,[XMLData]
FROM		#XMLDATA

OPEN TableCursor
FETCH NEXT FROM TableCursor INTO @TableName,@XML2
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		SELECT @TableName,@XML2
		RAISERROR(@TableName,-1,-1) WITH NOWAIT

		--DELETE #XMLSCHEMA WHERE TableName = @TableName
		------------------------------------------------------------------------
		------------------------------------------------------------------------
		--	POPULATE THE XMLSCHEMA TEMP TABLE
		------------------------------------------------------------------------
		------------------------------------------------------------------------
		INSERT INTO	#XMLSCHEMA
		SELECT		@TableName [TableName]
					,a.x.value('@name','sysname') [ColumnName]
					,REPLACE(a.x.value('@type','sysname'),'sqltypes:','') [type]
					,REPLACE(a.x.value('*[1]/*[1]/@base','sysname'),'sqltypes:','') [base]
					,a.x.value('*[1]/*[1]/*[1]/@value','sysname') [value1]
					,a.x.value('*[1]/*[1]/*[2]/@value','sysname') [value2]
		FROM		@XML2.nodes('/*[1]/*[1]/*[2]/*[1]/*') a(x)

		------------------------------------------------------------------------
		------------------------------------------------------------------------
		--	CREATE THE DYNAMIC SQL TO CREATE THE SOURCE TEMP TABLE FROM THE XSD
		------------------------------------------------------------------------
		------------------------------------------------------------------------
		SET			@TSQL		= 'DECLARE @XML2 XML; SELECT @XML2 = [XMLData] FROM #XMLDATA WHERE [TableName] = '''+@TableName+''';'
								+ CHAR(13)+CHAR(10)
								+ 'SELECT	@XML2 = (SELECT CAST(STUFF(CAST(@XML2.query(''*[1]/*'') AS VarChar(max)),1,CHARINDEX(''</xsd:schema>'',CAST(@XML2.query(''*[1]/*'') AS VarChar(max)))+12,'''') AS XML) FOR XML RAW ('''+@TableName+'''))'
								+ CHAR(13)+CHAR(10)
								+ 'SELECT		'
		SELECT		@TSQL		= @TSQL
								+ 'a.x.value(''@'+[ColumnName]+''','''
								+ REPLACE(COALESCE([type],[base]+'('+[value1]+COALESCE(','+nullif([value2],'')+')',')')),'sqltypes:','')+''') ' + QUOTENAME([ColumnName])
								+ CHAR(13) + CHAR(10) + '			,' 
		FROM		#XMLSCHEMA ColumnData
		WHERE		[TableName] = @TableName
					
		SET			@TSQL		= REPLACE(@TSQL+'||','			,||','INTO	##Source'+CHAR(13) + CHAR(10)+'FROM		@XML2.nodes(''*/*'') a(x)')

		PRINT @TSQL
		PRINT ''


		------------------------------------------------------------------------
		------------------------------------------------------------------------
		--	CREATE THE SOURCE TEMP TABLE FROM THE XSD
		------------------------------------------------------------------------
		------------------------------------------------------------------------
		IF OBJECT_ID('tempdb..##Source')	IS NOT NULL	DROP TABLE ##Source
		
		EXEC	(@TSQL)
		
		IF @@ROWCOUNT > 0
			SELECT * FROM ##Source







	END
	FETCH NEXT FROM TableCursor INTO @TableName,@XML2
END
CLOSE TableCursor
DEALLOCATE TableCursor



