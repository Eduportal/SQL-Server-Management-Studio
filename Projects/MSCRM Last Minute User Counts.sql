

USE [Getty_Images_US_Inc__MSCRM]

-- Users accessing the system in the last minute
SELECT		SU.BusinessUnitIdName
		,COUNT(*) [UserCount]
FROM SystemUser SU
INNER JOIN [MSCRM_CONFIG].[dbo].[SystemUserOrganizations] SUO ON SUO.CrmUserId = SU.SystemUserId
INNER JOIN [MSCRM_CONFIG].[dbo].[SystemUserAuthentication] SUA ON SUA.UserId = SUO.UserId

WHERE		SUO.LastAccessTime > DATEADD(Minute,-1,Getdate())
GROUP BY	SU.BusinessUnitIdName
ORDER BY	1










--SELECT		SU.*
--FROM		SystemUser SU
--INNER JOIN	[MSCRM_CONFIG].[dbo].[SystemUserOrganizations] SUO 
--	ON	SUO.CrmUserId = SU.SystemUserId
--INNER JOIN	[MSCRM_CONFIG].[dbo].[SystemUserAuthentication] SUA 
--	ON	SUA.UserId = SUO.UserId




