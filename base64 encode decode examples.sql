SELECT		Name
		,FullPathName
		,DateCreated
		-- make sure to replace "$" with "=" and remove extension before decoding
		,[dbaadmin].[dbo].[dbaudf_base64_decode](
				LEFT(REPLACE([Name],'$','='),LEN([Name])-4)) DecodedFileName
		,REPLACE(
			[dbaadmin].[dbo].[ReturnPart](
				[dbaadmin].[dbo].[dbaudf_base64_decode](
					LEFT(REPLACE([Name],'$','='),LEN([Name])-4)
					)
				,1)
			,'$'
			,'\')							[ServerName]
		,[dbaadmin].[dbo].[ReturnPart](
			[dbaadmin].[dbo].[dbaudf_base64_decode](
				LEFT(REPLACE([Name],'$','='),LEN([Name])-4)
				)
			,2)							[Import_Destination]
		,[dbaadmin].[dbo].[ReturnPart](
			[dbaadmin].[dbo].[dbaudf_base64_decode](
				LEFT(REPLACE([Name],'$','='),LEN([Name])-4)
				)
			,3)							[Part3]
		,[dbaadmin].[dbo].[ReturnPart](
			[dbaadmin].[dbo].[dbaudf_base64_decode](
				LEFT(REPLACE([Name],'$','='),LEN([Name])-4)
				)
			,4)							[Part4]
		,[dbaadmin].[dbo].[ReturnPart](
			[dbaadmin].[dbo].[dbaudf_base64_decode](
				LEFT(REPLACE([Name],'$','='),LEN([Name])-4)
				)
			,5)							[Part5]
		,[dbaadmin].[dbo].[ReturnPart](
			[dbaadmin].[dbo].[dbaudf_base64_decode](
				LEFT(REPLACE([Name],'$','='),LEN([Name])-4)
				)
			,6)							[Part6]

FROM		dbaadmin.dbo.dbaudf_FileAccess_Dir2
			('\\seapdbasql01\Station_AMER_Depart',null,0)


WHERE		Extension = '.dat'
		--AND	DateModified >= GetDate()-30



-- dbaudf_Base64_encode OUTPUT GENERATES "=" which can not be used in a file name so I replace them with "$"
SELECT REPLACE([dbaadmin].[dbo].[dbaudf_base64_encode]('GMSSQLDEV01\A|IndexHealth_Results|WCDSwork|NULL|NULL|02/17/2015'),'=','$')