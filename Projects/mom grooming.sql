
exec sp_configure 'max degree', 1
reconfigure with override


Declare @tempdays int
Declare @daysdiff int
Declare @dayskeep int

 

set @daysdiff = 1
set @dayskeep = 90


Groom_Again:

select @tempdays = datediff(dd, min(timestored), getdate()) from sdkeventview
set @tempdays = @tempdays - 1

set @tempdays = @tempdays - @daysdiff 
select @tempdays
IF (@tempdays < @dayskeep) 
BEGIN
select 'Finished Grooming'
return 
END

 
select 'start grooming in a new loop'
select @tempdays


IF (@tempdays > @dayskeep)
BEGIN
Exec p_updategroomdays 'SC_AlertFact_Table'		, @tempdays
Exec p_updategroomdays 'SC_AlertHistoryFact_Table'	, @tempdays
Exec p_updategroomdays 'SC_AlertToEventFact_Table'	, @tempdays
Exec p_updategroomdays 'SC_EventFact_Table'		, @tempdays
Exec p_updategroomdays 'SC_EventParameterFact_Table'	, @tempdays
Exec p_updategroomdays 'SC_SampledNumericDataFact_Table', @tempdays
END


exec dbo.p_GroomDatawarehouseTables
select getdate()
DBCC opentran
goto Groom_Again

GO



DECLARE		@OldestDate	DateTime
DECLARE		@NewestDate	DateTime
DECLARE		@DaysStored	INT
SELECT		@OldestDate	= min(LocalDateTimeGenerated)
		,@NewestDate	= max(LocalDateTimeGenerated)
		,@DaysStored	= DATEDIFF(day,@OldestDate,@NewestDate)
FROM		dbo.SC_EventFact_Table


--SELECT		@OldestDate,@NewestDate,@DaysStored

select		t1.*
		,t2.TableName	
		,t3.PropertyName		AS [ColumnName]
		,t5.rowcnt			AS [Rows]
		,t5.rowcnt/@DaysStored		AS [RowsPerDay]
		,t5.reservedMB			AS [SizeMB]
		,t5.reservedMB/@DaysStored	AS [SizeMBPerDay]
		,@DaysStored-T1.GroomDays	AS [DaystoGroom]
		,(@DaysStored-T1.GroomDays)
		 * (t5.reservedMB/@DaysStored)	AS [SizeMBtoGroom]

From		dbo.SMC_Meta_WarehouseClassSchema t1
join		dbo.SMC_Meta_ClassSchemas t2
	on	t2.classid = t1.classid
left join	dbo.SMC_Meta_ClassProperties t3
	on	t3.classid = t1.classid
left join	dbo.SMC_Meta_WarehouseClassProperty t4
	on	t4.ClassPropertyID = t3.ClassPropertyID	

	
left join	(	
		select		object_name(id) TableName
				,max(rowcnt) rowcnt
				,sum(reserved)*8/1024 reservedMB
		From		sysindexes
		GROUP BY	id
		) t5
	on	t5.TableName = T2.TableName

WHERE		t4.IsGroomColumn = 1
order by	t5.rowcnt desc


GO


DELETE
























DeleteMore:

DELETE SC_SampledNumericDataFact_Table
WHERE [SMC_InstanceID] IN
(
SELECT Top 100 [SMC_InstanceID]
FROM SC_SampledNumericDataFact_Table WITH(NOLOCK)
WHERE	DateTimeAdded >= GetDate()-90
)
If @@rowcount = 100 goto DeleteMore

GO



sp_DECRYPT2K '','V'

select * from sysobjects where type = 'V'




select * 
From sysobjects
where	type in ('FN','TF','V','IF','P') 
and	id not in
(
select id From syscomments
)

UNION ALL

select * 
from sysobjects
WHERE CAST(name AS VarChar(255)) in
(
'SC_Class_HP Procurve Switch Entity_View'
,'SC_Class_HP Procurve Switch_View'
,'SC_Class_Rel_Cisco VPN Concentrator Interface-Cisco VPN Concentrator Interface ARP_View'
,'SC_Class_Rel_Cisco VPN Concentrator Interface-Cisco VPN Concentrator Interface IP_View'
,'SC_Class_Rel_IIS-IISSmtpVirtualServer_View'
,'SC_Class_Rel_IIS-IISWebServiceExtensions_View'
)

order by name

delete sysobjects where id = 28563231

GO
USE MASTER
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

CREATE PROCEDURE sp_DECRYPT2K (@objName varchar(50), @type char(1) )
--INPUT: object name (stored procedure, 
--     view or trigger), object type ('S'-store
--     d procedure, 'V'view or 'T'-trigger)
--Original idea: shoeboy <shoeboy@ade
--     quacy.org>
--Copyright © 1999-2002 SecurityFocus 
--adapted by Joseph Gama
--Planet Source Code, my employer and my
--     self are not responsible for the use of 
--     this code
--This code is provided as is and for ed
--     ucational purposes only
--Please test it and share your results
 AS
DECLARE @a nvarchar(4000), @b nvarchar(4000), @c nvarchar(4000), @d nvarchar(4000), @i int, @t bigint, @tablename varchar(255), @trigtype varchar(6)
SET @type=UPPER(@type)
IF @type='T'
	BEGIN
	SET @tablename=(SELECT sysobjects_1.name
	FROM dbo.sysobjects INNER JOIN
	 dbo.sysobjects sysobjects_1 ON dbo.sysobjects.parent_obj = sysobjects_1.id
	WHERE (dbo.sysobjects.type = 'TR') AND (dbo.sysobjects.name = @objName))
	SET @trigtype=(SELECT CASE WHEN dbo.sysobjects.deltrig > 0 THEN 'DELETE' 
					WHEN dbo.sysobjects.instrig > 0 THEN 'INSERT' 
					WHEN dbo.sysobjects.updtrig > 0 THEN 'UPDATE' END
			FROM dbo.sysobjects INNER JOIN
			 dbo.sysobjects sysobjects_1 ON dbo.sysobjects.parent_obj = sysobjects_1.id
			WHERE (dbo.sysobjects.type = 'TR') AND (dbo.sysobjects.name = @objName))
	END
--get encrypted data
SET @a=(SELECT ctext FROM syscomments WHERE id = object_id(@objName))
SET @b=case @type 
		WHEN 'S' THEN 'ALTER PROCEDURE '+ @objName +' WITH ENCRYPTION AS '+REPLICATE('-', 4000-62)
		WHEN 'V' THEN 'ALTER VIEW '+ @objName +' WITH ENCRYPTION AS SELECT dbo.dtproperties.* FROM dbo.dtproperties'+REPLICATE('-', 4000-150)
		WHEN 'T' THEN 'ALTER TRIGGER '+@objName+' ON '+ @tablename+' WITH ENCRYPTION FOR '+@trigtype+' AS PRINT ''a'''+REPLICATE('-', 4000-150)
		END
EXECUTE (@b)
--get encrypted bogus SP
SET @c=(SELECT ctext FROM syscomments WHERE id = object_id(@objName))
SET @b=case @type 
	WHEN 'S' THEN 'CREATE PROCEDURE '+ @objName +' WITH ENCRYPTION AS '+REPLICATE('-', 4000-62)
	WHEN 'V' THEN 'CREATE VIEW '+ @objName +' WITH ENCRYPTION AS SELECT dbo.dtproperties.* FROM dbo.dtproperties'+REPLICATE('-', 4000-150)
	WHEN 'T' THEN 'CREATE TRIGGER '+@objName+' ON '+ @tablename+' WITH ENCRYPTION FOR '+@trigtype+' AS PRINT ''a'''+REPLICATE('-', 4000-150)
	END
--start counter
SET @i=1
--fill temporary variable
SET @d = replicate(N'A', (datalength(@a) / 2))
--loop
WHILE @i<=datalength(@a)/2
	BEGIN
--xor original+bogus+bogus encrypted
SET @d = stuff(@d, @i, 1,
 NCHAR(UNICODE(substring(@a, @i, 1)) ^
 (UNICODE(substring(@b, @i, 1)) ^
 UNICODE(substring(@c, @i, 1)))))
	SET @i=@i+1
	END
--drop original SP
IF @type='S'
	EXECUTE ('drop PROCEDURE '+ @objName)
ELSE
	IF @type='V'
		EXECUTE ('drop VIEW '+ @objName)
	ELSE
		IF @type='T'
			EXECUTE ('drop TRIGGER '+ @objName)
--remove encryption
--try to preserve case
SET @d=REPLACE((@d),'WITH ENCRYPTION', '')
SET @d=REPLACE((@d),'With Encryption', '')
SET @d=REPLACE((@d),'with encryption', '')
IF CHARINDEX('WITH ENCRYPTION',UPPER(@d) )>0
	SET @d=REPLACE(UPPER(@d),'WITH ENCRYPTION', '')
--replace SP
execute( @d)

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



ALTER FUNCTION dbo.udf_select_concat ( @c INT )
RETURNS VARCHAR(8000) AS BEGIN
DECLARE @p VARCHAR(8000) ;
           SET @p = '' ;
        SELECT @p = @p + quotename(name) + ','
          FROM syscolumns
         WHERE id = @c ;
         SET @p = REPLACE(@P+'|',',|','')
RETURN @p
END
GO


SELECT	CASE OBJECTPROPERTYEX(id,'TableHasIdentity')
	 WHEN 1 THEN 'SET IDENTITY_INSERT SCR2.dbo.'+name+' OFF'+CHAR(13)+CHAR(10)+'GO'+CHAR(13)+CHAR(10)
	 ELSE ''END

FROM	sysobjects where type = 'u'


select	CASE OBJECTPROPERTYEX(id,'TableHasIdentity')
	 WHEN 1 THEN 'SET IDENTITY_INSERT SCR2.dbo.'+name+' ON'+CHAR(13)+CHAR(10)+'GO'+CHAR(13)+CHAR(10)
	 ELSE '' END
	
	+'ALTER TABLE SCR2.dbo.'+name+' DISABLE TRIGGER ALL'+CHAR(13)+CHAR(10)+'GO'+CHAR(13)+CHAR(10)
	+'TRUNCATE TABLE SCR2.dbo.'+name+CHAR(13)+CHAR(10)+'GO'+CHAR(13)+CHAR(10)
	+'INSERT INTO SCR2.dbo.'+name+' ('
	+ dbo.udf_select_concat( id )
	+')'+CHAR(13)+CHAR(10)
	+'SELECT '
	+ dbo.udf_select_concat( id )
	+' FROM SystemCenterReporting.dbo.'+name+CHAR(13)+CHAR(10)
	+'GO'+CHAR(13)+CHAR(10)
	
	+CASE OBJECTPROPERTYEX(id,'TableHasIdentity')
	 WHEN 1 THEN 'SET IDENTITY_INSERT SCR2.dbo.'+name+' OFF'+CHAR(13)+CHAR(10)+'GO'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
	 ELSE ''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END

FROM	sysobjects where type = 'u'
AND name not in 
(
'SC_SampledNumericDataFact_Table'
,'SC_EventFact_Table'
,'SC_EventParameterFact_Table'
,'SC_AlertHistoryFact_Table'
,'SC_ClassAttributeInstanceFact_Table'
,'SC_AlertFact_Table'
)


select	CASE OBJECTPROPERTYEX(id,'TableHasIdentity')
	 WHEN 1 THEN 'SET IDENTITY_INSERT SCR2.dbo.'+name+' ON'+CHAR(13)+CHAR(10)+'GO'+CHAR(13)+CHAR(10)
	 ELSE '' END
	
	+'ALTER TABLE SCR2.dbo.'+name+' DISABLE TRIGGER ALL'+CHAR(13)+CHAR(10)+'GO'+CHAR(13)+CHAR(10)
	+'TRUNCATE TABLE SCR2.dbo.'+name+CHAR(13)+CHAR(10)+'GO'+CHAR(13)+CHAR(10)
	+'INSERT INTO SCR2.dbo.'+name+' ('
	+ dbo.udf_select_concat( id )
	+')'+CHAR(13)+CHAR(10)
	+'SELECT '
	+ dbo.udf_select_concat( id )
	+' FROM SystemCenterReporting.dbo.'+name+' WHERE ['+T2.columnname+'] >= GetDate()-90'+CHAR(13)+CHAR(10)
	+'GO'+CHAR(13)+CHAR(10)
	
	+CASE OBJECTPROPERTYEX(id,'TableHasIdentity')
	 WHEN 1 THEN 'SET IDENTITY_INSERT SCR2.dbo.'+name+' OFF'+CHAR(13)+CHAR(10)+'GO'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
	 ELSE ''+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10) END

FROM	sysobjects
JOIN		(
		SELECT 'SC_SampledNumericDataFact_Table','DateTimeAdded'
		UNION ALL
		SELECT 'SC_EventFact_Table','DateTimeStored'
		UNION ALL
		SELECT 'SC_EventParameterFact_Table','DateTimeEventStored'
		UNION ALL
		SELECT 'SC_AlertHistoryFact_Table','DateTimeLastModified'
		UNION ALL
		SELECT 'SC_ClassAttributeInstanceFact_Table','DateTimeOfTransfer'
		UNION ALL
		SELECT 'SC_AlertFact_Table','DateTimeLastModified'
		) T2(tablename,columnname)
	ON	sysobjects.name = T2.tablename		





 where type = 'u'
AND name in 
(
'SC_SampledNumericDataFact_Table'
,'SC_EventFact_Table'
,'SC_EventParameterFact_Table'
,'SC_AlertHistoryFact_Table'
,'SC_ClassAttributeInstanceFact_Table'
,'SC_AlertFact_Table'
)


