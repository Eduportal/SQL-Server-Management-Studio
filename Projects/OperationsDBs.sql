'
'Steve Ledridge 10/12/2010
'*************************************************************************

isOnRadar	= 0
isPerf		= 0
isDeployable	= 0
isGears		= 0
isDeplControl	= 0
isDeployMaster	= 0
isCentral	= 0
isErrorOrWarning = "WARNING"

SCRIPT_SQL = _
        "SET NOCOUNT ON; " & _
        "" & _
        "DECLARE	@DBName	sysname" & _
        "SET	@DBName	= 'dbaadmin'" & _
        "" & _
        "SELECT	DBName" & _
        "	,MAX(DBID)	AS DBID" & _
        "	,MAX(CRDate)	AS CRDate" & _
        "FROM	(" & _
        "	SELECT	'dbaadmin'	AS DBName" & _
        "		,0		AS DBID" & _
        "		,1/1/1900	AS CRDate" & _
        "	UNION ALL" & _
        "	SELECT	'dbaPerf'	AS DBName" & _
        "		,0		AS DBID" & _
        "		,1/1/1900	AS CRDate" & _
        "	UNION ALL" & _
        "	SELECT	'deplinfo'	AS DBName" & _
        "		,0		AS DBID" & _
        "		,1/1/1900	AS CRDate" & _
        "	UNION ALL" & _
        "	SELECT	'deplcontrol'	AS DBName" & _
        "		,0		AS DBID" & _
        "		,1/1/1900	AS CRDate" & _
        "	UNION ALL" & _
        "	SELECT	'dbacentral'	AS DBName" & _
        "		,0		AS DBID" & _
        "		,1/1/1900	AS CRDate" & _
        "	UNION ALL" & _
        "	SELECT	'DeployMaster'	AS DBName" & _
        "		,0		AS DBID" & _
        "		,1/1/1900	AS CRDate" & _
        "	UNION ALL" & _
        "	SELECT	'gears'		AS DBName" & _
        "		,0		AS DBID" & _
        "		,1/1/1900	AS CRDate" & _
        "	UNION ALL" & _
        "	SELECT	name" & _
        "		,dbid" & _
        "		,crdate" & _ 
        "	FROM	SYSDATABASES" & _ 
        "	) Data" & _
        "Group By DBName;"

        
BUILD_SQL = _
        "SET NOCOUNT ON; " & _
        "" & _
        "SELECT	TOP 1 " & _
	"	[iBuildID] " & _
	"	,[vchName] " & _
	"	,[vchLabel] " & _
	"	,[dtBuildDate] " & _
	"	,[vchNotes] " & _
	"FROM	[dbaadmin].[dbo].[Build] " & _
	"ORDER BY [dtBuildDate] DESC; "  
	    
'************************** CREATE ADO OBJECTS **********************************************************
Set cnManagedOPDBInstance = CreateObject("ADODB.Connection")
cnManagedOPDBInstance.Provider = "sqloledb"
cnManagedOPDBInstance.ConnectionTimeout = 30

Set cnManagedInstance = CreateObject("ADODB.Connection")
cnManagedInstance.Provider = "sqloledb"
cnManagedInstance.ConnectionTimeout = 30
sConnString = "Server=" & sManagedInstance & ";Database=master;Trusted_Connection=yes"

cnManagedInstance.Open sConnString
Set rsDBInfo = cnManagedInstance.Execute(SCRIPT_SQL)

'********************************************************************************************************

sAlertDescription = vBCrLf & vBCrLf & "Server\Instance: " & sManagedInstance & vBCrLf & vBCrLf
sAlertDescription = sAlertDescription & "OPERATIONS DATABASE HEALTH" & vBCrLf
sAlertDescription = sAlertDescription & "----------------" & vBCrLf

bWriteLOG = False 'write to Evt Log

Do While Not rsDBInfo.EOF
        

    '********************************************************************************************************
    '**************************        DBAADMIN       **********************************************************
    '********************************************************************************************************
    If rsDBInfo("DBName").Value = "dbaadmin" Then 'CHECK DBAADMIN DATABASE

	If rsDBInfo("DBID").Value = 0 Then 'DATABASE Does Not Exist
	
	        sAlertDescription = sAlertDescription & vBCrLf & "OPERATIONS DATABASE MISSING: " & rsDBInfo("DBName").Value & vBCrLf
	        bWriteLOG = True
	        isErrorOrWarning = "ERROR"
	Else
		isOnRadar = 1
	
		'************************** CREATE ADO OBJECTS **********************************************************
		sConnString = "Server=" & sManagedInstance & ";Database=" & rsDBInfo("DBName").Value & ";Trusted_Connection=yes"
		cnManagedOPDBInstance.Open sConnString
		Set rsOPDBInfo = cnManagedOPDBInstance.Execute(BUILD_SQL)
		'********************************************************************************************************
	
		If Not rsOPDBInfo.EOF Then
			OpDbBuildVersion	= rsOPDBInfo("vchLabel").Value
			OpDbBuildDate		= rsOPDBInfo("dtBuildDate").Value
		Else
			sAlertDescription = sAlertDescription & vBCrLf & "OPERATIONS DATABASE MISSING BUILD TABLE: " & rsDBInfo("DBName").Value & vBCrLf
			bWriteLOG = True		
		End If
	
	End If
        

    '********************************************************************************************************
    '**************************        DBACENTRAL       **********************************************************
    '********************************************************************************************************
    Else If rsDBInfo("DBName").Value = "dbacentral" Then 'CHECK DBACENTRAL DATABASE
    
	If rsDBInfo("DBID").Value = 0 Then 'DATABASE Does Not Exist
	
	        sAlertDescription = sAlertDescription & vBCrLf & "OPERATIONS DATABASE MISSING: " & rsDBInfo("DBName").Value & vBCrLf
	        bWriteLOG = True
	Else
		isCentral = 1
	
		'************************** CREATE ADO OBJECTS **********************************************************
		sConnString = "Server=" & sManagedInstance & ";Database=" & rsDBInfo("DBName").Value & ";Trusted_Connection=yes"
		cnManagedOPDBInstance.Open sConnString
		Set rsOPDBInfo = cnManagedOPDBInstance.Execute(BUILD_SQL)
		'********************************************************************************************************
	
		If Not rsOPDBInfo.EOF Then
			OpDbBuildVersion	= rsOPDBInfo("vchLabel").Value
			OpDbBuildDate		= rsOPDBInfo("dtBuildDate").Value
		Else
			sAlertDescription = sAlertDescription & vBCrLf & "OPERATIONS DATABASE MISSING BUILD TABLE: " & rsDBInfo("DBName").Value & vBCrLf
			bWriteLOG = True
		End If
	
	End If
        

    '********************************************************************************************************
    '**************************        DBAPERF       **********************************************************
    '********************************************************************************************************
    Else If rsDBInfo("DBName").Value = "dbaperf" Then 'CHECK DBAPERF DATABASE

	If rsDBInfo("DBID").Value = 0 Then 'DATABASE Does Not Exist
	
	        sAlertDescription = sAlertDescription & vBCrLf & "OPERATIONS DATABASE MISSING: " & rsDBInfo("DBName").Value & vBCrLf
	        bWriteLOG = True
	        isErrorOrWarning = "ERROR"
	Else
		isPerf = 1
	
		'************************** CREATE ADO OBJECTS **********************************************************
		sConnString = "Server=" & sManagedInstance & ";Database=" & rsDBInfo("DBName").Value & ";Trusted_Connection=yes"
		cnManagedOPDBInstance.Open sConnString
		Set rsOPDBInfo = cnManagedOPDBInstance.Execute(BUILD_SQL)
		'********************************************************************************************************
	
		If Not rsOPDBInfo.EOF Then
			OpDbBuildVersion	= rsOPDBInfo("vchLabel").Value
			OpDbBuildDate		= rsOPDBInfo("dtBuildDate").Value
		Else
			sAlertDescription = sAlertDescription & vBCrLf & "OPERATIONS DATABASE MISSING BUILD TABLE: " & rsDBInfo("DBName").Value & vBCrLf
			bWriteLOG = True
		End If
	
	End If
        

    '********************************************************************************************************
    '**************************       DEPLCONTROL      **********************************************************
    '********************************************************************************************************
    Else If rsDBInfo("DBName").Value = "deplcontrol" Then 'CHECK DEPLCONTROL DATABASE

	If rsDBInfo("DBID").Value = 0 Then 'DATABASE Does Not Exist
	
	        sAlertDescription = sAlertDescription & vBCrLf & "OPERATIONS DATABASE MISSING: " & rsDBInfo("DBName").Value & vBCrLf
	        bWriteLOG = True
	Else
		isDeplControl = 1
	
		'************************** CREATE ADO OBJECTS **********************************************************
		sConnString = "Server=" & sManagedInstance & ";Database=" & rsDBInfo("DBName").Value & ";Trusted_Connection=yes"
		cnManagedOPDBInstance.Open sConnString
		Set rsOPDBInfo = cnManagedOPDBInstance.Execute(BUILD_SQL)
		'********************************************************************************************************
	
		If Not rsOPDBInfo.EOF Then
			OpDbBuildVersion	= rsOPDBInfo("vchLabel").Value
			OpDbBuildDate		= rsOPDBInfo("dtBuildDate").Value
		Else
			sAlertDescription = sAlertDescription & vBCrLf & "OPERATIONS DATABASE MISSING BUILD TABLE: " & rsDBInfo("DBName").Value & vBCrLf
			bWriteLOG = True
		End If
	
	End If
        

    '********************************************************************************************************
    '**************************        DEPLINFO       **********************************************************
    '********************************************************************************************************
    Else If rsDBInfo("DBName").Value = "deplinfo" Then 'CHECK DEPLINFO DATABASE

	If rsDBInfo("DBID").Value = 0 Then 'DATABASE Does Not Exist
	
	        sAlertDescription = sAlertDescription & vBCrLf & "OPERATIONS DATABASE MISSING: " & rsDBInfo("DBName").Value & vBCrLf
	        bWriteLOG = True
	        isErrorOrWarning = "ERROR"
	Else
		isDeployable = 1
	
		'************************** CREATE ADO OBJECTS **********************************************************
		sConnString = "Server=" & sManagedInstance & ";Database=" & rsDBInfo("DBName").Value & ";Trusted_Connection=yes"
		cnManagedOPDBInstance.Open sConnString
		Set rsOPDBInfo = cnManagedOPDBInstance.Execute(BUILD_SQL)
		'********************************************************************************************************
	
		If Not rsOPDBInfo.EOF Then
			OpDbBuildVersion	= rsOPDBInfo("vchLabel").Value
			OpDbBuildDate		= rsOPDBInfo("dtBuildDate").Value
		Else
			sAlertDescription = sAlertDescription & vBCrLf & "OPERATIONS DATABASE MISSING BUILD TABLE: " & rsDBInfo("DBName").Value & vBCrLf
			bWriteLOG = True
		End If
	
	End If
        

    '********************************************************************************************************
    '***********************        DEPLOYMASTER       *******************************************************
    '********************************************************************************************************
    Else If rsDBInfo("DBName").Value = "deploymaster" Then 'CHECK DEPLOYMASTER DATABASE

	If rsDBInfo("DBID").Value = 0 Then 'DATABASE Does Not Exist
	
	        sAlertDescription = sAlertDescription & vBCrLf & "OPERATIONS DATABASE MISSING: " & rsDBInfo("DBName").Value & vBCrLf
	        bWriteLOG = True
	Else
		isDeployMaster = 1
	
		'************************** CREATE ADO OBJECTS **********************************************************
		sConnString = "Server=" & sManagedInstance & ";Database=" & rsDBInfo("DBName").Value & ";Trusted_Connection=yes"
		cnManagedOPDBInstance.Open sConnString
		Set rsOPDBInfo = cnManagedOPDBInstance.Execute(BUILD_SQL)
		'********************************************************************************************************
	
		If Not rsOPDBInfo.EOF Then
			OpDbBuildVersion	= rsOPDBInfo("vchLabel").Value
			OpDbBuildDate		= rsOPDBInfo("dtBuildDate").Value
		Else
			sAlertDescription = sAlertDescription & vBCrLf & "OPERATIONS DATABASE MISSING BUILD TABLE: " & rsDBInfo("DBName").Value & vBCrLf
			bWriteLOG = True
		End If
	
	End If
        

    '********************************************************************************************************
    '**************************        GEARS       **********************************************************
    '********************************************************************************************************
    Else If rsDBInfo("DBName").Value = "gears" Then 'CHECK GEARS DATABASE
    
	If rsDBInfo("DBID").Value = 0 Then 'DATABASE Does Not Exist
	
	        sAlertDescription = sAlertDescription & vBCrLf & "OPERATIONS DATABASE MISSING: " & rsDBInfo("DBName").Value & vBCrLf
	        bWriteLOG = True
	Else
		isGears = 1
	
		'************************** CREATE ADO OBJECTS **********************************************************
		sConnString = "Server=" & sManagedInstance & ";Database=" & rsDBInfo("DBName").Value & ";Trusted_Connection=yes"
		cnManagedOPDBInstance.Open sConnString
		Set rsOPDBInfo = cnManagedOPDBInstance.Execute(BUILD_SQL)
		'********************************************************************************************************
	
		If Not rsOPDBInfo.EOF Then
			OpDbBuildVersion	= rsOPDBInfo("vchLabel").Value
			OpDbBuildDate		= rsOPDBInfo("dtBuildDate").Value
		Else
			sAlertDescription = sAlertDescription & vBCrLf & "OPERATIONS DATABASE MISSING BUILD TABLE: " & rsDBInfo("DBName").Value & vBCrLf
			bWriteLOG = True
		End If
	
	End If
        
    End If

    rsDBInfo.MoveNext
    
Loop

Set cmd = Nothing
Set rsDBInfo = Nothing
Set rsOPDBInfo = Nothing
Set cnManagedInstance = Nothing 
Set cnManagedOPDBInstance = Nothing 
Set cnAnalysisInstance = Nothing
   
'Write to Evt Log   
If bWriteLOG = True Then
    Set objShell = CreateObject("Wscript.Shell")
    strCmd = "eventcreate /SO OperationsDBChecks /T "& isErrorOrWarning & " /ID 999 /L APPLICATION /D" & " """ & sAlertDescription & """"
    ReturnCode = objShell.Run(strCmd,vbHide,True)
    Set objShell = Nothing
End If
