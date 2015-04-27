USE master
GO
IF OBJECT_ID('dbo.sp_GGShowVersion') IS NOT NULL
  DROP PROC dbo.sp_GGShowVersion
GO
CREATE PROC dbo.sp_GGShowVersion @Mask varchar(30)='%', @ObjType varchar(2)='%'
/*

GGVersion: 2.0.1
Object: sp_GGShowVersion
Description: Shows version, revision and other info for procedures, views,
triggers, and functions

Usage: sp_GGShowVersion @Mask, @ObjType -- @Mask is an object name mask
(supports wildcards)
                                      indicating which objects to list
                                      @ObjType is an object type mask
                                      (supports wildcards)
                                      indicating which object types to list

                                      Supported object types include:
                                      P   Procedures
                                      V   Views
                                      TR  Triggers
                                      FN  Functions

Returns: (none)
$Workfile: sp_ggshowversion.SQL $

$Author: Khen $. Email: khen@khen.com

$Revision: 1 $

Example: sp_GGShowVersion

Created: 2000-04-03. $Modtime: 4/29/00 2:49p $.

*/
AS
DECLARE @GGVersion varchar(30), @Revision varchar(30), @author varchar(30),
@Date varchar(30), @Modtime varchar(30)
SELECT @GGVersion='GGVersion: ',@Revision='$'+'Revision: ',@Date='$'+'Date:
',@Modtime='$'+'Modtime: ',@Author='$'+'Author: '

SELECT DISTINCT Object=SUBSTRING(o.name,1,30),
       Type=CASE o.Type
       WHEN 'P' THEN 'Procedure'
       WHEN 'V' THEN 'View'
       WHEN 'TR' THEN 'Trigger'
       WHEN 'FN' THEN 'Function'
       ELSE o.Type
       END,
       Version=CASE
                WHEN CHARINDEX(@GGVersion,c.text)<>0 THEN
SUBSTRING(LTRIM(SUBSTRING(c.text,CHARINDEX(@GGVersion,c.text)+LEN(@GGVersion),10)),1,ISNULL(NULLIF(CHARINDEX(CHAR(13),LTRIM(SUBSTRING(c.text,CHARINDEX(@GGVersion,c.text)+LEN(@GGVersion),10)))-1,-1),1))
       ELSE NULL
       END,
       Revision=CONVERT(int,
       CASE
       WHEN CHARINDEX(@Revision,c.text)<>0 THEN
SUBSTRING(LTRIM(SUBSTRING(c.text,CHARINDEX(@Revision,c.text)+LEN(@Revision),10))
,1,ISNULL(NULLIF(CHARINDEX('
',LTRIM(SUBSTRING(c.text,CHARINDEX(@Revision,c.text)+LEN(@Revision),10)))-1,-1),1))
       ELSE '0'
       END),
       Created=o.crdate,
       Owner=SUBSTRING(USER_NAME(uid),1,10),
       'Last Modified By'=
SUBSTRING(LTRIM(SUBSTRING(c.text,CHARINDEX(@Author,c.text)+LEN(@Author),10)),1,ISNULL(NULLIF(CHARINDEX('
$',LTRIM(SUBSTRING(c.text,CHARINDEX(@Author,c.text)+LEN(@Author),10)))-1,-1),1)),
       'Last Checked In'=CASE WHEN CHARINDEX(@Date,c.text)<>0 THEN
SUBSTRING(LTRIM(SUBSTRING(c.text,CHARINDEX(@Date,c.text)+LEN(@Date),15)),1,ISNULL(NULLIF(CHARINDEX('
$',LTRIM(SUBSTRING(c.text,CHARINDEX(@Date,c.text)+LEN(@Date),20)))-1,-1),1)) ELSE NULL END,
       'Last
Modified'=SUBSTRING(LTRIM(SUBSTRING(c.text,CHARINDEX(@Modtime,c.text)+LEN(@Modtime),20)),1,ISNULL(NULLIF(CHARINDEX('
$',LTRIM(SUBSTRING(c.text,CHARINDEX(@Modtime,c.text)+LEN(@Modtime),20)))-1,-1),1))
FROM dbo.syscomments c RIGHT OUTER JOIN dbo.sysobjects o ON c.id=o.id
WHERE o.name LIKE @Mask
AND (o.type LIKE @ObjType AND o.TYPE in ('P','V','FN','TR'))
AND (c.text LIKE '%'+@Revision+'%' OR c.text IS NULL)
AND (c.colid=(SELECT MIN(c1.colid) FROM syscomments c1 WHERE c1.id=c.id) OR
c.text IS NULL)
ORDER BY Object
GO
GRANT ALL ON dbo.sp_GGShowversion TO public
GO
EXEC dbo.sp_GGShowVersion