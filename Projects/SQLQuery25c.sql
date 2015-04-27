ALTER VIEW	[DBA_DashBoard_ChartData]
AS
SELECT	'CCTH' [ChartID],'Change Control Ticket History' [ChartTitle],CAST((
SELECT	*
FROM	(
		SELECT	1				as Tag
				, NULL			as Parent
				, 'clr-namespace:Visifire.Charts;assembly=SLVisifire.Charts'			AS [vc:Chart!1!xmlns:vc]
				, '500'			AS [vc:Chart!1!Width]
				, '300'			AS [vc:Chart!1!Height]
				, 'Theme1'		AS [vc:Chart!1!Theme]
				, '0.5'			AS [vc:Chart!1!BorderThickness]
				, 'Gray'		AS [vc:Chart!1!BorderBrush]
				, NULL			AS [vc:Chart.Series!2!]
				, NULL			AS [vc:DataSeries!3!RenderAs]
				, NULL			AS [vc:DataSeries!3!LabelEnabled]
				, NULL			AS [vc:DataSeries.DataPoints!4!]
				, NULL			AS [vc:DataPoint!5!AxisXLabel]
				, NULL			AS [vc:DataPoint!5!YValue]  
		UNION ALL
		SELECT	2				as Tag
				, 1				as Parent
				, NULL			AS [vc:Chart!1!xmlns:vc]
				, NULL			AS [vc:Chart!1!Width]
				, NULL			AS [vc:Chart!1!Height]
				, NULL			AS [vc:Chart!1!Theme]
				, NULL			AS [vc:Chart!1!BorderThickness]
				, NULL			AS [vc:Chart!1!BorderBrush]
				, NULL			AS [vc:Chart.Series!2!]
				, NULL			AS [vc:DataSeries!3!RenderAs]
				, NULL			AS [vc:DataSeries!3!LabelEnabled]
				, NULL			AS [vc:DataSeries.DataPoints!4!]
				, NULL			AS [vc:DataPoint!5!AxisXLabel]
				, NULL			AS [vc:DataPoint!5!YValue]  
		UNION ALL            
		SELECT	3				as Tag
				, 2				as Parent
				, NULL			AS [vc:Chart!1!xmlns:vc]
				, NULL			AS [vc:Chart!1!Width]
				, NULL			AS [vc:Chart!1!Height]
				, NULL			AS [vc:Chart!1!Theme]
				, NULL			AS [vc:Chart!1!BorderThickness]
				, NULL			AS [vc:Chart!1!BorderBrush]
				, NULL			AS [vc:Chart.Series!2!]
				, 'Column'		AS [vc:DataSeries!3!RenderAs]
				, 'True'		AS [vc:DataSeries!3!LabelEnabled]
				, NULL			AS [vc:DataSeries.DataPoints!4!]
				, NULL			AS [vc:DataPoint!5!AxisXLabel]
				, NULL			AS [vc:DataPoint!5!YValue]  
		UNION ALL
		SELECT	4				as Tag
				, 3				as Parent
				, NULL			AS [vc:Chart!1!xmlns:vc]
				, NULL			AS [vc:Chart!1!Width]
				, NULL			AS [vc:Chart!1!Height]
				, NULL			AS [vc:Chart!1!Theme]
				, NULL			AS [vc:Chart!1!BorderThickness]
				, NULL			AS [vc:Chart!1!BorderBrush]
				, NULL			AS [vc:Chart.Series!2!]
				, Null			AS [vc:DataSeries!3!RenderAs]
				, Null			AS [vc:DataSeries!3!LabelEnabled]
				, NULL			AS [vc:DataSeries.DataPoints!4!]
				, NULL			AS [vc:DataPoint!5!AxisXLabel]
				, NULL			AS [vc:DataPoint!5!YValue]  
		UNION ALL		
		SELECT	5				as Tag
				, 4				as Parent
				, NULL			AS [vc:Chart!1!xmlns:vc]
				, NULL			AS [vc:Chart!1!Width]
				, NULL			AS [vc:Chart!1!Height]
				, NULL			AS [vc:Chart!1!Theme]
				, NULL			AS [vc:Chart!1!BorderThickness]
				, NULL			AS [vc:Chart!1!BorderBrush]
				, NULL			AS [vc:Chart.Series!2!]
				, NULL			AS [vc:DataSeries!3!RenderAs]
				, NULL			AS [vc:DataSeries!3!LabelEnabled]
				, NULL			AS [vc:DataSeries.DataPoints!4!]
				, [Date]		AS [vc:DataPoint!5!AxisXLabel]
				, [TicketCount]	AS [vc:DataPoint!5!YValue]  
		FROM [SEAINTRASQL01].[Users].[dbo].[DBA_DashBoard_CCTicketHistory]
		) Data 
FOR XML EXPLICIT  
)AS VarChar(8000)) [ChartData]
UNION ALL
SELECT	'NOCTH' [ChartID],'NOC Ticket History' [ChartTitle],CAST((
SELECT	*
FROM	(
		SELECT	1				as Tag
				, NULL			as Parent
				, 'clr-namespace:Visifire.Charts;assembly=SLVisifire.Charts'			AS [vc:Chart!1!xmlns:vc]
				, '500'			AS [vc:Chart!1!Width]
				, '300'			AS [vc:Chart!1!Height]
				, 'Theme1'		AS [vc:Chart!1!Theme]
				, '0.5'			AS [vc:Chart!1!BorderThickness]
				, 'Gray'		AS [vc:Chart!1!BorderBrush]
				, NULL			AS [vc:Chart.Series!2!]
				, NULL			AS [vc:DataSeries!3!RenderAs]
				, NULL			AS [vc:DataSeries!3!LabelEnabled]
				, NULL			AS [vc:DataSeries.DataPoints!4!]
				, NULL			AS [vc:DataPoint!5!AxisXLabel]
				, NULL			AS [vc:DataPoint!5!YValue]  
		UNION ALL
		SELECT	2				as Tag
				, 1				as Parent
				, NULL			AS [vc:Chart!1!xmlns:vc]
				, NULL			AS [vc:Chart!1!Width]
				, NULL			AS [vc:Chart!1!Height]
				, NULL			AS [vc:Chart!1!Theme]
				, NULL			AS [vc:Chart!1!BorderThickness]
				, NULL			AS [vc:Chart!1!BorderBrush]
				, NULL			AS [vc:Chart.Series!2!]
				, NULL			AS [vc:DataSeries!3!RenderAs]
				, NULL			AS [vc:DataSeries!3!LabelEnabled]
				, NULL			AS [vc:DataSeries.DataPoints!4!]
				, NULL			AS [vc:DataPoint!5!AxisXLabel]
				, NULL			AS [vc:DataPoint!5!YValue]  
		UNION ALL            
		SELECT	3				as Tag
				, 2				as Parent
				, NULL			AS [vc:Chart!1!xmlns:vc]
				, NULL			AS [vc:Chart!1!Width]
				, NULL			AS [vc:Chart!1!Height]
				, NULL			AS [vc:Chart!1!Theme]
				, NULL			AS [vc:Chart!1!BorderThickness]
				, NULL			AS [vc:Chart!1!BorderBrush]
				, NULL			AS [vc:Chart.Series!2!]
				, 'Column'		AS [vc:DataSeries!3!RenderAs]
				, 'True'		AS [vc:DataSeries!3!LabelEnabled]
				, NULL			AS [vc:DataSeries.DataPoints!4!]
				, NULL			AS [vc:DataPoint!5!AxisXLabel]
				, NULL			AS [vc:DataPoint!5!YValue]  
		UNION ALL
		SELECT	4				as Tag
				, 3				as Parent
				, NULL			AS [vc:Chart!1!xmlns:vc]
				, NULL			AS [vc:Chart!1!Width]
				, NULL			AS [vc:Chart!1!Height]
				, NULL			AS [vc:Chart!1!Theme]
				, NULL			AS [vc:Chart!1!BorderThickness]
				, NULL			AS [vc:Chart!1!BorderBrush]
				, NULL			AS [vc:Chart.Series!2!]
				, Null			AS [vc:DataSeries!3!RenderAs]
				, Null			AS [vc:DataSeries!3!LabelEnabled]
				, NULL			AS [vc:DataSeries.DataPoints!4!]
				, NULL			AS [vc:DataPoint!5!AxisXLabel]
				, NULL			AS [vc:DataPoint!5!YValue]  
		UNION ALL		
		SELECT	5				as Tag
				, 4				as Parent
				, NULL			AS [vc:Chart!1!xmlns:vc]
				, NULL			AS [vc:Chart!1!Width]
				, NULL			AS [vc:Chart!1!Height]
				, NULL			AS [vc:Chart!1!Theme]
				, NULL			AS [vc:Chart!1!BorderThickness]
				, NULL			AS [vc:Chart!1!BorderBrush]
				, NULL			AS [vc:Chart.Series!2!]
				, NULL			AS [vc:DataSeries!3!RenderAs]
				, NULL			AS [vc:DataSeries!3!LabelEnabled]
				, NULL			AS [vc:DataSeries.DataPoints!4!]
				, [Date]		AS [vc:DataPoint!5!AxisXLabel]
				, [TicketCount]	AS [vc:DataPoint!5!YValue]  
		FROM [SEAINTRASQL01].[Users].[dbo].[DBA_DashBoard_NOCTicketHistory]
		) Data 
FOR XML EXPLICIT  
)AS VarChar(8000)) [ChartData]
GO




Select * From [DBA_DashBoard_ChartData]