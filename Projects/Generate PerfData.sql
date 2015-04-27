
DECLARE	@Trace		Int	-- 0=NOT, 1=General, 2=Detailed
	,@Duration	CHAR(8) -- FORMAT  HH:MM:SS
	,@Service	INT	-- 0=NOT, 1=Register, 2=Start, 3=Stop, 4=Stop_Abort, 5=remove
	,@snapshot	Bit

SELECT	@Trace		= 1
	,@Duration	= '00:05:00'
	,@Service	= 0
	,@snapshot	= 0

DECLARE	@InstanceName		VarChar(50)
DECLARE @DurationString		VarChar(50)
DECLARE @ConfigString		VarChar(255)
DECLARE @ServiceString		VarChar(50)
DECLARE @SnapshotString		VarChar(50)
DECLARE	@Path			VarChar(2000)
DECLARE @CMD			VarChar(8000)

SET	@Path		= 'D:\SQLDiagPerfStats'
SET	@InstanceName	= 'SQLDiag_' +@@SERVICENAME

If @Service = 1
	SET @ServiceString = ' /R' 

ELSE IF @Service = 2
	SET @ServiceString = ' START'

ELSE IF @Service = 3
	SET @ServiceString = ' STOP'

ELSE IF @Service = 4
	SET @ServiceString = ' STOP_ABORT'

ELSE IF @Service = 5
	SET @ServiceString = ' /U'



If COALESCE(@Duration,'00:00:00') != '00:00:00'
	SET @DurationString = ' /E +'+ @Duration


If @Trace = 0
	SET @ConfigString = ' /I "' + @Path + '\SQLDiagPerfStats_NoTrace.XML"'
ELSE if @Trace = 1
	SET @ConfigString = ' /I "' + @Path + '\SQLDiagPerfStats_Trace.XML"'
ELSE if @Trace = 2
	SET @ConfigString = ' /I "' + @Path + '\SQLDiagPerfStats_Detailed_Trace.XML"'

If @snapshot = 1
	SET @SnapshotString = ' /X'


SET	@CMD	= 'SQLDIAG.exe'
		+ COALESCE(@ServiceString,'')
		+ ' /P ' + QUOTENAME(COALESCE(@Path + '\Support',''),'"') 
		+ ' /A ' + @InstanceName
IF @Service < 2	
	SET @CMD = @CMD	
		+ COALESCE(@ConfigString,'')
		+ COALESCE(@SnapshotString,'')
		+ COALESCE(@DurationString,'')
		+ ' /N 1 /Q /O "' + COALESCE(@Path,'') + '\Output"'  

PRINT @CMD
EXEC	xp_cmdshell @CMD






