
Select *
INTO  WCDS.dbo.IndividualPassword_old_20100423
From SEAEXSQLMAIL.wcds_old.dbo.IndividualPassword


Select	T1.iIndividualID
	,T1.iOriginalSystemID
	,T1.vchPassword BadPass
	,T2.vchPassword GoodPass
INTO	IndividualPassword_fixes
From	WCDS.dbo.IndividualPassword T1 WITH(NOLOCK)
JOIN	WCDS.dbo.IndividualPassword_old_20100423 T2 WITH(NOLOCK)
ON	T1.iIndividualID= T2.iIndividualID
AND	T1.iOriginalSystemID  = T2.iOriginalSystemID
WHERE	T1.vchPassword = '03129A1EBC2A35A8'
AND	T2.vchPassword != '03129A1EBC2A35A8'



UPDATE	WCDS.dbo.IndividualPassword
SET	vchPassword = T2.GoodPass
FROM	WCDS.dbo.IndividualPassword T1
JOIN	WCDS.dbo.IndividualPassword_fixes T2
ON	T1.iIndividualID= T2.iIndividualID
AND	T1.iOriginalSystemID  = T2.iOriginalSystemID	



Select i.vchUserName From IndividualPassword ip (nolock)
Inner Join Individual i on i.iIndividualId = ip.iIndividualId
Where ip.vchPassword = '03129A1EBC2A35A8'




Select i.vchUserName 
	,T3.vchPassword

From IndividualPassword ip (nolock)
Inner Join Individual i on i.iIndividualId = ip.iIndividualId
LEFT JOIN WCDS.dbo.IndividualPassword_old_20100423 T3
ON	ip.iIndividualID= t3.iIndividualID
AND	ip.iOriginalSystemID  = t3.iOriginalSystemID	
Where ip.vchPassword = '03129A1EBC2A35A8'
