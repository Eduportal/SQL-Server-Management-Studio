DROP TABLE #Table
GO
CREATE TABLE #Table
	(
        SPID INT,
        Status VARCHAR(8000),
        LOGIN VARCHAR(8000),
        HostName VARCHAR(8000),
        BlkBy VARCHAR(8000),
        DBName VARCHAR(8000),
        Command VARCHAR(8000),
        CPUTime INT,
        DiskIO INT,
        LastBatch VARCHAR(8000),
        ProgramName VARCHAR(8000),
        SPID_1 INT,
        REQUESTID INT
	)

INSERT INTO #Table EXEC sp_who2

SELECT  *
FROM    #Table
WHERE	LOGIN IN ('dbasledridge','AMER\s-sledridge')
	OR	BlkBy != '  .'

GO
