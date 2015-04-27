BACKUP log [SystemCenterReporting] with truncate_only
GO
USE [SystemCenterReporting]
GO
DBCC SHRINKFILE (N'REPLOG' , 0, TRUNCATEONLY)
GO
DBCC SHRINKFILE (N'REPLOG' , 0, NOTRUNCATE)
GO
DBCC SHRINKFILE (N'REPLOG' , 0, TRUNCATEONLY)
GO

Declare @tempdays int
Declare @daysdiff int
Declare @dayskeep int


set @daysdiff = 1
set @dayskeep = 90

Groom_Again:

	select		@tempdays = datediff(dd, min(DateTimeStored), getdate()) 
	from		SystemCenterReporting.dbo.SC_EventFact_Table AS aaa  with (NOLOCK) 

	set		@tempdays = @tempdays - 1

	set @tempdays = @tempdays - @daysdiff 
	select @tempdays
	
	IF (@tempdays < @dayskeep) 
	BEGIN
		select 'Finished Grooming'
		RETURN 
	END

	 
	select 'start grooming in a new loop'
	select @tempdays

	IF (@tempdays > @dayskeep)
	BEGIN
		Exec SystemCenterReporting.dbo.p_updategroomdays 'SC_AlertFact_Table'		, @tempdays
		Exec SystemCenterReporting.dbo.p_updategroomdays 'SC_AlertHistoryFact_Table'	, @tempdays
		Exec SystemCenterReporting.dbo.p_updategroomdays 'SC_AlertToEventFact_Table'	, @tempdays
		Exec SystemCenterReporting.dbo.p_updategroomdays 'SC_EventFact_Table'		, @tempdays
		Exec SystemCenterReporting.dbo.p_updategroomdays 'SC_EventParameterFact_Table'	, @tempdays
		Exec SystemCenterReporting.dbo.p_updategroomdays 'SC_SampledNumericDataFact_Table', @tempdays
	END

	exec SystemCenterReporting.dbo.p_GroomDatawarehouseTables

GOTO Groom_Again

