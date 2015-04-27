
SELECT		insertion_date	
		,Current_Rows	
		,Current_Size	
		,Additional_Rows	
		,Additional_Size
		,((Current_Rows+Additional_Rows)*100.)/Current_Rows Row_Pct_Growth
		,((Current_Size+Additional_Size)*100.)/Current_Size Size_Pct_Growth
FROM		(
		SELECT		CAST(CONVERT(VarChar(12),insertion_time,101)AS DateTime) insertion_date
				,SUM(CASE
					WHEN channel in	(
							'100 Inc Backup Expires May 21',
							'100 Inc Backup partner nhl',
							'100 Inc Backup partner default',
							'100 Inc Backup Picturedesk',
							'100 Inc Backup Special',
							'100 Incoming Backup insert',
							'100 INSERT EMAIL UPLOAD',
							'100 INSERT Inc Back News Photo',
							'100 INSERT Inc Back Spo Photo',
							'100 INSERT Inc Backup 02',
							'102 INSERT GIFT GENERAL',
							'103 INSERT SE Nascar 01',
							'103 INSERT SpecEvent',
							'400 Special Exclusives Inserter'
							)
					THEN 1 
					ELSE 0
					END) AS Current_Rows
				,SUM(CASE
					WHEN channel in	(
							'100 Inc Backup Expires May 21',
							'100 Inc Backup partner nhl',
							'100 Inc Backup partner default',
							'100 Inc Backup Picturedesk',
							'100 Inc Backup Special',
							'100 Incoming Backup insert',
							'100 INSERT EMAIL UPLOAD',
							'100 INSERT Inc Back News Photo',
							'100 INSERT Inc Back Spo Photo',
							'100 INSERT Inc Backup 02',
							'102 INSERT GIFT GENERAL',
							'103 INSERT SE Nascar 01',
							'103 INSERT SpecEvent',
							'400 Special Exclusives Inserter'
							)
					THEN	DataLength(Getdate)		--   8
						+DataLength(filename)		--  24
						+DataLength(byline)		--  32
						+DataLength(orig_trans_ref)	--  32
						+DataLength(channel)		--  32
						+DataLength(Insertion_Time)	--   8
						+DataLength(originalfilename)	-- 254
						+4
					ELSE	0	
					END) AS [Current_Size]

				,SUM(CASE
					WHEN channel in	(
							'100 Inc Backup Expires May 21',
							'100 Inc Backup partner nhl',
							'100 Inc Backup partner default',
							'100 Inc Backup Picturedesk',
							'100 Inc Backup Special',
							'100 Incoming Backup insert',
							'100 INSERT EMAIL UPLOAD',
							'100 INSERT Inc Back News Photo',
							'100 INSERT Inc Back Spo Photo',
							'100 INSERT Inc Backup 02',
							'102 INSERT GIFT GENERAL',
							'103 INSERT SE Nascar 01',
							'103 INSERT SpecEvent',
							'400 Special Exclusives Inserter'
							)
					THEN 0 
					ELSE 1
					END) AS Additional_Rows
				,SUM(CASE
					WHEN channel in	(
							'100 Inc Backup Expires May 21',
							'100 Inc Backup partner nhl',
							'100 Inc Backup partner default',
							'100 Inc Backup Picturedesk',
							'100 Inc Backup Special',
							'100 Incoming Backup insert',
							'100 INSERT EMAIL UPLOAD',
							'100 INSERT Inc Back News Photo',
							'100 INSERT Inc Back Spo Photo',
							'100 INSERT Inc Backup 02',
							'102 INSERT GIFT GENERAL',
							'103 INSERT SE Nascar 01',
							'103 INSERT SpecEvent',
							'400 Special Exclusives Inserter'
							)
					THEN	0
					ELSE	DataLength(Getdate)		--   8
						+DataLength(filename)		--  24
						+DataLength(byline)		--  32
						+DataLength(orig_trans_ref)	--  32
						+DataLength(channel)		--  32
						+DataLength(Insertion_Time)	--   8
						+DataLength(originalfilename)	-- 254
						+4
					END) AS [Additional_Size]
		FROM		(
				select		distinct
						Getdate()	getdate				--   8
						, substring(pg.filename,0,24)	filename	--  24
						, pg.byline					--  32
						, pg.orig_trans_ref				--  32
						, substring(mf.channel,0,32)	channel		--  32
						, pg.Insertion_Time				--   8
						, pg.originalfilename				-- 254
				from		mg_db.dbo.mflog mf WITH(NOLOCK)	-- TOTAL --------- 390
				join		mg_db.dbo.pga_pri_14 pg  WITH(NOLOCK)
					on	pg.originalfilename  = mf.input
				WHERE		pg.insertion_time < '2013-08-09'
					AND	pg.insertion_time >= '2013-08-05'
				) Data

		GROUP BY 	CAST(CONVERT(VarChar(12),insertion_time,101)AS DateTime) WITH ROLLUP
		) Data

ORDER BY	1

--SELECT		Avg([Rows])
--		,AVG([Size])
--FROM		(
		SELECT		CAST(CONVERT(VarChar(12),[InsertionTime],101)AS DateTime) [InsertionTime]
				--year([InsertionTime]) [yr]
				--,month([InsertionTime]) [mo]
				--,[Channel]
				,COUNT(*) [Rows]
				,SUM	(
					DataLength([IncomingChannelId])
					+DataLength([IncomingChannelCreateDate])
					+DataLength([Filename])		
					+DataLength([Byline])	
					+DataLength([MEID])		
					+DataLength([Channel])	
					+DataLength([InsertionTime])	
					+DataLength([OriginalFilename])	
					) [Size]
		FROM		[DewdsReporting].[dbo].[IncomingChannel]
		WHERE		[InsertionTime] >= CAST(CONVERT(VarChar(12),getdate()-850,101)AS DateTime)
		GROUP BY	--CAST(CONVERT(VarChar(12),[IncomingChannelCreateDate],101)AS DateTime)
				--year([InsertionTime])
				--,month([InsertionTime])
				CAST(CONVERT(VarChar(12),[InsertionTime],101)AS DateTime)
				--,[Channel]
--		) Data
--WHERE		InsertionTime < = '2013-08-07'

		--(yr = 2011 and mo >= 7) OR (yr = 2012) or (yr = 2013 and mo <= 7)

ORDER BY	1

--sp_spaceused '[dbo].[IncomingChannel]'