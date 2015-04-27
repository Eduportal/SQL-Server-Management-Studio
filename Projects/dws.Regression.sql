/*

  You have to change the path to match your environment

*/

CREATE ASSEMBLY [dws.Regression]
FROM		'\\seapsqldba01\DBA_Docs\dws.Regression.dll'
WITH		PERMISSION_SET = SAFE
GO

CREATE AGGREGATE [Linear]
(
	@x FLOAT,
	@y FLOAT
)
RETURNS [xml]
EXTERNAL NAME [dws.Regression].[dws.Linear]
GO

CREATE AGGREGATE [Polynomial]
(
	@d INT,
	@x FLOAT,
	@y FLOAT
)
RETURNS [xml]
EXTERNAL NAME [dws.Regression].[dws.Polynomial]
GO

CREATE AGGREGATE [Spearman]
(
	@Rank1 INT,
	@Rank2 INT
)
RETURNS [xml]
EXTERNAL NAME [dws.Regression].[dws.Spearman]
GO