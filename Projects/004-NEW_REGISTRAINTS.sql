/*====================================================================
Website Registrants - New/within last 7 days
=====================================================================*/

/*================================================================================
Customer Lightboxes - Query:  Identify Customers that have created/modified lightboxes 
in the last 7 days
==================================================================================*/
GO
SET NOCOUNT ON

DECLARE		@dateset			datetime
SET			@dateset			= CAST(CONVERT(VarChar(12),getdate()-7,101)AS DateTime)+.0625

;WITH		CM -- Country Map
	AS		(
			SELECT 'UNKNOWN' [SalesTeam],'Unknown' [Region],'Unknown' [SubRegion],'Unknown' [Territory],'Unknown' [Country],'Unk' [CountryCode] UNION ALL
			SELECT 'INDIRECT','APAC','Other APAC','Other APAC','India','AFG' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Other EMEA','Yugoslavia','ALB' UNION ALL
			SELECT 'FRANCE','EMEA','S.Europe','France','France','DZA' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Guam','ASM' UNION ALL
			SELECT 'IBERIA','EMEA','S.Europe','Iberia','Spain','AND' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','AGO' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Aruba','AIA' UNION ALL
			SELECT 'Australia/NZ','APAC','Australasia','Australasia','Australia','ATA' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Aruba','ATG' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Argentina','ARG' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Other EMEA','Russia','ARM' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Aruba','ABW' UNION ALL
			SELECT 'Australia/NZ','APAC','Australasia','Australasia','Australia','AUS' UNION ALL
			SELECT 'GLR','EMEA','GLR','GLR','Austria','AUT' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Other EMEA','Russia','AZE' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Bahamas','BHS' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Middle East','Turkey','BHR' UNION ALL
			SELECT 'INDIRECT','APAC','Other APAC','Other APAC','India','BGD' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Barbados','BRB' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Other EMEA','Belarus','BLR' UNION ALL
			SELECT 'BENELUX','EMEA','NEB','Benelux','Belgium','BEL' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Costa Rica','BLZ' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','BEN' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Bermuda','BMU' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Bolivia','BOL' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Other EMEA','Yugoslavia','BIH' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','BWA' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Brazil','BRA' UNION ALL
			SELECT 'HK&SEA','APAC','SEA/HK','SEA','Indonesia','IOT' UNION ALL
			SELECT 'HK&SEA','APAC','SEA/HK','SEA','Malaysia','BRN' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Other EMEA','Bulgaria','BGR' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','BFA' UNION ALL
			SELECT 'HK&SEA','APAC','SEA/HK','SEA','Thailand','KHM' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','Egypt','CMR' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','CPV' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Cayman Islands','CYM' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','TCD' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Chile','CHL' UNION ALL
			SELECT 'INDIRECT','APAC','China','China','China','CHN' UNION ALL
			SELECT 'HK&SEA','APAC','SEA/HK','SEA','Indonesia','CXR' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Colombia','COL' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','Egypt','COG' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','COD' UNION ALL
			SELECT 'Australia/NZ','APAC','Australasia','Australasia','Australia','COK' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Costa Rica','CRI' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','Egypt','CIV' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Central Europe','Croatia','HRV' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Aruba','CUB' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Other EMEA','Cyprus','CYP' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Central Europe','Czech Republic','CZE' UNION ALL
			SELECT 'NORDIC','EMEA','NEB','Northern Europe','Denmark','DNK' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','DJI' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Aruba','DMA' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Dominican Republic','DOM' UNION ALL
			SELECT 'NORTH AMERICA','Americas','N.America','N.America','Canada','CAN' UNION ALL
			SELECT 'NORTH AMERICA','Americas','N.America','N.America','United States','USA' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Ecuador','ECU' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','Egypt','EGY' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','El Salvador','SLV' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','Egypt','ERI' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Other EMEA','Baltic','EST' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','ETH' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Argentina','FLK' UNION ALL
			SELECT 'NORDIC','EMEA','NEB','Northern Europe','Denmark','FRO' UNION ALL
			SELECT 'Australia/NZ','APAC','Australasia','Australasia','Australia','FJI' UNION ALL
			SELECT 'NORDIC','EMEA','NEB','Northern Europe','Finland','FIN' UNION ALL
			SELECT 'FRANCE','EMEA','S.Europe','France','France','FRA' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Costa Rica','GUF' UNION ALL
			SELECT 'FRANCE','EMEA','S.Europe','France','France','PYF' UNION ALL
			SELECT 'FRANCE','EMEA','S.Europe','France','France','ATF' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','Egypt','GAB' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','GMB' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Other EMEA','Georgia','GEO' UNION ALL
			SELECT 'GLR','EMEA','GLR','GLR','Germany','DEU' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','GHA' UNION ALL
			SELECT 'UKI','EMEA','UKI','UKI','United Kingdom','GIB' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Other EMEA','Greece','GRC' UNION ALL
			SELECT 'NORDIC','EMEA','NEB','Northern Europe','Denmark','GRL' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Aruba','GRD' UNION ALL
			SELECT 'FRANCE','EMEA','S.Europe','France','France','GLP' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Guam','GUM' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Guatemala','GTM' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','GIN' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Guyana','GUY' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Aruba','HTI' UNION ALL
			SELECT 'ITALY','EMEA','S.Europe','Italy','Italy','VAT' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Honduras','HND' UNION ALL
			SELECT 'HK&SEA','APAC','SEA/HK','Hong Kong','Hong Kong','HKG' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Other EMEA','Hungary','HUN' UNION ALL
			SELECT 'INDIRECT','EMEA','NEB','Northern Europe','Iceland','ISL' UNION ALL
			SELECT 'INDIRECT','APAC','Other APAC','Other APAC','India','IND' UNION ALL
			SELECT 'HK&SEA','APAC','SEA/HK','SEA','Indonesia','IDN' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Middle East','Turkey','IRN' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Middle East','Turkey','IRQ' UNION ALL
			SELECT 'UKI','EMEA','UKI','UKI','Ireland','IRL' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Middle East','Israel','ISR' UNION ALL
			SELECT 'ITALY','EMEA','S.Europe','Italy','Italy','ITA' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Jamaica','JAM' UNION ALL
			SELECT 'Japan','APAC','Japan','Japan','Japan','JPN' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Middle East','Turkey','JOR' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Other EMEA','Russia','KAZ' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','KEN' UNION ALL
			SELECT 'INDIRECT','APAC','Other APAC','Other APAC','Korea','PRK' UNION ALL
			SELECT 'INDIRECT','APAC','Other APAC','Other APAC','Korea','KOR' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Middle East','Turkey','KWT' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Other EMEA','Russia','KGZ' UNION ALL
			SELECT 'HK&SEA','APAC','SEA/HK','SEA','Thailand','LAO' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Other EMEA','Baltic','LVA' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Middle East','Lebanon','LBN' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','LSO' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','Egypt','LBY' UNION ALL
			SELECT 'GLR','EMEA','GLR','GLR','Austria','LIE' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Other EMEA','Baltic','LTU' UNION ALL
			SELECT 'BENELUX','EMEA','NEB','Benelux','Luxembourg','LUX' UNION ALL
			SELECT 'HK&SEA','APAC','SEA/HK','Hong Kong','Hong Kong','MAC' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Other EMEA','Yugoslavia','MKD' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','MDG' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','MWI' UNION ALL
			SELECT 'HK&SEA','APAC','SEA/HK','SEA','Malaysia','MYS' UNION ALL
			SELECT 'INDIRECT','APAC','Other APAC','Other APAC','India','MDV' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','MLI' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Other EMEA','Malta','MLT' UNION ALL
			SELECT 'FRANCE','EMEA','S.Europe','France','France','MTQ' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','MUS' UNION ALL
			SELECT 'FRANCE','EMEA','S.Europe','France','France','MYT' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Mexico','MEX' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Other EMEA','Russia','MDA' UNION ALL
			SELECT 'FRANCE','EMEA','S.Europe','France','France','MCO' UNION ALL
			SELECT 'INDIRECT','APAC','Other APAC','Other APAC','India','MNG' UNION ALL
			SELECT 'FRANCE','EMEA','S.Europe','France','France','MAR' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','MOZ' UNION ALL
			SELECT 'INDIRECT','APAC','Other APAC','Other APAC','India','MMR' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','NAM' UNION ALL
			SELECT 'INDIRECT','APAC','Other APAC','Other APAC','India','NPL' UNION ALL
			SELECT 'BENELUX','EMEA','NEB','Benelux','Netherlands','NLD' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Aruba','ANT' UNION ALL
			SELECT 'Australia/NZ','APAC','Australasia','Australasia','Australia','NCL' UNION ALL
			SELECT 'Australia/NZ','APAC','Australasia','Australasia','New Zealand','NZL' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Aruba','NIC' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','NGA' UNION ALL
			SELECT 'Australia/NZ','APAC','Australasia','Australasia','Australia','NIU' UNION ALL
			SELECT 'HK&SEA','APAC','SEA/HK','SEA','Philippines','MNP' UNION ALL
			SELECT 'NORDIC','EMEA','NEB','Northern Europe','Norway','NOR' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Middle East','Turkey','OMN' UNION ALL
			SELECT 'INDIRECT','APAC','Other APAC','Other APAC','India','PAK' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Middle East','Turkey','PSE' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Panama','PAN' UNION ALL
			SELECT 'HK&SEA','APAC','SEA/HK','SEA','Indonesia','PNG' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Paraguay','PRY' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Peru','PER' UNION ALL
			SELECT 'HK&SEA','APAC','SEA/HK','SEA','Philippines','PHL' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Other EMEA','Poland','POL' UNION ALL
			SELECT 'IBERIA','EMEA','S.Europe','Iberia','Portugal','PRT' UNION ALL
			SELECT 'IBERIA','EMEA','S.Europe','Iberia','Portugal','PR1' UNION ALL
			SELECT 'IBERIA','EMEA','S.Europe','Iberia','Portugal','PR2' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Puerto Rico','PRI' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Middle East','Turkey','QAT' UNION ALL
			SELECT 'FRANCE','EMEA','S.Europe','France','France','REU' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Other EMEA','Romania','ROM' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Other EMEA','Russia','RUS' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','Egypt','RWA' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Aruba','KNA' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Aruba','LCA' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Guam','WSM' UNION ALL
			SELECT 'ITALY','EMEA','S.Europe','Italy','Italy','SMR' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Middle East','Turkey','SAU' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','SEN' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','Egypt','SYC' UNION ALL
			SELECT 'HK&SEA','APAC','SEA/HK','SEA','Singapore','SGP' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Central Europe','Czech Republic','SVK' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Central Europe','Slovenia','SVN' UNION ALL
			SELECT 'Australia/NZ','APAC','Australasia','Australasia','Australia','SLB' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','ZAF' UNION ALL
			SELECT 'IBERIA','EMEA','S.Europe','Iberia','Spain','ESP' UNION ALL
			SELECT 'IBERIA','EMEA','S.Europe','Iberia','Spain','ES1' UNION ALL
			SELECT 'HK&SEA','APAC','SEA/HK','SEA','Sri Lanka','LKA' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Aruba','VCT' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','SDN' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Other EMEA','Russia','SUR' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','SWZ' UNION ALL
			SELECT 'NORDIC','EMEA','NEB','Northern Europe','Sweden','SWE' UNION ALL
			SELECT 'GLR','EMEA','GLR','GLR','Switzerland','CHE' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Middle East','Turkey','SYR' UNION ALL
			SELECT 'HK&SEA','APAC','SEA/HK','Hong Kong','Taiwan','TWN' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Other EMEA','Russia','TJK' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','Egypt','TZA' UNION ALL
			SELECT 'HK&SEA','APAC','SEA/HK','SEA','Thailand','THA' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','TGO' UNION ALL
			SELECT 'Australia/NZ','APAC','Australasia','Australasia','Australia','TON' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Trinidad and Tobago','TTO' UNION ALL
			SELECT 'FRANCE','EMEA','S.Europe','France','France','TUN' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Middle East','Turkey','TUR' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Aruba','TCA' UNION ALL
			SELECT 'Australia/NZ','APAC','Australasia','Australasia','Australia','TUV' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','Egypt','UGA' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Other EMEA','Ukraine','UKR' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Middle East','United Arab Emirates','ARE' UNION ALL
			SELECT 'UKI','EMEA','UKI','UKI','United Kingdom','GBR' UNION ALL
			SELECT 'UKI','EMEA','UKI','UKI','United Kingdom','GB1' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Uruguay','URY' UNION ALL
			SELECT 'NORTH AMERICA','Americas','N.America','N.America','United States','UMI' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Other EMEA','Russia','UZB' UNION ALL
			SELECT 'Australia/NZ','APAC','Australasia','Australasia','Australia','VUT' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Venezuela','VEN' UNION ALL
			SELECT 'HK&SEA','APAC','SEA/HK','SEA','Vietnam','VNM' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Virgin Islands','VGB' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Virgin Islands','VIR' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','ESH' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Middle East','Turkey','YEM' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Other EMEA','Yugoslavia','YUG' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','ZMB' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','ZWE' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','Equatorial Guinea','GNQ' UNION ALL
			SELECT 'UNKNOWN','Unknown','Unknown','Unknown','Unknown','ALL' UNION ALL
			SELECT 'Australia/NZ','APAC','Australasia','Australasia','Australia','PCN' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','BDI' UNION ALL
			SELECT 'INDIRECT','APAC','Other APAC','Other APAC','India','BTN' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','BVT' UNION ALL
			SELECT 'Australia/NZ','APAC','Australasia','Australasia','Australia','CCK' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','COM' UNION ALL
			SELECT 'HK&SEA','APAC','SEA/HK','SEA','Indonesia','FSM' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','GNB' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','HMD' UNION ALL
			SELECT 'Australia/NZ','APAC','Australasia','Australasia','Australia','KIR' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','LBR' UNION ALL
			SELECT 'Australia/NZ','APAC','Australasia','Australasia','Australia','MHL' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','MRT' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Montserrat','MSR' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','NER' UNION ALL
			SELECT 'Australia/NZ','APAC','Australasia','Australasia','Australia','NFK' UNION ALL
			SELECT 'HK&SEA','APAC','SEA/HK','SEA','Indonesia','NRU' UNION ALL
			SELECT 'HK&SEA','APAC','SEA/HK','SEA','Indonesia','PLW' UNION ALL
			SELECT 'INDIRECT','Americas','L.America','L.America','Argentina','SGS' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','SHN' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Other EMEA','Russia','SJM' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','SLE' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','SOM' UNION ALL
			SELECT 'FRANCE','EMEA','S.Europe','France','France','SPM' UNION ALL
			SELECT 'IBERIA','EMEA','S.Europe','Iberia','Portugal','STP' UNION ALL
			SELECT 'Australia/NZ','APAC','Australasia','Australasia','New Zealand','TKL' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Other EMEA','Turkmenistan','TKM' UNION ALL
			SELECT 'HK&SEA','APAC','SEA/HK','SEA','Philippines','TMP' UNION ALL
			SELECT 'Australia/NZ','APAC','Australasia','Australasia','Australia','WLF' UNION ALL
			SELECT 'INDIRECT','EMEA','Other EMEA','Africa','South Africa','CAF'
			)
			,TEMP1
	AS		(
			SELECT		i.iIndividualId
						, ISNULL(w.tiSendEmailFlag,0)		[SendGYIEM]
						, ISNULL(w2.tiSendEmailFlag,0)		[SendJIEM] 
						, ISNULL(w3.tiSendEmailFlag,0)		[SendPSEM] 
						, ISNULL(w4.tiSendEmailFlag,0)		[SendCAEM] 
						, ISNULL(w5.tiSendEmailFlag,0)		[SendPHEM] 
			FROM		SEAPSQLRPT01.wcds.dbo.individual i
			LEFT JOIN	SEAPSQLRPT01.wcds.dbo.websiteuse w  
				ON		i.iIndividualID = w.iIndividualID
				AND		w.iOriginalSystemID = 100
				AND		i.dtcreated >= @dateset
			LEFT JOIN	SEAPSQLRPT01.wcds.dbo.websiteuse w2  
				ON		i.iIndividualID = w2.iIndividualID
				AND		w2.iOriginalSystemID = 400
			LEFT JOIN	SEAPSQLRPT01.wcds.dbo.websiteuse w3 
				ON		i.iIndividualID = w3.iIndividualID
				AND		w3.iOriginalSystemID = 302
			LEFT JOIN	SEAPSQLRPT01.wcds.dbo.websiteuse w4  
				ON		i.iIndividualID = w4.iIndividualID
				AND		w4.iOriginalSystemID = 420
			LEFT JOIN	SEAPSQLRPT01.wcds.dbo.websiteuse w5 
				ON		i.iIndividualID = w5.iIndividualID
				AND		w5.iOriginalSystemID = 410
			)
			,TEMP22
	AS		(
			SELECT		os.vchoriginalsystemname					[Site]						--DON SCHENCK 2/19/2009 ADDED
						, i.iindividualid 							[Contact ID] 
						, i.vchgivenname + ' ' + i.vchfamilyname 	[Contact Name]
						, i.vchusername 							[User Name]
						, email.vchemailaddress						[Email]
						, ph.vchphonenumber							[Phone]
						, i.vchoffice 								[Free Text Company Name] 
						, i.dtcreated 								[Create Date]
						, co.vchcompanyname							[Associated Company Name]
						, co.icompanyid								[Associated Company Number]
						, cr1.nvchcountryname 						[Billing Country]
						, ma.vchCity								[Mailing City]
						, i.nchcountrycode							[Billing Country Code]		--DON SCHENCK 2/19/2009 ADDED
						, ma.chstatecode							[Mailing State]
						, cr2.nvchcountryname 						[Mailing Country]
						, ocat.OrgTypeCategoryName					[Org Category]				--DON SCHENCK 2/19/2009 ADDED
						, o.OrgTypeName								[Org Type]					--DON SCHENCK 2/19/2009 ADDED
						, case
							when jt.JobTitleName = '<None>' 
							then i.vchJobtitletext 
							else coalesce	(
											jt.JobTitleName
											, jdt.nvchJobTypeDescription
											) 
							end										[JobTitle]					--DON SCHENCK 2/19/2009 ADDED
						, year(i.dtcreated)							[Year Number]
						, month(i.dtcreated)						[Month Number] 
						, day(i.dtcreated)							[Day] 
						, sum(case
								when od.munitprice > 0 
								then od.iquantity 
								else 0 
								end
								)									[Items Ordered]				--DON SCHENCK 2/19/2009 ADDED
						, sum(od.munitprice)						[Sales] 
						, ors.vchCurrencyCode						[Currency Code] 
						, i.tiGIPrintedMaterialFlag
						, i.tiJIPrintedMaterialFlag
						, i.tiPSPrintedMaterialFlag
						, i.tiCAPrintedMaterialFlag
						, i.tiPHPrintedMaterialFlag
						, i.tiPartnerEmailFlag
			FROM		SEAPSQLRPT01.wcds.dbo.individual i 
			LEFT JOIN	SEAPSQLRPT01.wcds.dbo.companyindividualrel coind  
				ON		i.iindividualid = coind.iindividualid 
			LEFT JOIN	SEAPSQLRPT01.wcds.dbo.company co  
				ON		co.icompanyid = coind.icompanyid
			LEFT JOIN	SEAPSQLRPT01.wcds.dbo.countryreadonly cr1  
				ON		i.nchcountrycode = cr1.nchcountrycode
			LEFT JOIN	SEAPSQLRPT01.wcds.dbo.address ma  
				ON		i.iprimmailtoaddressid = ma.iaddressid
			LEFT JOIN	SEAPSQLRPT01.wcds.dbo.countryreadonly cr2  
				ON		cr2.nchcountrycode  = ma.nchcountrycode
			LEFT JOIN	SEAPSQLRPT01.wcds.dbo.JobDescriptionType jdt  
				ON		jdt.iJobDescriptionTypeId = i.iJobDescriptionTypeId
			LEFT JOIN	SEAPSQLRPT01.wcds.dbo.JobTitleCategoryJobTitleRel jrel					--DON SCHENCK 2/19/2009 ADDED
				ON		jrel.JobTitleCategoryJobTitleRelID = i.iJobTitleCategoryJobTitleRelID
			LEFT JOIN	SEAPSQLRPT01.wcds.dbo.jobtitle jt										--DON SCHENCK 2/19/2009 ADDED
				ON		jt.jobtitleid = jrel.jobtitleid											--DON SCHENCK 2/19/2009 ADDED
			LEFT JOIN	SEAPSQLRPT01.wcds.dbo.OrgTypeCategoryOrgTypeRel orgrel					--DON SCHENCK 2/19/2009 ADDED
				ON		orgrel.OrgTypeCategoryOrgTypeRelID = i.iOrgTypeCategoryOrgTypeRelID		--DON SCHENCK 2/19/2009 ADDED
			LEFT JOIN	SEAPSQLRPT01.wcds.dbo.OrgType o											--DON SCHENCK 2/19/2009 ADDED
				ON		o.orgtypeid = orgrel.orgtypeid
			LEFT JOIN	SEAPSQLRPT01.wcds.dbo.OrgTypeCategory ocat								--DON SCHENCK 2/19/2009 ADDED
				ON		ocat.OrgTypeCategoryID = orgrel.OrgTypeCategoryID
			LEFT JOIN	SEAPSQLRPT01.wcds.dbo.email email  
				ON		email.iindividualid = i.iindividualid
			LEFT JOIN	SEAPSQLRPT01.wcds.dbo.phone ph  
				ON		ph.ientityid = i.iindividualid
				AND		itechnologytypeid = 400
				AND		iusagetypeid = 302
			LEFT JOIN	SEAPSQLRPT01.wcds.dbo.orders ors  
				ON		ors.iindividualid = i.iindividualid
			LEFT JOIN	SEAPSQLRPT01.wcds.dbo.orderdetail od  
				ON		od.iorderid = ors.iorderid
			JOIN		SEAPSQLRPT01.wcds.dbo.websiteuse w  
				ON		w.iIndividualID = i.iIndividualID
				AND		w.iOriginalSystemID = 100
			JOIN		SEAPSQLRPT01.wcds.dbo.originalsystem os									--DON SCHENCK 2/19/2009 ADDED
				ON		os.ioriginalsystemid = i.ioriginalsystemid
			WHERE		i.tiTestUserFlag = 0
				and		i.iTypeID IN (1000,1001,1002)
				and		i.dtcreated >= @dateset
			GROUP BY	os.vchoriginalsystemname												--DON SCHENCK 2/19/2009 ADDED os.vchoriginalsystemname to GROUP BY 
						, i.iindividualid
						, i.vchgivenname + ' ' + i.vchfamilyname
						, i.vchusername
						, i.vchoffice
						, i.dtcreated
						, i.nchcountrycode														--DON SCHENCK 2/19/2009 ADDED
						, ma.chstatecode
						, ma.nchcountrycode
						, jdt.nvchJobTypeDescription
						, ocat.OrgTypeCategoryName												--DON SCHENCK 2/19/2009 ADDED
						, o.OrgTypeName															--DON SCHENCK 2/19/2009 ADDED
						, i.vchJobTitleText														--DON SCHENCK 2/19/2009 ADDED
						, jt.JobTitleName														--DON SCHENCK 2/19/2009 ADDED
						, cr1.nvchCountryName
						, cr2.nvchCountryName
						, cr2.nchcountrycode 
						, email.vchemailaddress
						, ph.vchphonenumber
						, year(i.dtcreated)
						, month(i.dtcreated) 
						, day(i.dtcreated)
						, ma.vchCity 
						, i.nchcountrycode
						, ors.vchCurrencyCode
						, co.vchcompanyname
						, co.icompanyid
						, i.tiGIPrintedMaterialFlag
						, i.tiJIPrintedMaterialFlag
						, i.tiPSPrintedMaterialFlag
						, i.tiCAPrintedMaterialFlag
						, i.tiPHPrintedMaterialFlag
						, i.tiPartnerEmailFlag
			)
			,Final
	AS		(
			SELECT		t2.*
						,case
							when tiGIPrintedMaterialFlag = 1 
								then 'Yes'
							when isnull(tiGIPrintedMaterialFlag,0) = 0 
								then 'No' 
							else 'ERROR' 
							end											[SendGYIDM]

						,case
							when tiJIPrintedMaterialFlag = 1 
								then 'Yes'
							when isnull(tiJIPrintedMaterialFlag,0) = 0 
								then 'No' 
							else 'ERROR' 
							end											[SendJIDM]

						,case
							when tiPSPrintedMaterialFlag = 1 
								then 'Yes'
							when isnull(tiPSPrintedMaterialFlag,0) = 0 
								then 'No' 
							else 'ERROR' 
							end											[SendPSDM]

						,case
							when tiCAPrintedMaterialFlag = 1 
								then 'Yes'
							when isnull(tiCAPrintedMaterialFlag,0) = 0 
								then 'No' 
							else 'ERROR' 
							end											[SendCADM]

						,case
							when tiPHPrintedMaterialFlag = 1 
								then 'Yes'
							when isnull(tiPHPrintedMaterialFlag,0) = 0 
								then 'No' 
							else 'ERROR' 
							end											[SendPHDM]

						,case
							when tiPartnerEmailFlag = 1 
								then 'Yes'
							when isnull(tiPartnerEmailFlag,0) = 0 
								then 'No' 
							else 'ERROR' 
							end											[SendPartnerEM]

						,case
							when SendGYIEM = 1 
								then 'Yes'
							when ISNULL(SendGYIEM,0) = 0 
								then 'No' 
							else 'ERROR' 
							end											[SendGYIEM]

						,case
							when SendJIEM = 1 
								then 'Yes'
							when SendJIEM = 0 
								then 'No' 
							else 'ERROR' 
							end											[SendJIEM]

						,case		
							when SendPSEM = 1 
								then 'Yes'
							when SendPSEM = 0
								then 'No' 
							else 'ERROR' 
							end											[SendPSEM]

						,case
							when SendCAEM = 1 
								then 'Yes'
							when SendCAEM = 0 
								then 'No' 
							else 'ERROR' 
							end											[SendCAEM]

						,case
							when SendPHEM = 1 
								then 'Yes'
							when SendPHEM = 0 
								then 'No' 
							else 'ERROR' 
							end											[SendPHEM]
			FROM		temp22 t2
			LEFT JOIN	temp1 t1
				ON		t1.iindividualid = t2.[contact id]
			)
			,ASS -- ASSIGNMENTS
	AS		(
			SELECT		co.icompanyid [companyid]
						,co.vchCompanyName [CompanyName]
						,MAX(CASE sci.iCompensationRoleID when 1 THEN ae.vchgivenname + ' ' + ae.vchfamilyname END)		as [StillsAE]
						,MAX(CASE sci.iCompensationRoleID when 6 THEN ae.vchgivenname + ' ' + ae.vchfamilyname END)		as [OutsideAE]
						,MAX(CASE sci.iCompensationRoleID when 11 THEN ae.vchgivenname + ' ' + ae.vchfamilyname END)	as [Researcher]
			FROM		wcds.dbo.CompanySCIUserRel sci
			JOIN		wcds.dbo.company co				
					ON	co.icompanyid = sci.icompanyid
					AND	sci.iCompensationRoleID in (6,1,11)	-- OutsideAE,Stills AE,Researcher
					AND	sci.istatusid = 1					--Still active
			JOIN	wcds.dbo.individual ae			
					ON	ae.iindividualid = sci.iSCIOwnerId
			GROUP BY	co.icompanyid,co.vchCompanyName
			)


SELECT		DISTINCT 
			b.SalesTeam
			,b.Region
			,b.SubRegion
			,b.Territory
			,c.StillsAE
			,c.OutsideAE
			,c.Researcher
			,a.Site
			,a.[Contact ID]
			,a.[Contact Name]
			,a.[User Name]
			,a.Email
			,a.Phone
			,a.[Free Text Company Name]
			,a.[Create Date]
			,a.[Associated Company Name]
			,a.[Associated Company Number]
			,a.[Billing Country]
			,a.[Billing Country Code]
			,a.[Mailing City]
			,a.[Mailing State]
			,a.[Mailing Country]
			,a.[Org Category]
			,a.[Org Type]
			,a.[JobTitle]
			,a.[Items Ordered]
			,a.Sales
			,a.[Currency Code]
			,a.SendGYIDM
			,a.SendJIDM
			,a.SendPSDM
			,a.SendCADM
			,a.SendPHDM
			,a.SendPartnerEM
			,a.SendGYIEM
			,a.SendJIEM
			,a.SendPSEM
			,a.SendCAEM
			,a.SendPHEM

FROM		final a
LEFT JOIN	CM b 
	ON		b.CountryCode=a.[Billing Country Code]
LEFT JOIN	ASS  c  
	ON		a.[Associated Company Number]=c.CompanyID
WHERE		SalesTeam IN ('IBERIA','GLR','ITALY','FRANCE','BENELUX', 'UKI','NORDIC'); 

--SalesTeam = 'Australia/NZ'
--SalesTeam = 'BENELUX'
--SalesTeam = 'FRANCE'
--SalesTeam = 'GLR'
--SalesTeam = 'HK&SEA'
--SalesTeam = 'IBERIA'
--SalesTeam = 'INDIRECT'
--SalesTeam = 'ITALY'
--SalesTeam = 'Japan'
--SalesTeam = 'NORDIC'
--SalesTeam = 'NORTH AMERICA'
--SalesTeam = 'UKI'

