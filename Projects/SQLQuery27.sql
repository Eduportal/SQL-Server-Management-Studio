						--LEVEL 4 NESTING GROUP
						DECLARE Level3_Cursor CURSOR
						FOR
							Select		DISTINCT 
										Col4 
							From		@ServerList
							Where		Col4 != '--'
								AND		Col3 = @Level3
								AND		Col2 = @Level2
								AND		Col1 = @Level1
							ORDER BY	1
						OPEN Level3_Cursor
						FETCH NEXT FROM Level3_Cursor INTO @Level4
						WHILE (@@fetch_status <> -1)
						BEGIN
							IF (@@fetch_status <> -2)
							BEGIN

								--LEVEL 1 HEADER
								SET @Text = '                <document>
												  <docinfo>
													<aliases>
													  <alias>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/'+@Level1+'/ServerGroup/'+@Level2+'/ServerGroup/'+@Level3+'/ServerGroup/'+@Level4+'</alias>
													</aliases>
													<sfc:version DomainVersion="1" />
												  </docinfo>
												  <data>
													<RegisteredServers:ServerGroup xmlns:RegisteredServers="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08" xmlns:sml="http://schemas.serviceml.org/sml/2007/02" xmlns:xs="http://www.w3.org/2001/XMLSchema">'
								PRINT @Text


								IF EXISTS (SELECT * FROM @ServerList Where Col1 = @Level1 AND Col2 = @Level2 AND Col3 = @Level3 AND Col4 = @Level4) -- ARE THERE ANY LEVEL 4 SERVERS
								BEGIN
									--LEVEL 4 SERVERS HEADER
									SET @Text = '                      <RegisteredServers:RegisteredServers>
															<sfc:Collection>'
									PRINT @Text

									--LEVEL 4 SERVERS DATA
									DECLARE Level4_Cursor CURSOR
									FOR
										Select		DISTINCT 
													Col5 
										From		@ServerList
										Where		Col4 = @Level4
											AND		Col3 = @Level3
											AND		Col2 = @Level2
											AND		Col1 = @Level1
										ORDER BY	1
									OPEN Level4_Cursor
									FETCH NEXT FROM Level4_Cursor INTO @Server
									WHILE (@@fetch_status <> -1)
									BEGIN
										IF (@@fetch_status <> -2)
										BEGIN
											SET @Text = '                          <sfc:Reference sml:ref="true">
															<sml:Uri>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/'+@Level1+'/ServerGroup/'+@Level2+'/ServerGroup/'+@Level3+'/ServerGroup/'+@Level4+'/RegisteredServer/'+@Server+'</sml:Uri>
														  </sfc:Reference>'
											PRINT @Text
										END
										FETCH NEXT FROM Level4_Cursor INTO @Server
									END
									CLOSE Level4_Cursor
									DEALLOCATE Level4_Cursor

									--LEVEL 4 SRVERS FOOTER
									SET @Text = '                        </sfc:Collection>
														  </RegisteredServers:RegisteredServers>'
									PRINT @Text
								END

								
								--LEVEL 1 FOOTER
								SET @Text = '                      <RegisteredServers:Parent>
														<sfc:Reference sml:ref="true">
														  <sml:Uri>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup</sml:Uri>
														</sfc:Reference>
													  </RegisteredServers:Parent>
													  <RegisteredServers:Name type="string">'+@Level4+'</RegisteredServers:Name>
													  <RegisteredServers:Description type="string">'+@Level4+'</RegisteredServers:Description>
													  <RegisteredServers:ServerType type="ServerType">DatabaseEngine</RegisteredServers:ServerType>
													</RegisteredServers:ServerGroup>
												  </data>
												</document>'
								PRINT @Text

								--LEVEL 1 SERVERS DATA
								DECLARE Level4_Cursor CURSOR
								FOR
									Select		DISTINCT 
												Col5,Col6,Col7,Col8,Col9
									From		@ServerList
									Where		Col4 = @Level4
										AND		Col3 = @Level3
										AND		Col2 = @Level2
										AND		Col1 = @Level1
									ORDER BY	1
								OPEN Level4_Cursor
								FETCH NEXT FROM Level4_Cursor INTO @Server,@Port,@DomainName,@Apps,@DBs
								WHILE (@@fetch_status <> -1)
								BEGIN
									IF (@@fetch_status <> -2)
									BEGIN
										SET @Desc = @Apps + ' ' + @DBs
										SET @Text = '                <document>
												  <docinfo>
													<aliases>
													  <alias>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/'+@Level1+'/ServerGroup/'+@Level2+'/ServerGroup/'+@Level3+'/ServerGroup/'+@Level4+'/RegisteredServer/'+@Server+'</alias>
													</aliases>
													<sfc:version DomainVersion="1" />
												  </docinfo>
												  <data>
													<RegisteredServers:RegisteredServer xmlns:RegisteredServers="http://schemas.microsoft.com/sqlserver/RegisteredServers/2007/08" xmlns:sfc="http://schemas.microsoft.com/sqlserver/sfc/serialization/2007/08" xmlns:sml="http://schemas.serviceml.org/sml/2007/02" xmlns:xs="http://www.w3.org/2001/XMLSchema">
													  <RegisteredServers:Parent>
														<sfc:Reference sml:ref="true">
														  <sml:Uri>/RegisteredServersStore/ServerGroup/DatabaseEngineServerGroup/ServerGroup/'+@Level1+'/ServerGroup/'+@Level2+'/ServerGroup/'+@Level3+'/ServerGroup/'+@Level4+'</sml:Uri>
														</sfc:Reference>
													  </RegisteredServers:Parent>
													  <RegisteredServers:Name type="string">'+@Server+'</RegisteredServers:Name>
													  <RegisteredServers:Description type="string">'+@Desc+'</RegisteredServers:Description>
													  <RegisteredServers:ServerName type="string">'+@Server+','+@Port+'</RegisteredServers:ServerName>
													  <RegisteredServers:UseCustomConnectionColor type="boolean">false</RegisteredServers:UseCustomConnectionColor>
													  <RegisteredServers:CustomConnectionColorArgb type="int">-986896</RegisteredServers:CustomConnectionColorArgb>
													  <RegisteredServers:ServerType type="ServerType">DatabaseEngine</RegisteredServers:ServerType>
													  <RegisteredServers:ConnectionStringWithEncryptedPassword type="string">server='+@Server+','+@Port+CASE WHEN @DomainName !='AMER' THEN ';uid='+@xDomLogin+';password='+@xDomPaswd ELSE ';trusted_connection=true' END + ';pooling=false;packet size=4096;multipleactiveresultsets=false</RegisteredServers:ConnectionStringWithEncryptedPassword>
													  <RegisteredServers:CredentialPersistenceType type="CredentialPersistenceType">'+CASE WHEN @DomainName !='AMER' THEN 'PersistLoginNameAndPassword' ELSE 'PersistLoginName' END +'</RegisteredServers:CredentialPersistenceType>
													</RegisteredServers:RegisteredServer>
												  </data>
												</document>'
										PRINT @Text
									END
									FETCH NEXT FROM Level4_Cursor INTO @Server,@Port,@DomainName,@Apps,@DBs
								END
								CLOSE Level4_Cursor
								DEALLOCATE Level4_Cursor

							END
							FETCH NEXT FROM Level3_Cursor INTO @Level4
						END
						CLOSE Level3_Cursor
						DEALLOCATE Level3_Cursor

