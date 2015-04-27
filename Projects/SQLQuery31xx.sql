USE DBAADMIN
GO
CREATE FUNCTION [dbo].[dbaudf_LinearForecast]
(
	@Predictor			float,
	@DelimitedXYvalues	varchar(8000)
)
RETURNS float
AS
BEGIN
	DECLARE @yDelim		nvarchar (1),
			@xDelim		nvarchar (1),
			@NextSet	int,
			@SetCount	int,
			@yPos		int,
			@xPos		int,
			@yVal		varchar(10),
			@xVal		varchar(10),
			@Values		varchar(100),
			@sigmaX		float,
			@sigmaY		float,
			@sigmaXX	float,
			@sigmaXY	float,
			@sigmaYY	float,
			@regSlope	float,
			@regYInt	float,
			@value		float
	--Initialize		 
	SET @yDelim	 = ','
	SET @xDelim	 = ':'
	SET @sigmaX = 0
	SET @sigmaY = 0
	SET @sigmaXX = 0
	SET @sigmaXY = 0
	SET @sigmaYY = 0

	--Check for trailing delimiter, if it doesn't exist then add it
	IF (RIGHT(@DelimitedXYvalues,1)<> @xDelim)
		SET @DelimitedXYvalues = @DelimitedXYvalues + @xDelim

	--Get position of first xDelim
	SET @xPos = CHARINDEX(@xDelim,@DelimitedXYvalues)
	SET @NextSet = 1
	SET @SetCount = 0

	--Loop while there is still an x delimiter in the string
	WHILE (@xPos <> 0)
	BEGIN
		SET @SetCount = @SetCount + 1
		SET @Values  = SUBSTRING(@DelimitedXYvalues,1,@xPos -1)
		SET @yPos = CHARINDEX(@yDelim,@DelimitedXYvalues)
		SET @yVal = SUBSTRING(@Values,1,@yPos -1)
		SET @xVal = SUBSTRING(@Values,@yPos + 1, LEN(@Values)-1)

		--Get the sums of X, Y, X*Y, and X^2
		SET @sigmaXY	= @sigmaXY + (CAST(@xVal as float) * CAST(@yVal as float))
		SET @sigmaXX	= @sigmaXX + POWER(CAST(@xVal as float), 2)
		SET @sigmaYY	= @sigmaYY + POWER(CAST(@yVal as float), 2)
		SET @sigmaX		= @sigmaX + @xVal	
		SET @sigmaY		= @sigmaY + @yVal

		SET @NextSet = @xPos + 1
		SET @DelimitedXYvalues = SUBSTRING(@DelimitedXYvalues,@NextSet,LEN(@DelimitedXYvalues))
		SET @xPos = CHARINDEX(@xDelim, @DelimitedXYvalues)
	END

--  Now we need to determine what the slope of the regression line will be
--  Slope(b) = NÓXY - (ÓX)(ÓY) / (NÓX2 - (ÓX)2)
	SET @regSlope	= ((@SetCount * @sigmaXY) - (@sigmaX * @sigmaY)) / ((@SetCount * @sigmaXX) - POWER(@sigmaX, 2))

--  Next we need to determine what the point of Y intercept is
--  Intercept(a) = (ÓY - b(ÓX)) / N 
	SET @regYInt	= (@sigmaY - (@regSlope * @sigmaX)) / @SetCount

--  Now use slope and intercept and predictor value in regression equation
--  Regression Equation(y) = a + bx
	SET @value		= @regYInt + (@regSlope * @Predictor)

	RETURN @value
END
GO





PRINT dbaadmin.dbo.dbaudf_LinearForecast(0, '552,6:313,5:1213,4:1204,3:721,2:428,1')

SELECT
dbo.ufn_LinearForecast(0,
CAST(JanSales as varchar) + ',' + '1:' +
CAST(FebSales as varchar) + ',' + '2:' +
CAST(MarSales as varchar) + ',' + '3:' +
CAST(AprSales as varchar) + ',' + '4:' +
CAST(MaySales as varchar) + ',' + '5:' +
CAST(JunSales as varchar) + ',' + '6:') AS Forecast
FROM dbo.SalesSummary
WHERE InvoiceDate >= '1/1/2009' AND InvoiceDate < '7/1/2009'



SELECT dbo.dbaudf_LinearForecast (10,'10,1:20,2:30,3:40,4:50,5:60,6')





SELECT dbo.dbaudf_LinearForecast (1,'1,10:2,20:3,30:4,40:5,50:6,60:7,70:8,80:9,90')
SELECT dbo.dbaudf_LinearForecast (2,'1,1:2,2:3,3:4,4:5,5:6,6:7,7:8,8:9,9')
SELECT dbo.dbaudf_LinearForecast (3,'1,1:2,2:3,3:4,4:5,5:6,6:7,7:8,8:9,9')
SELECT dbo.dbaudf_LinearForecast (4,'1,1:2,2:3,3:4,4:5,5:6,6:7,7:8,8:9,9')
SELECT dbo.dbaudf_LinearForecast (5,'1,1:2,2:3,3:4,4:5,5:6,6:7,7:8,8:9,9')
SELECT dbo.dbaudf_LinearForecast (6,'1,1:2,2:3,3:4,4:5,5:6,6:7,7:8,8:9,9')
SELECT dbo.dbaudf_LinearForecast (7,'1,1:2,2:3,3:4,4:5,5:6,6:7,7:8,8:9,9')
SELECT dbo.dbaudf_LinearForecast (8,'1,1:2,2:3,3:4,4:5,5:6,6:7,7:8,8:9,9')
SELECT dbo.dbaudf_LinearForecast (9,'1,1:2,2:3,3:4,4:5,5:6,6:7,7:8,8:9,9')
SELECT dbo.dbaudf_LinearForecast (10,'1,1:2,2:3,3:4,4:5,5:6,6:7,7:8,8:9,9')
			

SELECT	TOP 100
		datediff	(
					minute
					,(SELECT MIN(dt) [StartDate] FROM (SELECT TOP 100 dt FROM dbaperf.dbo.tempdb_space_usage WHERE scope = 'instance' ORDER BY	dt DESC) tsu)
					,dt
					)
		,(Instance_unallocated_extent_pages+version_store_pages+Instance_userobj_alloc_pages+Instance_internalobj_alloc_pages+Instance_mixed_extent_alloc_pages)*8/1024.0/1024.0 [Size_GB]
		,(version_store_pages+Instance_userobj_alloc_pages+Instance_internalobj_alloc_pages+Instance_mixed_extent_alloc_pages)*8/1024.0/1024.0 [Used_GB]
		,(version_store_pages+Instance_userobj_alloc_pages+Instance_internalobj_alloc_pages+Instance_mixed_extent_alloc_pages)*100/(Instance_unallocated_extent_pages+version_store_pages+Instance_userobj_alloc_pages+Instance_internalobj_alloc_pages+Instance_mixed_extent_alloc_pages) [PctFull]

		
FROM	dbaperf.dbo.tempdb_space_usage
WHERE	scope = 'instance'
order by dt desc




			
			
SELECT	DISTINCT TOP 100
		datediff	(
					Day
					,(SELECT MIN(rundate) FROM (SELECT DISTINCT TOP 100 rundate FROM dbaperf.dbo.db_stats_log WHERE	DatabaseName = 'getty_work_a' order by rundate desc) data)
					,rundate
					)
		,CAST([database_size_MB] AS Float) [Size]
		,CAST([unallocated space_MB] AS Float) [Free]
		,CAST([unallocated space_MB] AS Float)*100.00/CAST([database_size_MB] AS Float)				
		,*
		
FROM	dbaperf.dbo.db_stats_log
WHERE	DatabaseName = 'getty_work_a'
order by rundate desc



FROM	dbaperf.dbo.db_stats_log WHERE	DatabaseName = 'getty_work_a' order by rundate desc



SELECT		*




FROM		dbaperf.dbo.db_stats_log
WHERE		DatabaseName = 'getty_work_a'