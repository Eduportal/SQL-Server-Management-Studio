
SET IDENTITY_INSERT SCR2.dbo.SC_EventFact_Table ON
GO
ALTER TABLE SCR2.dbo.SC_EventFact_Table DISABLE TRIGGER ALL
GO

InsertSomeMore:

INSERT INTO SCR2.dbo.SC_EventFact_Table ([Computer_FK],[ComputerLogged_FK],[ConfigurationGroup_FK],[DateGenerated_FK],[DateOfFirstEvent_FK],[DateOfLastEvent_FK],[DateStarted_FK],[DateStored_FK],[DateTimeGenerated],[DateTimeOfFirstEvent],[DateTimeOfLastEvent],[DateTimeStarted],[DateTimeStored],[EventData],[EventDetail_FK],[EventID],[EventMessage],[EventType_FK],[IsAlerted],[IsConsolidated],[LocalDateGenerated_FK],[LocalDateStored_FK],[LocalDateTimeGenerated],[LocalDateTimeStored],[LocalTimeGenerated_FK],[LocalTimeStored_FK],[ProviderDetail_FK],[RepeatCount],[SMC_InstanceID],[TimeGenerated_FK],[TimeOfFirstEvent_FK],[TimeOfLastEvent_FK],[TimeStarted_FK],[TimeStored_FK],[User_FK])
SELECT [Computer_FK],[ComputerLogged_FK],[ConfigurationGroup_FK],[DateGenerated_FK],[DateOfFirstEvent_FK],[DateOfLastEvent_FK],[DateStarted_FK],[DateStored_FK],[DateTimeGenerated],[DateTimeOfFirstEvent],[DateTimeOfLastEvent],[DateTimeStarted],[DateTimeStored],[EventData],[EventDetail_FK],[EventID],[EventMessage],[EventType_FK],[IsAlerted],[IsConsolidated],[LocalDateGenerated_FK],[LocalDateStored_FK],[LocalDateTimeGenerated],[LocalDateTimeStored],[LocalTimeGenerated_FK],[LocalTimeStored_FK],[ProviderDetail_FK],[RepeatCount],[SMC_InstanceID],[TimeGenerated_FK],[TimeOfFirstEvent_FK],[TimeOfLastEvent_FK],[TimeStarted_FK],[TimeStored_FK],[User_FK] FROM SystemCenterReporting.dbo.SC_EventFact_Table
WHERE	[SMC_InstanceID] IN
(
SELECT TOP 100 [SMC_InstanceID] 
FROM SystemCenterReporting.dbo.SC_EventFact_Table 
WHERE [SMC_InstanceID] NOT IN (SELECT [SMC_InstanceID] FROM SCR2.dbo.SC_EventFact_Table)
)

If @@RowCount = 100 Goto InsertSomeMore

ALTER TABLE SCR2.dbo.SC_EventFact_Table ENABLE TRIGGER ALL
GO

GO
SET IDENTITY_INSERT SCR2.dbo.SC_EventFact_Table OFF
GO
