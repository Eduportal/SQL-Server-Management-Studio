USE DBAADMIN
GO
DROP FUNCTION dbaudf_SparklineChart
GO
CREATE FUNCTION dbaudf_SparklineChart
(
	@name		sysname
	,@Array		VarChar(max)
)
RETURNS varchar(max)
AS
BEGIN
	DECLARE @HTMLOutput varchar(max)
SET @HTMLOutput =
'<script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">
      google.load("visualization", "1", {packages:["imagesparkline"]});
      google.setOnLoadCallback(drawChart_'+@name+');
      function drawChart_'+@name+'() {
        var data = google.visualization.arrayToDataTable([['''+@name+'''],['+REPLACE(@Array,',','],[')+']]);
        var chart = new google.visualization.ImageSparkLine(document.getElementById(''chart_'+@name+'''));
        chart.draw(data, {width: 900, height: 10, showAxisLines: false,  showValueLabels: false});
      }
    </script><div id="chart_'+@name+'"></div>'
	RETURN @HTMLOutput
END
GO


SELECT dbaadmin.dbo.dbaudf_SparklineChart('test','1,2,3,4,5,6,7,8,9,10')	

