USE [dbaadmin]
GO

/****** Object:  Trigger [dbo].[trgPersonAudit]    Script Date: 10/24/2011 17:12:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trgAudit_DBA_DBInfo]
ON [dbo].[DB_DBInfo]
AFTER INSERT, UPDATE, DELETE 
AS
	DECLARE @auditBody XML
	DECLARE @DMLType CHAR(1)	
	-- after delete statement
	IF NOT EXISTS (SELECT * FROM inserted)
	BEGIN	
		SELECT	@auditBody = (select * FROM deleted AS Table FOR XML RAW ('dbaadmin.dbo.DBA_DBInfo'),XMLSCHEMA ('DBA_DBInfo'), ROOT('Table') ,type),
				@DMLType = 'D'
	
	END 
	-- after update or insert statement
	ELSE
	BEGIN
		SELECT	@auditBody = (select * FROM inserted AS Table FOR XML RAW ('dbaadmin.dbo.DBA_DBInfo'),XMLSCHEMA ('DBA_DBInfo'), ROOT('Table') ,type)
		-- after update statement
		IF EXISTS (SELECT * FROM deleted)
			SELECT 	@DMLType = 'U'
		-- after insert statement
		ELSE
			SELECT	@DMLType = 'I'
	END

	-- get table name dynamicaly but
	-- for performance this should be changed to constant in every trigger like:
	-- SELECT	@tableName = 'Person'
	DECLARE @tableName sysname 
	SELECT	@tableName = tbl.name 
    FROM	sys.tables tbl 
			JOIN sys.triggers trg ON tbl.[object_id] = trg.parent_id 
    WHERE	trg.[object_id] = @@PROCID 

	SELECT @auditBody = 
		'<AuditMsg> 
			<SourceServer>' + @@servername + '</SourceServer>
			<SourceDb>' + DB_NAME() + '</SourceDb>
			<SourceTable>' + @tableName + '</SourceTable>
			<UserId>' + SUSER_SNAME() + '</UserId>
			<DMLType>' + @DMLType + '</DMLType>
			<ChangedData>' + CAST(@auditBody AS NVARCHAR(MAX)) + '</ChangedData>
		</AuditMsg>'
	-- Audit data asynchrounously
	EXEC dbo.usp_SendAuditData @auditBody


GO

EXEC sp_settriggerorder @triggername=N'[dbo].[trgPersonAudit]', @order=N'Last', @stmttype=N'DELETE'
GO

EXEC sp_settriggerorder @triggername=N'[dbo].[trgPersonAudit]', @order=N'Last', @stmttype=N'INSERT'
GO

EXEC sp_settriggerorder @triggername=N'[dbo].[trgPersonAudit]', @order=N'Last', @stmttype=N'UPDATE'
GO


