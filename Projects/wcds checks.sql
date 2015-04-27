--sp_recompile 'wedDownloadDetailCreate129'


WCDS.dbo.wedDownloadDetailCreate129


WCDS.dbo.wedPremiumAccess_DownloadCreate_908

DECLARE		@ImageId INT
		,@SourceDetailID INT

SELECT		downloaddetailid -- select top 1 *
from		dbo.DownloadDetail WITH(NOLOCK) 
where		imageid = @ImageId 
	and	SourceDetailID = @SourceDetailID 
	and	StatusId = 950
  








SELECT d.DownloadID, 
       d.SiteId, 
       d.CreatedDate, 
       d.DownloadStatusID AS DownloadHeaderStatusID, 
       ds.vchDescription AS DownloadHeaderStatus, 
       dd.DownloadDetailID, 
       dd.ImageID, 
       dd.IndividualId, 
       dd.CompanyId, 
       dd.CompanyTypeId, 
       dd.ImageSizeExternalID, 
       dd.DownloadSourceId, 
       dd.SourceDetailID, 
       dd.OrderID, 
       dd.CollectionID, 
       dd.CollectionName, 
       dd.ImageTitle, 
       dd.PhotographerName, 
       dd.StatusModifiedBy, 
       dd.StatusModifiedDateTime, 
       dd.ImageSource, 
       dd.OrderDetailID, 
       dd.StatusID AS DownloadDetailStatusID, 
       dds.vchDescription AS DownloadDetailStatus, 
       isnull (t.vchDescription, 'Unknown') AS DownloadDetailSource, 
       b.chBrandCode 
  FROM WCDS..Download d WITH (NOLOCK) 
       JOIN WCDS..DownloadDetail dd WITH (NOLOCK) 
          ON d.DownloadID = dd.DownloadId 
       JOIN WCDS..Status ds WITH (NOLOCK) 
          ON d.DownloadStatusID = ds.iStatusID 
             AND ds.vchCategory = 'Download Image' 
       JOIN WCDS..Status dds WITH (NOLOCK) 
          ON dd.StatusID = dds.iStatusID 
             AND dds.vchCategory = 'Download Image' 
       LEFT JOIN WCDS..Type t WITH (NOLOCK) 
          ON dd.DownloadSourceID = t.iTypeID 
             AND t.vchCategory = 'Download Source' 
       JOIN WCDS..Brand b WITH (NOLOCK) 
          ON dd.CollectionID = b.iBrandID 
WHERE		dd.StatusID <> 951 
	AND	d.DownloadStatusID <> 951 
	AND	(
		d.CreatedDate >= getdate () - 14 
	  OR	dd.StatusModifiedDateTime >= getdate () - 14
		) 




SELECT		d.DownloadID, 
		d.SiteId, 
		d.CreatedDate, 
		d.DownloadStatusID AS DownloadHeaderStatusID, 
		ds.vchDescription AS DownloadHeaderStatus, 
		dd.DownloadDetailID, 
		dd.ImageID, 
		dd.IndividualId, 
		dd.CompanyId, 
		dd.CompanyTypeId, 
		dd.ImageSizeExternalID, 
		dd.DownloadSourceId, 
		dd.SourceDetailID, 
		dd.OrderID, 
		dd.CollectionID, 
		dd.CollectionName, 
		dd.ImageTitle, 
		dd.PhotographerName, 
		dd.StatusModifiedBy, 
		dd.StatusModifiedDateTime, 
		dd.ImageSource, 
		dd.OrderDetailID, 
		dd.StatusID AS DownloadDetailStatusID, 
		dds.vchDescription AS DownloadDetailStatus, 
		isnull (t.vchDescription, 'Unknown') AS DownloadDetailSource, 
		b.chBrandCode 
FROM		WCDS..Download d WITH (NOLOCK) 
JOIN		WCDS..DownloadDetail dd WITH (NOLOCK) 
	ON	d.DownloadID = dd.DownloadId
	AND	dd.StatusID <> 951
	AND	d.DownloadStatusID <> 951  

JOIN		WCDS..Status ds WITH (NOLOCK) 
	ON	d.DownloadStatusID = ds.iStatusID 
	AND	ds.vchCategory = 'Download Image' 

JOIN		WCDS..Status dds WITH (NOLOCK) 
	ON	dd.StatusID = dds.iStatusID 
	AND	dds.vchCategory = 'Download Image' 

LEFT JOIN	WCDS..Type t WITH (NOLOCK) 
	ON	dd.DownloadSourceID = t.iTypeID 
	AND	t.vchCategory = 'Download Source' 

JOIN		WCDS..Brand b WITH (NOLOCK) 
	ON	dd.CollectionID = b.iBrandID 

WHERE		d.CreatedDate >= getdate () - 14 
	OR	dd.StatusModifiedDateTime >= getdate () - 14



--EXEC [dbaadmin].[dbo].[dbasp_CreateMissingSingleColumnStats] @DatabaseName = 'WCDS'

--EXEC [dbaadmin].[dbo].[dbasp_RapidUpdateStats] @DatabaseName = 'WCDS'

exec sp_whoisactive


select		CAST(CONVERT(VarChar(12),[StatusModifiedDateTime],101)AS DATETIME)
		,DATEPART(hour,[StatusModifiedDateTime]) Hr
		,count(*) 
from		WCDS..DownloadDetail WITH(NOLOCK)
WHERE		[StatusModifiedDateTime] >= '2013-11-01'
GROUP BY	CAST(CONVERT(VarChar(12),[StatusModifiedDateTime],101)AS DATETIME)
		,DATEPART(hour,[StatusModifiedDateTime]) 
ORDER BY	1 desc, 2 desc



select		CAST(CONVERT(VarChar(12),[CreatedDate],101)AS DATETIME)
		,DATEPART(hour,[CreatedDate]) Hr
		,count(*) 
from		WCDS..Download WITH(NOLOCK)
WHERE		[CreatedDate] >= '2013-11-01'
GROUP BY	CAST(CONVERT(VarChar(12),[CreatedDate],101)AS DATETIME)
		,DATEPART(hour,[CreatedDate]) 
ORDER BY	1 desc, 2 desc


