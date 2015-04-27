

--LEVEL 1 GROUPS DATA
DECLARE Level1_Cursor CURSOR
FOR
	Select		DISTINCT 
				Col1 
	From		@ServerList
	Where		Col1 != '--'
	ORDER BY	1
OPEN Level1_Cursor
FETCH NEXT FROM Level1_Cursor INTO @Level1
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN








	END
	FETCH NEXT FROM Level1_Cursor INTO @Level1
END
CLOSE Level1_Cursor
DEALLOCATE Level1_Cursor


















































--LEVEL 1 PROPER
SET @Text = '            </sfc:Collection>
  </RegisteredServers:ServerGroups>
  <RegisteredServers:Parent>
    <sfc:Reference sml:ref="true">
      <sml:Uri>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup</sml:Uri>
    </sfc:Reference>
  </RegisteredServers:Parent>
  <RegisteredServers:Name type="string">'+@Level1+'</RegisteredServers:Name>
  <RegisteredServers:Description type="string">'+@Level1Desc+'</RegisteredServers:Description>
  <RegisteredServers:ServerType type="ServerType">DatabaseEngine</RegisteredServers:ServerType>
</RegisteredServers:ServerGroup>
</data>
</document>'
PRINT @Text
SET @Text = ''










DECLARE Level1_Cursor CURSOR
FOR
Select DISTINCT Col1 From @ServerList
OPEN Level1_Cursor
FETCH NEXT FROM Level1_Cursor INTO @Level1
WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		SET @Text = '    <document>
      <docinfo>
        <aliases>
          <alias>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup</alias>
        </aliases>
        <sfc:version DomainVersion="1" />
      </docinfo>
      <data>
        <RegisteredServers:ServerGroup xmlns:RegisteredServers="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08" xmlns:sml="http://schemas.serviceml.org/sml/2007/02" xmlns:xs="http://www.w3.org/2001/XMLSchema">
          <RegisteredServers:ServerGroups>
            <sfc:Collection>
              <sfc:Reference sml:ref="true">
                <sml:Uri>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/'+@Level1+'</sml:Uri>
              </sfc:Reference>
            </sfc:Collection>
          </RegisteredServers:ServerGroups>
          <RegisteredServers:Parent>
            <sfc:Reference sml:ref="true">
              <sml:Uri>/RegisteredServersStore</sml:Uri>
            </sfc:Reference>
          </RegisteredServers:Parent>
          <RegisteredServers:Name type="string">DatabaseEngineServerGroup</RegisteredServers:Name>
          <RegisteredServers:ServerType type="ServerType">DatabaseEngine</RegisteredServers:ServerType>
        </RegisteredServers:ServerGroup>
      </data>
    </document>
    <document>
      <docinfo>
        <aliases>
          <alias>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/'+@Level1+'</alias>
        </aliases>
        <sfc:version DomainVersion="1" />
      </docinfo>
      <data>
        <RegisteredServers:ServerGroup xmlns:RegisteredServers="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08" xmlns:sml="http://schemas.serviceml.org/sml/2007/02" xmlns:xs="http://www.w3.org/2001/XMLSchema">
          <RegisteredServers:ServerGroups>
            <sfc:Collection>'
        Print @Text	
		SET @Text = ''
		DECLARE Level2_Cursor CURSOR
		FOR
			Select DISTINCT Col2 From @ServerList
			Where Col1 = @Level1
			ORDER BY Col2
		OPEN Level2_Cursor
		FETCH NEXT FROM Level2_Cursor INTO @Level2
		WHILE (@@fetch_status <> -1)
		BEGIN
			IF (@@fetch_status <> -2)
			BEGIN
				SET @Text = '              <sfc:Reference sml:ref="true">
                <sml:Uri>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/'+@Level1+'/ServerGroup/'+@Level2+'</sml:Uri>
              </sfc:Reference>'
				PRINT @Text
				SET @Text = ''
			END
			FETCH NEXT FROM Level2_Cursor INTO @Level2
		END
		CLOSE Level2_Cursor
		DEALLOCATE Level2_Cursor
		SET @Text = '            </sfc:Collection>
          </RegisteredServers:ServerGroups>
          <RegisteredServers:Parent>
            <sfc:Reference sml:ref="true">
              <sml:Uri>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup</sml:Uri>
            </sfc:Reference>
          </RegisteredServers:Parent>
          <RegisteredServers:Name type="string">'+@Level1+'</RegisteredServers:Name>
          <RegisteredServers:Description type="string">'+@Level1Desc+'</RegisteredServers:Description>
          <RegisteredServers:ServerType type="ServerType">DatabaseEngine</RegisteredServers:ServerType>
        </RegisteredServers:ServerGroup>
      </data>
    </document>'
		PRINT @Text
		SET @Text = ''
		DECLARE Level2_Cursor CURSOR
		FOR
			Select DISTINCT Col2 From @ServerList
			Where Col1 = @Level1
			ORDER BY Col2		
		OPEN Level2_Cursor
		FETCH NEXT FROM Level2_Cursor INTO @Level2
		WHILE (@@fetch_status <> -1)
		BEGIN
			IF (@@fetch_status <> -2)
			BEGIN
				SET @Text = '    <document>
      <docinfo>
        <aliases>
          <alias>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/'+@Level1+'/ServerGroup/'+@Level2+'</alias>
        </aliases>
        <sfc:version DomainVersion="1" />
      </docinfo>
      <data>
        <RegisteredServers:ServerGroup xmlns:RegisteredServers="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08" xmlns:sml="http://schemas.serviceml.org/sml/2007/02" xmlns:xs="http://www.w3.org/2001/XMLSchema">
          <RegisteredServers:ServerGroups>
            <sfc:Collection>'
				PRINT @Text
				SET @Text = ''
				DECLARE Level3_Cursor CURSOR
				FOR
					Select DISTINCT Col3 From @ServerList
					Where Col1 = @Level1
						and Col2 = @Level2
					ORDER BY Col3
				OPEN Level3_Cursor
				FETCH NEXT FROM Level3_Cursor INTO @Level3
				WHILE (@@fetch_status <> -1)
				BEGIN
					IF (@@fetch_status <> -2)
					BEGIN
						SET @Text = '              <sfc:Reference sml:ref="true">
                <sml:Uri>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/'+@Level1+'/ServerGroup/'+@Level2+'/ServerGroup/'+@Level3+'</sml:Uri>
              </sfc:Reference>'
						PRINT @Text
						SET @Text = ''
					END
					FETCH NEXT FROM Level3_Cursor INTO @Level3
				END
				CLOSE Level3_Cursor
				DEALLOCATE Level3_Cursor

				SET @Text = '            </sfc:Collection>
          </RegisteredServers:ServerGroups>
          <RegisteredServers:Parent>
            <sfc:Reference sml:ref="true">
              <sml:Uri>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/'+@Level1+'</sml:Uri>
            </sfc:Reference>
          </RegisteredServers:Parent>
          <RegisteredServers:Name type="string">'+@Level2+'</RegisteredServers:Name>
          <RegisteredServers:Description type="string">'+@Level2Desc+'</RegisteredServers:Description>
          <RegisteredServers:ServerType type="ServerType">DatabaseEngine</RegisteredServers:ServerType>
        </RegisteredServers:ServerGroup>
      </data>
    </document>'
				PRINT @Text
				SET @Text = ''
				DECLARE Level3_Cursor CURSOR
				FOR
					Select DISTINCT Col3 From @ServerList
					Where Col1 = @Level1
						and Col2 = @Level2
					ORDER BY Col3
				OPEN Level3_Cursor
				FETCH NEXT FROM Level3_Cursor INTO @Level3
				WHILE (@@fetch_status <> -1)
				BEGIN
					IF (@@fetch_status <> -2)
					BEGIN
						SET @Text = '    <document>
      <docinfo>
        <aliases>
          <alias>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/'+@Level1+'/ServerGroup/'+@Level2+'/ServerGroup/'+@Level3+'</alias>
        </aliases>
        <sfc:version DomainVersion="1" />
      </docinfo>
      <data>
        <RegisteredServers:ServerGroup xmlns:RegisteredServers="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08" xmlns:sml="http://schemas.serviceml.org/sml/2007/02" xmlns:xs="http://www.w3.org/2001/XMLSchema">
          <RegisteredServers:RegisteredServers>
            <sfc:Collection>'
						PRINT @Text
						SET @Text = ''
						DECLARE Svr_Cursor CURSOR
						FOR
							Select DISTINCT Col4,Col5 From @ServerList
							Where Col1 = @Level1
								and Col2 = @Level2
								and Col3 = @Level3
							ORDER BY Col4
						OPEN Svr_Cursor
						FETCH NEXT FROM Svr_Cursor INTO @Server,@Port
						WHILE (@@fetch_status <> -1)
						BEGIN
							IF (@@fetch_status <> -2)
							BEGIN
								SET @Text = '              <sfc:Reference sml:ref="true">
                <sml:Uri>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/'+@Level1+'/ServerGroup/'+@Level2+'/ServerGroup/'+@Level3+'/RegisteredServer/'+@Server+'</sml:Uri>
              </sfc:Reference>'
								PRINT @Text
								SET @Text = ''
							END
							FETCH NEXT FROM Svr_Cursor INTO @Server,@Port
						END
						CLOSE Svr_Cursor
						DEALLOCATE Svr_Cursor
						SET @Text = '            </sfc:Collection>
          </RegisteredServers:RegisteredServers>
          <RegisteredServers:Parent>
            <sfc:Reference sml:ref="true">
              <sml:Uri>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/'+@Level1+'/ServerGroup/'+@Level2+'</sml:Uri>
            </sfc:Reference>
          </RegisteredServers:Parent>
          <RegisteredServers:Name type="string">'+@Level3+'</RegisteredServers:Name>
          <RegisteredServers:Description type="string">'+@Level3Desc+'</RegisteredServers:Description>
          <RegisteredServers:ServerType type="ServerType">DatabaseEngine</RegisteredServers:ServerType>
        </RegisteredServers:ServerGroup>
      </data>
    </document>'
						PRINT @Text
						SET @Text = ''
						DECLARE Svr_Cursor CURSOR
						FOR
							Select DISTINCT Col4,Col5,Col6+' '+Col7 From @ServerList
							Where Col1 = @Level1
								and Col2 = @Level2
								and Col3 = @Level3
							ORDER BY Col4
						OPEN Svr_Cursor
						FETCH NEXT FROM Svr_Cursor INTO @Server,@Port,@Desc
						WHILE (@@fetch_status <> -1)
						BEGIN
							IF (@@fetch_status <> -2)
							BEGIN
								SET @Text = '
    <document>
      <docinfo>
        <aliases>
          <alias>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/'+@Level1+'/ServerGroup/'+@Level2+'/ServerGroup/'+@Level3+'/RegisteredServer/'+@Server+'</alias>
        </aliases>
        <sfc:version DomainVersion="1" />
      </docinfo>
      <data>
        <RegisteredServers:RegisteredServer xmlns:RegisteredServers="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08" xmlns:sml="http://schemas.serviceml.org/sml/2007/02" xmlns:xs="http://www.w3.org/2001/XMLSchema">
          <RegisteredServers:Parent>
            <sfc:Reference sml:ref="true">
              <sml:Uri>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/'+@Level1+'/ServerGroup/'+@Level2+'/ServerGroup/'+@Level3+'</sml:Uri>
            </sfc:Reference>
          </RegisteredServers:Parent>
          <RegisteredServers:Name type="string">'+@Server+'</RegisteredServers:Name>
          <RegisteredServers:Description type="string">'+@Desc+'</RegisteredServers:Description>
          <RegisteredServers:ServerName type="string">'+@Server+','+@Port+'</RegisteredServers:ServerName>
          <RegisteredServers:UseCustomConnectionColor type="boolean">false</RegisteredServers:UseCustomConnectionColor>
          <RegisteredServers:CustomConnectionColorArgb type="int">-2830136</RegisteredServers:CustomConnectionColorArgb>
          <RegisteredServers:ServerType type="ServerType">DatabaseEngine</RegisteredServers:ServerType>
          <RegisteredServers:ConnectionStringWithEncryptedPassword type="string">server='+@Server+','+@Port+CASE WHEN @Level3 !='AMER' THEN ';uid=dbasledridge;password=AQAAANCMnd8BFdERjHoAwE/Cl+sBAAAAHJfG51DxI0CuOznOmyGQ9AQAAAACAAAAAAADZgAAwAAAABAAAAAbjabuawaJLihOxGPJE7ssAAAAAASAAACgAAAAEAAAAHB9whCLd9pKfUBkbeLEzR8YAAAAe7yI/SzrtvfJDmXfhq2FDaz5hK8GtCDWFAAAAIFL2iOy6L7x41tFOf0yvgBtCE6r' ELSE ';trusted_connection=true' END + ';pooling=false;packet size=4096;multipleactiveresultsets=false</RegisteredServers:ConnectionStringWithEncryptedPassword>
          <RegisteredServers:CredentialPersistenceType type="CredentialPersistenceType">'+CASE WHEN @Level3 !='AMER' THEN 'PersistLoginNameAndPassword' ELSE 'None' END +'</RegisteredServers:CredentialPersistenceType>
        </RegisteredServers:RegisteredServer>
      </data>
    </document>'
								PRINT @Text
								SET @Text = ''
							END
							FETCH NEXT FROM Svr_Cursor INTO @Server,@Port,@Desc
						END
						CLOSE Svr_Cursor
						DEALLOCATE Svr_Cursor						
					END
					FETCH NEXT FROM Level3_Cursor INTO @Level3
				END
				CLOSE Level3_Cursor
				DEALLOCATE Level3_Cursor
			END
			FETCH NEXT FROM Level2_Cursor INTO @Level2
		END
		CLOSE Level2_Cursor
		DEALLOCATE Level2_Cursor	
	END
	FETCH NEXT FROM Level1_Cursor INTO @Level1
END
CLOSE Level1_Cursor
DEALLOCATE Level1_Cursor

SET @Text = '  </instances>
</model>'
PRINT @Text



--DECLARE @HashThis nvarchar(4000);
--SELECT @HashThis = CONVERT(nvarchar(4000),'Tigger4U');
--SELECT HashBytes('SHA1', @HashThis);
--GO
 

--select master.dbo.fn_varbintohexstr(pwdencrypt('Tigger4U'))
--,'AQAAANCMnd8BFdERjHoAwE/Cl+sBAAAAHJfG51DxI0CuOznOmyGQ9AQAAAACAAAAAAADZgAAwAAAABAAAAAbjabuawaJLihOxGPJE7ssAAAAAASAAACgAAAAEAAAAHB9whCLd9pKfUBkbeLEzR8YAAAAe7yI/SzrtvfJDmXfhq2FDaz5hK8GtCDWFAAAAIFL2iOy6L7x41tFOf0yvgBtCE6r'
--,[dbaadmin].[dbo].[dbaudf_base64_encode] (pwdencrypt('Tigger4U'))


--EncryptByKey
