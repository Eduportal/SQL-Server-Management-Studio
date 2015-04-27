

SET NOCOUNT ON
SET NOEXEC OFF

DECLARE		@TableWidth		INT
		,@Output_Path		VarChar(8000)
		,@FileName		VarChar(8000)
		,@sharepointroot	VarChar(8000)
		,@sharepointsite	VarChar(8000)
		,@sharepointFolder	VarChar(8000)
		,@transcode1		VarChar(50)
		,@transcode2		VarChar(50)
		,@transcode3		VarChar(50)
		,@transcode4		VarChar(50)
		,@transcode5		VarChar(50)
		,@transcode6		VarChar(50)
		,@onclick		VarChar(8000)
		,@Link			VarChar(8000)
		,@L1			VarChar(8000)
		,@L2			VarChar(8000)
		,@L3			VarChar(8000)
		,@html1			VarChar(max)
		,@html2			VarChar(max)

SELECT		@transcode1		= '\u00252F' -- '/'
		,@transcode2		= '\u00255F' -- '_'
		,@transcode3		= '\u002520' -- ' '
		,@transcode4		= '\u00252D' -- '-'
		,@transcode5		= '\u00252E' -- '.'
		,@transcode6		= '\u0026'   -- '='
		,@sharepointroot	= '/personal/steve_ledridge_gettyimages_com/DBCollab/'
		,@sharepointsite	= 'Database Wiki/'
		,@sharepointFolder	= 'MSSQL Servers/'
		,@html1			= '<%@ Assembly Name="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c"%> <%@ Page Language="C#" Inherits="Microsoft.SharePoint.WebPartPages.WikiEditPage" MasterPageFile="~masterurl/default.master"      MainContentID="PlaceHolderMain" meta:webpartpageexpansion="full" meta:progid="SharePoint.WebPartPage.Document" %>
<%@ Import Namespace="Microsoft.SharePoint.WebPartPages" %> <%@ Register Tagprefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> <%@ Register Tagprefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %> <%@ Import Namespace="Microsoft.SharePoint" %> <%@ Assembly Name="Microsoft.Web.CommandUI, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<asp:Content ContentPlaceHolderId="PlaceHolderPageTitle" runat="server">
	<SharePoint:ProjectProperty Property="Title" runat="server"/> - 
	<SharePoint:ListItemProperty runat="server"/>
</asp:Content>
<asp:Content ContentPlaceHolderId="PlaceHolderPageImage" runat="server">
	<SharePoint:AlphaImage ID=onetidtpweb1 Src="/_layouts/15/images/wiki.png?rev=37" Width=145 Height=54 Alt="" Runat="server"/>
</asp:Content>
<asp:Content ContentPlaceHolderId="PlaceHolderAdditionalPageHead" runat="server">
	<meta name="CollaborationServer" content="SharePoint Team Web Site" />
	<SharePoint:ScriptBlock runat="server">var navBarHelpOverrideKey = "WSSEndUser";</SharePoint:ScriptBlock>
	<SharePoint:RssLink runat="server"/>
</asp:Content>
<asp:Content ContentPlaceHolderId="PlaceHolderMiniConsole" runat="server">
	<SharePoint:FormComponent TemplateName="WikiMiniConsole" ControlMode="Display" runat="server" id="WikiMiniConsole"/>
</asp:Content>
<asp:Content ContentPlaceHolderId="PlaceHolderLeftActions" runat="server">
	<SharePoint:RecentChangesMenu runat="server" id="RecentChanges"/>
</asp:Content>
<asp:Content ContentPlaceHolderId="PlaceHolderMain" runat="server">
	<span id="wikiPageNameDisplay" style="display: none;" runat="server">
		<SharePoint:ListItemProperty runat="server"/>
	</span>
	<span style="display:none;" id="wikiPageNameEdit" runat="server">
		<asp:TextBox id="wikiPageNameEditTextBox" runat="server"/>
	</span>
	<SharePoint:VersionedPlaceHolder UIVersion="4" runat="server">
		<SharePoint:SPRibbonButton
			id="btnWikiEdit"
			RibbonCommand="Ribbon.WikiPageTab.EditAndCheckout.SaveEdit.Menu.SaveEdit.Edit"
			runat="server"
			Text="edit"/>
		<SharePoint:SPRibbonButton
			id="btnWikiSave"
			RibbonCommand="Ribbon.WikiPageTab.EditAndCheckout.SaveEdit.Menu.SaveEdit.SaveAndStop"
			runat="server"
			Text="edit"/>
		<SharePoint:SPRibbonButton
			id="btnWikiRevert"
			RibbonCommand="Ribbon.WikiPageTab.EditAndCheckout.SaveEdit.Menu.SaveEdit.Revert"
			runat="server"
			Text="Revert"/>
	</SharePoint:VersionedPlaceHolder>
	<SharePoint:EmbeddedFormField id="WikiField" FieldName="WikiField" ControlMode="Display" runat="server">
		<div class="ExternalClass4E7EAB8DB61149D6BBBCA9AC7C445ABF">
			<table id="layoutsTable" style="width&#58;100%;">
				<tbody>
					<tr style="vertical-align&#58;top;">
						<td style="width&#58;100%;">
							<div class="ms-rte-layoutszone-outer" style="width&#58;100%;"><div class="ms-rte-layoutszone-inner" role="textbox" aria-autocomplete="both" aria-haspopup="true" aria-multiline="true">
'


		,@html2		= '
							</div>
						</td>
					</tr>
				</tbody>
			</table>
			<span id="layoutsData" style="display&#58;none;">false,false,1</span>
		</div>
	</SharePoint:EmbeddedFormField>
	<WebPartPages:WebPartZone runat="server" ID="Bottom" CssClass="ms-hide" Title="loc:Bottom"><ZoneTemplate></ZoneTemplate></WebPartPages:WebPartZone>
</asp:Content>'



		,@TableWidth		= 3
		,@FileName		= 'MSSQL Servers.aspx'
		,@Output_Path		= '\\'+REPLACE(@@ServerName,'\'+@@ServiceName,'')+'\'+REPLACE(@@ServerName,'\','$')+'_dbasql\dba_reports\wiki\MSSQL Servers'

		,@L1			= '" class="ms-missinglink" href="'+@SharepointRoot+@SharepointSite+@sharepointFolder
		,@L2			= '.aspx"onclick="OpenPopUpPage('''
					+ REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
						@SharepointRoot
						,'/',@transcode1)
						,'_',@transcode2)
						,' ',@transcode3)
						,'-',@transcode4)
						,'.',@transcode5)
						,'=',@transcode6)
					+ '_layouts\u002f15\u002fWikiRedirect.aspx?url='
					+ REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
						@SharepointRoot+@SharepointSite+@sharepointFolder
						,'/',@transcode1)
						,'_',@transcode2)
						,' ',@transcode3)
						,'-',@transcode4)
						,'.',@transcode5)
						,'=',@transcode6)
		
		,@L3			= '\u00252Easpx\u0026Source='
					+ REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
						@SharepointRoot
						,'/',@transcode1)
						,'_',@transcode2)
						,' ',@transcode3)
						,'-',@transcode4)
						,'.',@transcode5)
						,'=',@transcode6)
					+ '\u00255Fvti\u00255Fbin\u00252Fwebpartpages\u00252Easmx''); return false;">'

-- START THE FILE AS AN EMPTY FILE
SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write] ('',@Output_Path+'\'+@FileName,0,0)

;WITH		[Set_All]
		AS
		(
		SELECT		row
				,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
				  dbaadmin.dbo.dbaudf_Concatenate('<a id="'
									+ '$6$$5$$4$'+LinkName
									+ '|'
									+ LinkName
									+ '$1$'
									+ '$5$$4$'+LinkName
									+ '$2$'
									+ '$5$$4$'+LinkName
									+ '$3$'
									+ LinkName
									+ '</a>')
									,'$1$',@L1)
									,'$2$',@L2)
									,'$3$',@L3)
									,'$4$','')
									,'$5$','MSSQL SERVERS - ')
									,'$6$',@sharepointFolder) [LinkSet]
				,count(LinkName) [SetSize]
		FROM		(
				SELECT		TOP 100 PERCENT
						((rn-1)/@TableWidth+1) row
						,rn
						,LinkName
				FROM		(
						SELECT		row_number()over(order by LinkName) rn
								,LinkName
						FROM		(
								SELECT	'ALL' LinkName
								UNION ALL
								SELECT	'ACTIVE'
								UNION ALL
								SELECT	'NOT ACTIVE'
								)Data
						) Data
				WHERE		nullif(LinkName,'') IS NOT NULL
				order by	LinkName
				)Data
		GROUP BY	row
		)
		,[Set_Domain]
		AS
		(
		SELECT		row
				,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
				  dbaadmin.dbo.dbaudf_Concatenate('<a id="'
									+ @sharepointFolder
									+ '$6$$5$$4$'+LinkName
									+ '|'
									+ LinkName
									+ '$1$'
									+ '$5$$4$'+LinkName
									+ '$2$'
									+ '$5$$4$'+LinkName
									+ '$3$'
									+ LinkName
									+ '</a>')
									,'$1$',@L1)
									,'$2$',@L2)
									,'$3$',@L3)
									,'$4$','DOMAIN ')
									,'$5$','MSSQL SERVERS - ')
									,'$6$',@sharepointFolder) [LinkSet]
				,count(LinkName) [SetSize]
		FROM		(
				SELECT		TOP 100 PERCENT
						((rn-1)/@TableWidth+1) row
						,rn
						,LinkName
				FROM		(
						SELECT		row_number()over(order by LinkName) rn
								,LinkName
						FROM		(
								SELECT	DISTINCT
									UPPER(DomainName) LinkName
								FROM	[dbacentral].[dbo].[ServerInfo]
								WHERE	Active = 'y'
								)Data
						) Data
				WHERE		nullif(LinkName,'') IS NOT NULL
				order by	LinkName
				)Data
		GROUP BY	row
		)
		,[Set_SQLVersion]
		AS
		(
		SELECT		row
				,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
				  dbaadmin.dbo.dbaudf_Concatenate('<a id="'
									+ '$6$$5$$4$'+LinkName
									+ '|'
									+ LinkName
									+ '$1$'
									+ '$5$$4$'+LinkName
									+ '$2$'
									+ '$5$$4$'+LinkName
									+ '$3$'
									+ LinkName
									+ '</a>')
									,'$1$',@L1)
									,'$2$',@L2)
									,'$3$',@L3)
									,'$4$','SQL VERSION ')
									,'$5$','MSSQL SERVERS - ')
									,'$6$',@sharepointFolder) [LinkSet]
				,count(LinkName) [SetSize]
		FROM		(
				SELECT		TOP 100 PERCENT
						((rn-1)/@TableWidth+1) row
						,rn
						,LinkName
				FROM		(
						SELECT		row_number()over(order by LinkName) rn
								,LinkName
						FROM		(
								SELECT	DISTINCT
									UPPER(SQL_Version) LinkName
								FROM	[dbacentral].[dbo].[ServerInfo]
								WHERE	Active = 'y'
								)Data
						) Data
				WHERE		nullif(LinkName,'') IS NOT NULL
				order by	LinkName
				)Data
		GROUP BY	row
		)
		,[Set_Environment]
		AS
		(
		SELECT		row
				,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
				  dbaadmin.dbo.dbaudf_Concatenate('<a id="'
									+ '$6$$5$$4$'+LinkName
									+ '|'
									+ LinkName
									+ '$1$'
									+ '$5$$4$'+LinkName
									+ '$2$'
									+ '$5$$4$'+LinkName
									+ '$3$'
									+ LinkName
									+ '</a>')
									,'$1$',@L1)
									,'$2$',@L2)
									,'$3$',@L3)
									,'$4$','ENVIRONMENT ')
									,'$5$','MSSQL SERVERS - ')
									,'$6$',@sharepointFolder) [LinkSet]
				,count(LinkName) [SetSize]
		FROM		(
				SELECT		TOP 100 PERCENT
						((rn-1)/@TableWidth+1) row
						,rn
						,LinkName
				FROM		(
						SELECT		row_number()over(order by LinkName) rn
								,LinkName
						FROM		(
								SELECT	DISTINCT
									UPPER(SQLEnv) LinkName
								FROM	[dbacentral].[dbo].[ServerInfo]
								WHERE	Active = 'y'
								)Data
						) Data
				WHERE		nullif(LinkName,'') IS NOT NULL
				order by	LinkName
				)Data
		GROUP BY	row
		)
		,[Set_App]
		AS
		(
		SELECT		row
				,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
				  dbaadmin.dbo.dbaudf_Concatenate('<a id="'
									+ '$6$$5$$4$'+LinkName
									+ '|'
									+ LinkName
									+ '$1$'
									+ '$5$$4$'+LinkName
									+ '$2$'
									+ '$5$$4$'+LinkName
									+ '$3$'
									+ LinkName
									+ '</a>')
									,'$1$',@L1)
									,'$2$',@L2)
									,'$3$',@L3)
									,'$4$','APPLICATION ')
									,'$5$','MSSQL SERVERS - ')
									,'$6$',@sharepointFolder) [LinkSet]
				,count(LinkName) [SetSize]
		FROM		(
				SELECT		TOP 100 PERCENT
						((rn-1)/@TableWidth+1) row
						,rn
						,LinkName
				FROM		(
						SELECT		row_number()over(order by LinkName) rn
								,LinkName
						FROM		(
								SELECT	DISTINCT
									REPLACE(UPPER(REPLACE(Appl_desc,',','-')),'/','-') LinkName
								FROM	[dbacentral].[dbo].[DBA_DBInfo]
								WHERE	SQLName IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE	Active = 'y')
								  AND	NULLIF(Appl_desc,'') IS NOT NULL
								)Data
						) Data
				WHERE		nullif(LinkName,'') IS NOT NULL
				order by	LinkName
				)Data
		GROUP BY	row
		)
		,[Set_DB]
		AS
		(
		SELECT		row
				,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
				  dbaadmin.dbo.dbaudf_Concatenate('<a id="'
									+ '$5$$4$'+LinkName
									+ '|'
									+ LinkName
									+ '$1$'
									+ '$4$'+LinkName
									+ '$2$'
									+ '$4$'+LinkName
									+ '$3$'
									+ LinkName
									+ '</a>')
									,'$1$',@L1)
									,'$2$',@L2)
									,'$3$',@L3)
									,'$4$','MSSQL SERVERS - DATABASE ')
									,'$5$',@sharepointFolder) [LinkSet]
				,count(LinkName) [SetSize]
		FROM		(
				SELECT		TOP 100 PERCENT
						((rn-1)/@TableWidth+1) row
						,rn
						,LinkName
				FROM		(
						SELECT		row_number()over(order by LinkName) rn
								,LinkName
						FROM		(
								SELECT	DISTINCT
									UPPER(COALESCE(T2.DBName_Cleaned,T3.DBName_Cleaned,T1.DBName)) LinkName
								FROM	[dbacentral].[dbo].[DBA_DBInfo] T1
								LEFT 
								JOIN	[dbacentral].[dbo].[DBA_DBNameCleaner] T2
								  ON	T1.DBName Like T2.DBName
								LEFT
								JOIN	(
									SELECT	DISTINCT
										[DBName_Cleaned]+'%' [DBName]
										,[DBName_Cleaned]
									FROM	[dbacentral].[dbo].[DBA_DBNameCleaner]
									) T3
								  ON	T1.DBName Like T3.DBName
								WHERE	SQLName IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE	Active = 'y')
								)Data
						) Data
				WHERE		nullif(LinkName,'') IS NOT NULL
				order by	LinkName
				)Data
		GROUP BY	row
		
		)


SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write] ([OutputRow],@Output_Path+'\'+@FileName,1,1)
--SELECT *
FROM	(
SELECT	@HTML1 + '
								<div style="text-align&#58;center;">
									<span style="color&#58;#ba44fd;font-family&#58;''segoe ui semilight'', ''segoe ui'', segoe, tahoma, helvetica, arial, sans-serif;font-size&#58;1.46em;line-height&#58;1.4;">
										<span class="ms-rteForeColor-4">
											<strong>SERVER AND DATABASE LOOKUP TOOL</strong>
										</span>
										<br>
									</span>
								</div>
								<div>
								   <a href="http://ecommops/SqlDbaDocs/SQLLookup.aspx">SQL &#160;Server and Database Lookups</a><br/></div>
								<div>
								   <br/>
								</div>
								<div>This lookup tool will identify the current deployment of all databases on all servers in all environments. You can search for a database name and it will tell you which servers it exists on in each environment or you can search for a server to Identify what databases are on it. The server and database fields both accept partial names for wider searches. The Server name field also accepts cluster node names.</div>
								<br>
								<br>
								<br>
								<div style="text-align&#58;center;">
									<span style="color&#58;#ba44fd;font-family&#58;''segoe ui semilight'', ''segoe ui'', segoe, tahoma, helvetica, arial, sans-serif;font-size&#58;1.46em;line-height&#58;1.4;">
										<span class="ms-rteForeColor-4">
											<strong>LIST SERVERS BY</strong>
										</span>
										<br>
									</span>
								</div>
								<br>' [OutputRow]
UNION ALL
SELECT	'<table class="ms-rteTable-default ">'
UNION ALL
SELECT	'     <tbody>'
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"></td></tr>'
-------------------------------------------------------------------------------------
UNION ALL
SELECT	'          <tr><td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;">'+REPLACE([LinkSet],',','</td><td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;">')+'</td>'
		+ ISNULL(REPLICATE('<td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;"></td>',@TableWidth-[SetSize]),'')
		+'</tr>'
FROM		[Set_All]
---------------------------------------------------------------------------------------
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"></td></tr>'
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"><h2>DOMAIN</h2></td></tr>'
UNION ALL
SELECT	'          <tr><td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;">'+REPLACE([LinkSet],',','</td><td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;">')+'</td>'
		+ ISNULL(REPLICATE('<td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;"></td>',@TableWidth-[SetSize]),'')
		+'</tr>'
FROM		[Set_Domain]
---------------------------------------------------------------------------------------
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"></td></tr>'
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"><h2>SQL VERSION</h2></td></tr>'
UNION ALL
SELECT	'          <tr><td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;">'+REPLACE([LinkSet],',','</td><td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;">')+'</td>'
		+ ISNULL(REPLICATE('<td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;"></td>',@TableWidth-[SetSize]),'')
		+'</tr>'
FROM		[Set_SQLVersion]
---------------------------------------------------------------------------------------
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"></td></tr>'
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"><h2>ENVIRONMENT</h2></td></tr>'
UNION ALL
SELECT	'          <tr><td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;">'+REPLACE([LinkSet],',','</td><td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;">')+'</td>'
		+ ISNULL(REPLICATE('<td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;"></td>',@TableWidth-[SetSize]),'')
		+'</tr>'
FROM		[Set_Environment]
---------------------------------------------------------------------------------------
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"></td></tr>'
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"><h2>APPLICATIONS</h2></td></tr>'
UNION ALL
SELECT	'          <tr><td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;">'+REPLACE([LinkSet],',','</td><td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;">')+'</td>'
		+ ISNULL(REPLICATE('<td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;"></td>',@TableWidth-[SetSize]),'')
		+'</tr>'
FROM		[Set_App]
---------------------------------------------------------------------------------------
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"></td></tr>'
UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"><h2>DATABASES</h2></td></tr>'
UNION ALL
SELECT	'          <tr><td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;">'+REPLACE([LinkSet],',','</td><td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;">')+'</td>'
		+ ISNULL(REPLICATE('<td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;"></td>',@TableWidth-[SetSize]),'')
		+'</tr>'
FROM		[Set_DB]


UNION ALL
SELECT	'          <tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"></td></tr>'
UNION ALL
SELECT	'     </tbody>'
UNION ALL
SELECT	'</table>'
UNION ALL
SELECT	@HTML2

) Data


----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
--
--		ACTIVE/NOT ACTIVE/ALL SETS
--
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------


SELECT		@TableWidth		= 5

-- START THE FILE AS AN EMPTY FILE
SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write] (@html1 +CHAR(13)+CHAR(10)+'<table border="1" cellpadding="0" cellspacing="0" bordercolor="#111111" width="100%" id="AutoNumber1" height="150" style="border-collapse&#58;collapse;"><tbody><tr><td rowspan="1" colspan="'
							+CAST(@TableWidth AS VARCHAR(2))+'"><h2>'+setname+'</h2></td></tr>'
							,@Output_Path+'\'+SetName+'.aspx'
							,0,0)
FROM	(
	SELECT	'MSSQL Servers - ACTIVE' SetName
	UNION ALL
	SELECT	'MSSQL Servers - NOT ACTIVE'
	UNION ALL
	SELECT	'MSSQL Servers - ALL'
	) Sets



;WITH		[Servers_Active]
		AS
		(
		SELECT		SetName
				,row
				,REPLACE(REPLACE(REPLACE(REPLACE(
				  dbaadmin.dbo.dbaudf_ConcatenateUnique('<a id="'
									+ @sharepointFolder
									+ REPLACE(LinkName,'\','$')
									+ '|'
									+ LinkName
									+ '$1$'
									+ REPLACE(LinkName,'\','$')
									+ '$2$'
									+ REPLACE(LinkName,'\','$')
									+ '$3$'
									+ LinkName
									+ '</a>')
									,'$1$',@L1)
									,'$2$',@L2)
									,'$3$',@L3)
									,'$4$','') [LinkSet]
				,count(LinkName) [SetSize]
		FROM		(
				SELECT		TOP 100 PERCENT
						SetName
						,((rn-1)/@TableWidth+1) row
						,rn
						,LinkName
				FROM		(
						SELECT		SetName
								,row_number()over(Partition by SetName order by LinkName) rn
								,LinkName
						FROM		(
								SELECT	DISTINCT
									'MSSQL Servers - ACTIVE' SetName
									,UPPER(SQLName) LinkName
								FROM	[dbacentral].[dbo].[ServerInfo]
								WHERE	Active = 'y'
								UNION ALL
								SELECT	DISTINCT
									'MSSQL Servers - NOT ACTIVE' SetName
									,UPPER(SQLName) LinkName
								FROM	[dbacentral].[dbo].[ServerInfo]
								WHERE	Active != 'y'
								UNION ALL
								SELECT	DISTINCT
									'MSSQL Servers - ALL' SetName
									,UPPER(SQLName) LinkName
								FROM	[dbacentral].[dbo].[ServerInfo]
								)Data
						) Data
				WHERE		nullif(LinkName,'') IS NOT NULL
				order by	SetName,LinkName
				)Data
		GROUP BY	setname,row
		)

SELECT		[DBAadmin].[dbo].[dbaudf_FileAccess_Write] ([OutputRow],@Output_Path+'\'+SetName+'.aspx',1,1)
--SELECT *
FROM		(
		SELECT		SetName
				,'          <tr><td>'+REPLACE([LinkSet],',','</td><td>')+'</td>'
				+ ISNULL(REPLICATE('<td></td>',@TableWidth-[SetSize]),'')
				+'</tr>' [OutputRow]
		FROM		[Servers_Active]
		) Data


-- FINISH WRITING TO THE FILES
SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write] ('<tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"></td></tr></tbody></table>'+CHAR(13)+CHAR(10)+@html2
							,@Output_Path+'\'+SetName+'.aspx'
							,1,1)
FROM	(
	SELECT	'MSSQL Servers - ACTIVE' SetName
	UNION ALL
	SELECT	'MSSQL Servers - NOT ACTIVE'
	UNION ALL
	SELECT	'MSSQL Servers - ALL'
	) Sets


----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
--
--		DOMAIN SETS
--
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

SELECT		@TableWidth		= 5

-- START THE FILE AS AN EMPTY FILE
SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write] (@html1 +CHAR(13)+CHAR(10)+'<table border="1" cellpadding="0" cellspacing="0" bordercolor="#111111" width="100%" id="AutoNumber1" height="150" style="border-collapse&#58;collapse;"><tbody><tr><td rowspan="1" colspan="'
							+CAST(@TableWidth AS VARCHAR(2))+'"><h2>'+setname+'</h2></td></tr>'
							,@Output_Path+'\'+SetName+'.aspx'
							,0,0)
FROM	(
	SELECT	DISTINCT
		'MSSQL SERVERS - DOMAIN '+ UPPER(DomainName) SetName
	FROM	[dbacentral].[dbo].[ServerInfo]
	WHERE	Active = 'y'
	) Sets



;WITH		[Servers_Active]
		AS
		(
		SELECT		SetName
				,row
				,REPLACE(REPLACE(REPLACE(REPLACE(
				  dbaadmin.dbo.dbaudf_ConcatenateUnique('<a id="'
									+ @sharepointFolder
									+ REPLACE(LinkName,'\','$')
									+ '|'
									+ LinkName
									+ '$1$'
									+ REPLACE(LinkName,'\','$')
									+ '$2$'
									+ REPLACE(LinkName,'\','$')
									+ '$3$'
									+ LinkName
									+ '</a>')
									,'$1$',@L1)
									,'$2$',@L2)
									,'$3$',@L3)
									,'$4$','') [LinkSet]
				,count(LinkName) [SetSize]
		FROM		(
				SELECT		TOP 100 PERCENT
						SetName
						,((rn-1)/@TableWidth+1) row
						,rn
						,LinkName
				FROM		(
						SELECT		SetName
								,row_number()over(Partition by SetName order by LinkName) rn
								,LinkName
						FROM		(
								SELECT	DISTINCT
									'MSSQL SERVERS - DOMAIN '+ UPPER(DomainName) SetName
									,UPPER(SQLName) LinkName
								FROM	[dbacentral].[dbo].[ServerInfo]
								WHERE	Active = 'y'
								)Data
						) Data
				WHERE		nullif(LinkName,'') IS NOT NULL
				order by	SetName,LinkName
				)Data
		GROUP BY	setname,row
		)

SELECT		[DBAadmin].[dbo].[dbaudf_FileAccess_Write] ([OutputRow],@Output_Path+'\'+SetName+'.aspx',1,1)
--SELECT *
FROM		(
		SELECT		SetName
				,'          <tr><td>'+REPLACE([LinkSet],',','</td><td>')+'</td>'
				+ ISNULL(REPLICATE('<td></td>',@TableWidth-[SetSize]),'')
				+'</tr>' [OutputRow]
		FROM		[Servers_Active]
		) Data


-- FINISH WRITING TO THE FILES
SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write] ('<tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"></td></tr></tbody></table>'+CHAR(13)+CHAR(10)+@html2
							,@Output_Path+'\'+SetName+'.aspx'
							,1,1)
FROM	(
	SELECT	DISTINCT
		'MSSQL SERVERS - DOMAIN '+ UPPER(DomainName) SetName
	FROM	[dbacentral].[dbo].[ServerInfo]
	WHERE	Active = 'y'
	) Sets


----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
--
--		SQL VERSION SETS
--
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------




SELECT		@TableWidth		= 5

-- START THE FILE AS AN EMPTY FILE
SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write] (@html1 +CHAR(13)+CHAR(10)+'<table border="1" cellpadding="0" cellspacing="0" bordercolor="#111111" width="100%" id="AutoNumber1" height="150" style="border-collapse&#58;collapse;"><tbody><tr><td rowspan="1" colspan="'
							+CAST(@TableWidth AS VARCHAR(2))+'"><h2>'+setname+'</h2></td></tr>'
							,@Output_Path+'\'+SetName+'.aspx'
							,0,0)
FROM	(
	SELECT	DISTINCT
		'MSSQL SERVERS - SQL VERSION '+ UPPER(SQL_Version) SetName
	FROM	[dbacentral].[dbo].[ServerInfo]
	WHERE	Active = 'y'
	) Sets



;WITH		[Servers_Active]
		AS
		(
		SELECT		SetName
				,row
				,REPLACE(REPLACE(REPLACE(REPLACE(
				  dbaadmin.dbo.dbaudf_ConcatenateUnique('<a id="'
									+ @sharepointFolder
									+ REPLACE(LinkName,'\','$')
									+ '|'
									+ LinkName
									+ '$1$'
									+ REPLACE(LinkName,'\','$')
									+ '$2$'
									+ REPLACE(LinkName,'\','$')
									+ '$3$'
									+ LinkName
									+ '</a>')
									,'$1$',@L1)
									,'$2$',@L2)
									,'$3$',@L3)
									,'$4$','') [LinkSet]
				,count(LinkName) [SetSize]
		FROM		(
				SELECT		TOP 100 PERCENT
						SetName
						,((rn-1)/@TableWidth+1) row
						,rn
						,LinkName
				FROM		(
						SELECT		SetName
								,row_number()over(Partition by SetName order by LinkName) rn
								,LinkName
						FROM		(
								SELECT	DISTINCT
									'MSSQL SERVERS - SQL VERSION '+ UPPER(SQL_Version) SetName
									,UPPER(SQLName) LinkName
								FROM	[dbacentral].[dbo].[ServerInfo]
								WHERE	Active = 'y'
								)Data
						) Data
				WHERE		nullif(LinkName,'') IS NOT NULL
				order by	SetName,LinkName
				)Data
		GROUP BY	setname,row
		)

SELECT		[DBAadmin].[dbo].[dbaudf_FileAccess_Write] ([OutputRow],@Output_Path+'\'+SetName+'.aspx',1,1)
--SELECT *
FROM		(
		SELECT		SetName
				,'          <tr><td>'+REPLACE([LinkSet],',','</td><td>')+'</td>'
				+ ISNULL(REPLICATE('<td></td>',@TableWidth-[SetSize]),'')
				+'</tr>' [OutputRow]
		FROM		[Servers_Active]
		) Data


-- FINISH WRITING TO THE FILES
SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write] ('<tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"></td></tr></tbody></table>'+CHAR(13)+CHAR(10)+@html2
							,@Output_Path+'\'+SetName+'.aspx'
							,1,1)
FROM	(
	SELECT	DISTINCT
		'MSSQL SERVERS - SQL VERSION '+ UPPER(SQL_Version) SetName
	FROM	[dbacentral].[dbo].[ServerInfo]
	WHERE	Active = 'y'
	) Sets


----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
--
--		ENVIRONMENT SETS
--
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------



SELECT		@TableWidth		= 5

-- START THE FILE AS AN EMPTY FILE
SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write] (@html1 +CHAR(13)+CHAR(10)+'<table border="1" cellpadding="0" cellspacing="0" bordercolor="#111111" width="100%" id="AutoNumber1" height="150" style="border-collapse&#58;collapse;"><tbody><tr><td rowspan="1" colspan="'
							+CAST(@TableWidth AS VARCHAR(2))+'"><h2>'+setname+'</h2></td></tr>'
							,@Output_Path+'\'+SetName+'.aspx'
							,0,0)
FROM	(
	SELECT	DISTINCT
		'MSSQL SERVERS - ENVIRONMENT '+ UPPER(SQLEnv) SetName
	FROM	[dbacentral].[dbo].[ServerInfo]
	WHERE	Active = 'y'
	) Sets



;WITH		[Servers_Active]
		AS
		(
		SELECT		SetName
				,row
				,REPLACE(REPLACE(REPLACE(REPLACE(
				  dbaadmin.dbo.dbaudf_ConcatenateUnique('<a id="'
									+ @sharepointFolder
									+ REPLACE(LinkName,'\','$')
									+ '|'
									+ LinkName
									+ '$1$'
									+ REPLACE(LinkName,'\','$')
									+ '$2$'
									+ REPLACE(LinkName,'\','$')
									+ '$3$'
									+ LinkName
									+ '</a>')
									,'$1$',@L1)
									,'$2$',@L2)
									,'$3$',@L3)
									,'$4$','') [LinkSet]
				,count(LinkName) [SetSize]
		FROM		(
				SELECT		TOP 100 PERCENT
						SetName
						,((rn-1)/@TableWidth+1) row
						,rn
						,LinkName
				FROM		(
						SELECT		SetName
								,row_number()over(Partition by SetName order by LinkName) rn
								,LinkName
						FROM		(
								SELECT	DISTINCT
									'MSSQL SERVERS - ENVIRONMENT '+ UPPER(SQLEnv) SetName
									,UPPER(SQLName) LinkName
								FROM	[dbacentral].[dbo].[ServerInfo]
								WHERE	Active = 'y'
								)Data
						) Data
				WHERE		nullif(LinkName,'') IS NOT NULL
				order by	SetName,LinkName
				)Data
		GROUP BY	setname,row
		)

SELECT		[DBAadmin].[dbo].[dbaudf_FileAccess_Write] ([OutputRow],@Output_Path+'\'+SetName+'.aspx',1,1)
--SELECT *
FROM		(
		SELECT		SetName
				,'          <tr><td>'+REPLACE([LinkSet],',','</td><td>')+'</td>'
				+ ISNULL(REPLICATE('<td></td>',@TableWidth-[SetSize]),'')
				+'</tr>' [OutputRow]
		FROM		[Servers_Active]
		) Data



-- FINISH WRITING TO THE FILES
SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write] ('<tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"></td></tr></tbody></table>'+CHAR(13)+CHAR(10)+@html2
							,@Output_Path+'\'+SetName+'.aspx'
							,1,1)
FROM	(
	SELECT	DISTINCT
		'MSSQL SERVERS - ENVIRONMENT '+ UPPER(SQLEnv) SetName
	FROM	[dbacentral].[dbo].[ServerInfo]
	WHERE	Active = 'y'
	) Sets


----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
--
--		APPLICATION SETS
--
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------


	

SELECT		@TableWidth		= 5

-- START THE FILE AS AN EMPTY FILE
SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write] (@html1 +CHAR(13)+CHAR(10)+'<table border="1" cellpadding="0" cellspacing="0" bordercolor="#111111" width="100%" id="AutoNumber1" height="150" style="border-collapse&#58;collapse;"><tbody><tr><td rowspan="1" colspan="'
							+CAST(@TableWidth AS VARCHAR(2))+'"><h2>'+setname+'</h2></td></tr>'
							,@Output_Path+'\'+SetName+'.aspx'
							,0,0)
FROM	(
	SELECT	DISTINCT
		'MSSQL SERVERS - APPLICATION '+ REPLACE(REPLACE(UPPER(Appl_desc),'/','-'),',','-') SetName
	FROM	[dbacentral].[dbo].[DBA_DBInfo]
	WHERE	SQLName IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE	Active = 'y')
	  AND	NULLIF(Appl_desc,'') IS NOT NULL
	) Sets



;WITH		[Servers_Active]
		AS
		(
		SELECT		SetName
				,row
				,REPLACE(REPLACE(REPLACE(REPLACE(
				  dbaadmin.dbo.dbaudf_ConcatenateUnique('<a id="'
									+ @sharepointFolder
									+ REPLACE(LinkName,'\','$')
									+ '|'
									+ LinkName
									+ '$1$'
									+ REPLACE(LinkName,'\','$')
									+ '$2$'
									+ REPLACE(LinkName,'\','$')
									+ '$3$'
									+ LinkName
									+ '</a>')
									,'$1$',@L1)
									,'$2$',@L2)
									,'$3$',@L3)
									,'$4$','') [LinkSet]
				,count(LinkName) [SetSize]
		FROM		(
				SELECT		TOP 100 PERCENT
						SetName
						,((rn-1)/@TableWidth+1) row
						,rn
						,LinkName
				FROM		(
						SELECT		SetName
								,row_number()over(Partition by SetName order by LinkName) rn
								,LinkName
						FROM		(
								SELECT	DISTINCT
									'MSSQL SERVERS - APPLICATION '+ REPLACE(REPLACE(UPPER(Appl_desc),'/','-'),',','-') SetName
									,UPPER(SQLName) LinkName
								FROM	[dbacentral].[dbo].[DBA_DBInfo]
								WHERE	SQLName IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE	Active = 'y')
								  AND	NULLIF(Appl_desc,'') IS NOT NULL
								--ORDER BY 1,2
								)Data
						) Data
				WHERE		nullif(LinkName,'') IS NOT NULL
				order by	SetName,LinkName
				)Data
		GROUP BY	setname,row
		)

SELECT		[DBAadmin].[dbo].[dbaudf_FileAccess_Write] ([OutputRow],@Output_Path+'\'+SetName+'.aspx',1,1)
--SELECT *
FROM		(
		SELECT		SetName
				,'          <tr><td>'+REPLACE([LinkSet],',','</td><td>')+'</td>'
				+ ISNULL(REPLICATE('<td></td>',@TableWidth-[SetSize]),'')
				+'</tr>' [OutputRow]
		FROM		[Servers_Active]
		) Data


-- FINISH WRITING TO THE FILES
SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write] ('<tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"></td></tr></tbody></table>'+CHAR(13)+CHAR(10)+@html2
							,@Output_Path+'\'+SetName+'.aspx'
							,1,1)
FROM	(
	SELECT	DISTINCT
		'MSSQL SERVERS - APPLICATION '+ REPLACE(REPLACE(UPPER(Appl_desc),'/','-'),',','-') SetName
	FROM	[dbacentral].[dbo].[DBA_DBInfo]
	WHERE	SQLName IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE	Active = 'y')
	  AND	NULLIF(Appl_desc,'') IS NOT NULL
	) Sets


----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
--
--		DATABASE SETS
--
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------


	

SELECT		@TableWidth		= 5

-- START THE FILE AS AN EMPTY FILE
SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write] (@html1 +CHAR(13)+CHAR(10)+'<table border="1" cellpadding="0" cellspacing="0" bordercolor="#111111" width="100%" id="AutoNumber1" height="150" style="border-collapse&#58;collapse;"><tbody><tr><td rowspan="1" colspan="'
							+CAST(@TableWidth AS VARCHAR(2))+'"><h2>'+setname+'</h2></td></tr>'
							,@Output_Path+'\'+SetName+'.aspx'
							,0,0)
FROM	(
	SELECT	DISTINCT
		'MSSQL SERVERS - DATABASE '+ UPPER(COALESCE(T2.DBName_Cleaned,T3.DBName_Cleaned,T1.DBName)) SetName
	FROM	[dbacentral].[dbo].[DBA_DBInfo] T1
	LEFT 
	JOIN	[dbacentral].[dbo].[DBA_DBNameCleaner] T2
		ON	T1.DBName Like T2.DBName
	LEFT
	JOIN	(
		SELECT	DISTINCT
			[DBName_Cleaned]+'%' [DBName]
			,[DBName_Cleaned]
		FROM	[dbacentral].[dbo].[DBA_DBNameCleaner]
		) T3
		ON	T1.DBName Like T3.DBName
	WHERE	SQLName IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE	Active = 'y')
	--ORDER BY 1
	) Sets



;WITH		[Servers_Active]
		AS
		(
		SELECT		SetName
				,row
				,REPLACE(REPLACE(REPLACE(REPLACE(
				  dbaadmin.dbo.dbaudf_ConcatenateUnique('<a id="'
									+ @sharepointFolder
									+ REPLACE(LinkName,'\','$')
									+ '|'
									+ LinkName
									+ '$1$'
									+ REPLACE(LinkName,'\','$')
									+ '$2$'
									+ REPLACE(LinkName,'\','$')
									+ '$3$'
									+ LinkName
									+ '</a>')
									,'$1$',@L1)
									,'$2$',@L2)
									,'$3$',@L3)
									,'$4$','') [LinkSet]
				,count(LinkName) [SetSize]
		FROM		(
				SELECT		TOP 100 PERCENT
						SetName
						,((rn-1)/@TableWidth+1) row
						,rn
						,LinkName
				FROM		(
						SELECT		SetName
								,row_number()over(Partition by SetName order by LinkName) rn
								,LinkName
						FROM		(
								SELECT	DISTINCT
									'MSSQL SERVERS - DATABASE '+ UPPER(COALESCE(T2.DBName_Cleaned,T3.DBName_Cleaned,T1.DBName)) SetName
									,UPPER(SQLName) LinkName
								FROM	[dbacentral].[dbo].[DBA_DBInfo] T1
								LEFT 
								JOIN	[dbacentral].[dbo].[DBA_DBNameCleaner] T2
									ON	T1.DBName Like T2.DBName
								LEFT
								JOIN	(
									SELECT	DISTINCT
										[DBName_Cleaned]+'%' [DBName]
										,[DBName_Cleaned]
									FROM	[dbacentral].[dbo].[DBA_DBNameCleaner]
									) T3
									ON	T1.DBName Like T3.DBName
								WHERE	SQLName IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE	Active = 'y')
								--ORDER BY 1,2
								)Data
						) Data
				WHERE		nullif(LinkName,'') IS NOT NULL
				order by	SetName,LinkName
				)Data
		GROUP BY	setname,row
		)

SELECT		[DBAadmin].[dbo].[dbaudf_FileAccess_Write] ([OutputRow],@Output_Path+'\'+SetName+'.aspx',1,1)
--SELECT *
FROM		(
		SELECT		SetName
				,'          <tr><td>'+REPLACE([LinkSet],',','</td><td>')+'</td>'
				+ ISNULL(REPLICATE('<td></td>',@TableWidth-[SetSize]),'')
				+'</tr>' [OutputRow]
		FROM		[Servers_Active]
		) Data


-- FINISH WRITING TO THE FILES
SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write] ('<tr><td rowspan="1" colspan="'+CAST(@TableWidth AS VARCHAR(2))+'" style="width: 100%;"></td></tr></tbody></table>'+CHAR(13)+CHAR(10)+@html2
							,@Output_Path+'\'+SetName+'.aspx'
							,1,1)
FROM	(
	SELECT	DISTINCT
		'MSSQL SERVERS - DATABASE '+ UPPER(COALESCE(T2.DBName_Cleaned,T3.DBName_Cleaned,T1.DBName)) SetName
	FROM	[dbacentral].[dbo].[DBA_DBInfo] T1
	LEFT 
	JOIN	[dbacentral].[dbo].[DBA_DBNameCleaner] T2
		ON	T1.DBName Like T2.DBName
	LEFT
	JOIN	(
		SELECT	DISTINCT
			[DBName_Cleaned]+'%' [DBName]
			,[DBName_Cleaned]
		FROM	[dbacentral].[dbo].[DBA_DBNameCleaner]
		) T3
		ON	T1.DBName Like T3.DBName
	WHERE	SQLName IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE	Active = 'y')
	--ORDER BY 1
	) Sets

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
--
--	INDIVIDUAL SERVER PAGES
--
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
DECLARE		@HTML3		VarChar(max)

	-------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------------
	--	HEADER SECTION
	-------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------------



SET		@HTML3 = '
								<div style="text-align&#58;center;">
									<span style="color&#58;#ba44fd;font-family&#58;''segoe ui semilight'', ''segoe ui'', segoe, tahoma, helvetica, arial, sans-serif;font-size&#58;1.46em;line-height&#58;1.4;">
										<span class="ms-rteForeColor-4">
											<strong>$SQLNAME$</strong>
										</span>
										<br>
									</span>
								</div>
								<br>
								<br>
								<br>'

-- START THE FILE AS AN EMPTY FILE
SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write]	(
							@html1 +CHAR(13)+CHAR(10)+REPLACE(@HTML3,'$SQLNAME$',SQLNAME)
							,@Output_Path+'\'+REPLACE(SQLName,'\','$')+'.aspx'
							,0,1
							)
FROM	[dbacentral].[dbo].[ServerInfo]
WHERE	Active = 'y'

	-------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------------
	--	LINKS SECTION
	-------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------------

SELECT		@TableWidth		= 4
SET		@HTML3 = '
								<div>
									<h2 style="text-align&#58;center;">CUSTOM NOTES</h2>
								</div>
								<table border="0" cellpadding="0" cellspacing="0" bordercolor="#111111" width="100%" id="CustomNotes" height="50" style="text-align: center; border-collapse: collapse;">  
									<tbody>'

;WITH		[Set_Links]
		AS
		(
		SELECT		row
				,REPLACE(REPLACE(REPLACE(REPLACE(
				  dbaadmin.dbo.dbaudf_Concatenate('<a id="'
									+ '$5$$4$' + REPLACE(LinkName,' ','_')
									+ '|'
									+ LinkName
									+ '$1$'
									+ '$4$' + REPLACE(LinkName,' ','_')
									+ '$2$'
									+ '$4$' + REPLACE(LinkName,' ','_')
									+ '$3$'
									+ LinkName
									+ '</a>')
									,'$1$',@L1)
									,'$2$',@L2)
									,'$3$',@L3)
									,'$5$',@sharepointFolder) [LinkSet]
				,count(LinkName) [SetSize]
		FROM		(
				SELECT		TOP 100 PERCENT
						((rn-1)/@TableWidth+1) row
						,rn
						,LinkName
				FROM		(
						SELECT		row_number()over(order by LinkName) rn
								,LinkName
						FROM		(
								SELECT	'ACTIVE ALERTS' LinkName
								UNION ALL
								SELECT	'STANDARD DEVIATIONS'
								UNION ALL
								SELECT	'KNOWN ISSUES'
								UNION ALL
								SELECT	'GENERAL NOTES'
								)Data
						) Data
				WHERE		nullif(LinkName,'') IS NOT NULL
				order by	LinkName
				)Data
		GROUP BY	row
		)

SELECT		@HTML3 = @HTML3 +CHAR(13)+CHAR(10)
		+ '          <tr><td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;">'+REPLACE([LinkSet],',','</td><td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;">')+'</td>'
		+ ISNULL(REPLICATE('<td style="width: '+CAST(100/@TableWidth AS VARCHAR(2))+'%;"></td>',@TableWidth-[SetSize]),'')
		+'</tr>'
FROM		[Set_Links]

SELECT		@HTML3 = @HTML3 +CHAR(13)+CHAR(10)
		+ '									</tbody>
								</table>
								<br>
								<br>
								<br>
								<br>'

SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write]	(REPLACE(@HTML3,'$4$',ISNULL(REPLACE(SQLName,'\','$')+'_',''))

							,@Output_Path+'\'+REPLACE(SQLName,'\','$')+'.aspx'
							,1,1
							)
FROM	[dbacentral].[dbo].[ServerInfo]
WHERE	Active = 'y'


	-------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------------
	--	SERVER DETAILS SECTION
	-------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------------

SET		@HTML3 = '
								<div>
									<h2 style="text-align&#58;center;">SERVER DETAILS</h2>
								</div>
								<table border="1" cellpadding="0" cellspacing="0" bordercolor="#111111" width="100%" id="ServerDetails" height="50" style="text-align: center; border-collapse: collapse;">  
									<tbody>
										<tr>  
											<td width="15%" height="22" bgcolor="#000080"><b><font face="Verdana" size="1" color="#FFFFFF">Server IP</font></b></td>  
											<td width="15%" height="22" bgcolor="#000080"><b><font face="Verdana" size="1" color="#FFFFFF">Server Name</font></b></td>  
											<td width="15%" height="22" bgcolor="#000080"><b><font face="Verdana" size="1" color="#FFFFFF">Environment</font></b></td>
											<td width="15%" height="22" bgcolor="#000080"><b><font face="Verdana" size="1" color="#FFFFFF">Domain</font></b></td>
											<td width="15%" height="22" bgcolor="#000080"><b><font face="Verdana" size="1" color="#FFFFFF">DBAADMIN<br>Version</font></b></td>  
											<td width="15%" height="22" bgcolor="#000080"><b><font face="Verdana" size="1" color="#FFFFFF">DBAPERF<br>Version</font></b></td>  
											<td width="15%" height="22" bgcolor="#000080"><b><font face="Verdana" size="1" color="#FFFFFF">SQLDEPLOY<br>Version</font></b></td>  
										</tr>  
										<tr>  
											<td style="text-align: center; height: 15px;"><font face="Verdana" size="1">$VAR11$</font></td>  
											<td style="text-align: center; height: 15px;"><font face="Verdana" size="1">$VAR12$</font></td>  
											<td style="text-align: center; height: 15px;"><font face="Verdana" size="1">$VAR13$</font></td>
											<td style="text-align: center; height: 15px;"><font face="Verdana" size="1">$VAR14$</font></td>  
											<td style="text-align: center; height: 15px;"><font face="Verdana" size="1">$VAR15$</font></td>  
											<td style="text-align: center; height: 15px;"><font face="Verdana" size="1">$VAR16$</font></td>
											<td style="text-align: center; height: 15px;"><font face="Verdana" size="1">$VAR17$</font></td>  
										</tr>  
										<tr>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 15px;"><b><font face="Verdana" size="1" color="#ffffff">SQL Version</font></b></td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 15px;"><b><font face="Verdana" size="1" color="#ffffff">SQL Edition</font></b></td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 15px;"><b><font face="Verdana" size="1" color="#ffffff">SQL Build</font></b></td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 15px;"><b><font face="Verdana" size="1" color="#ffffff">SQL Bit Level</font></b></td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 15px;"><b><font face="Verdana" size="1" color="#ffffff">Total Memory</font></b></td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 15px;"><b><font face="Verdana" size="1" color="#ffffff">SQL Max Memory</font></b></td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 15px;"><b><font face="Verdana" size="1" color="#ffffff">Is Clustered</font></b></td>
										</tr>
										<tr>
											<td style="text-align: center; height: 15px;"><font face="Verdana" size="1">$VAR21$</font></td>
											<td style="text-align: center; height: 15px;"><font face="Verdana" size="1">$VAR22$</font></td>
											<td style="text-align: center; height: 15px;"><font face="Verdana" size="1">$VAR23$</font></td>
											<td style="text-align: center; height: 15px;"><font face="Verdana" size="1">$VAR24$</font></td>
											<td style="text-align: center; height: 15px;"><font face="Verdana" size="1">$VAR25$</font></td>
											<td style="text-align: center; height: 15px;"><font face="Verdana" size="1">$VAR26$</font></td>
											<td style="text-align: center; height: 15px;"><font face="Verdana" size="1">$VAR27$</font></td>
										</tr>
										<tr>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 15px;"><b><font face="Verdana" size="1" color="#ffffff">OS Version</font></b></td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 15px;"><b><font face="Verdana" size="1" color="#ffffff">OS Edition</font></b></td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 15px;"><b><font face="Verdana" size="1" color="#ffffff">OS Build</font></b></td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 15px;"><b><font face="Verdana" size="1" color="#ffffff">OS Bit Level</font></b></td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 15px;"><b><font face="Verdana" size="1" color="#ffffff">PageFile Max</font></b></td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 15px;"><b><font face="Verdana" size="1" color="#ffffff">OS Restarted</font></b></td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 15px;"><b><font face="Verdana" size="1" color="#ffffff">SQL Restarted</font></b></td>
										</tr>
										<tr>
											<td style="text-align: center; height: 15px;"><font face="Verdana" size="1">$VAR31$</font></td>
											<td style="text-align: center; height: 15px;"><font face="Verdana" size="1">$VAR32$</font></td>
											<td style="text-align: center; height: 15px;"><font face="Verdana" size="1">$VAR33$</font></td>
											<td style="text-align: center; height: 15px;"><font face="Verdana" size="1">$VAR34$</font></td>
											<td style="text-align: center; height: 15px;"><font face="Verdana" size="1">$VAR35$</font></td>
											<td style="text-align: center; height: 15px;"><font face="Verdana" size="1">$VAR36$</font></td>
											<td style="text-align: center; height: 15px;"><font face="Verdana" size="1">$VAR37$</font></td>
										</tr>
									</tbody>
								</table>
								<br>
								<br>
								<br>
								<br>'

SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write]	(
							REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
								REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
								REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@HTML3
								,'$VAR11$',ISNULL([IPnum],''))
								,'$VAR12$',ISNULL(UPPER([SQLNAME]),''))
								,'$VAR13$',ISNULL(UPPER([SQLEnv]),''))
								,'$VAR14$',ISNULL(UPPER([DomainName]),''))
								,'$VAR15$',ISNULL([OPSDBVersion_DBAADMIN],''))
								,'$VAR16$',ISNULL([OPSDBVersion_DBAPERF],''))
								,'$VAR17$',ISNULL([OPSDBVersion_SQLdeploy],''))

								,'$VAR21$',ISNULL([SQL_Version],''))
								,'$VAR22$',ISNULL([SQL_Edition],''))
								,'$VAR23$',ISNULL([SQL_Build],''))
								,'$VAR24$',ISNULL([SQL_BitLevel],''))
								,'$VAR25$',ISNULL(dbaadmin.dbo.dbaudf_FormatNumber([MEM_MB_Total],10,2),''))
								,'$VAR26$',ISNULL(dbaadmin.dbo.dbaudf_FormatNumber([MEM_MB_SQLMax],10,2),''))
								,'$VAR27$',ISNULL(CASE [Iscluster] WHEN 'y' then '&#10004;' ELSE '' END,''))

								,'$VAR31$',ISNULL([OS_Version],''))
								,'$VAR32$',ISNULL([OS_Edition],''))
								,'$VAR33$',ISNULL([OS_Build],''))
								,'$VAR34$',ISNULL([OS_BitLevel],''))
								,'$VAR35$',ISNULL(dbaadmin.dbo.dbaudf_FormatNumber([MEM_MB_PageFileMax],10,2),''))
								,'$VAR36$',ISNULL(CAST([OSuptime] AS VarChar(50)),''))
								,'$VAR37$',ISNULL(CAST([SQLrecycleDate] AS VarChar(50)),''))

							,@Output_Path+'\'+REPLACE(SQLName,'\','$')+'.aspx'
							,1,1
							)
FROM	[dbacentral].[dbo].[ServerInfo]
WHERE	Active = 'y'



	-------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------------
	--	DRIVE DETAILS
	-------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------------


SET		@HTML3 = '
								<div>
									<h2 style="text-align&#58;center;">DRIVE DETAILS</h2>
								</div>
								<table border="1" cellpadding="0" cellspacing="0" bordercolor="#111111" width="100%" height="50" style="text-align: center; border-collapse: collapse;">
									<tbody>
										<tr>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 20px;">DRIVE</td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 20px;">SIZE</td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 20px;">FREE</td>
											<td bgcolor="#000080" style="text-align: center; width: 150px; height: 20px;">%&#160;&#160;&#160;<span class="ms-rteForeColor-2">Full&#160;&#9608;</span>&#160;&#160;&#160;<span class="ms-rteForeColor-6">Free&#160;&#9608;</span></td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 20px;">GROWTH<br/>PER WEEK</td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 20px;">WEEKS<br/>TILL FULL</td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 20px;">SPACE CHECK<br/>OVERRIDE</td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 20px;">ACTIVE</td>
										</tr>'

SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write]	(
							@HTML3
							,@Output_Path+'\'+REPLACE(SQLName,'\','$')+'.aspx'
							,1,1
							)
FROM		[dbacentral].[dbo].[DBA_DiskInfo]
WHERE		[SQLNAME] IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE Active = 'y')
GROUP BY	SQLNAME


SET		@HTML3 = '
										<tr>
											<td style="text-align: center; height: 20px;">$VAR11$</td>
											<td style="text-align: center; height: 20px;">$VAR12$</td>
											<td style="text-align: center; height: 20px;">$VAR13$</td>
											<td style="text-align: center; height: 20px;">$VAR14$</td>
											<td style="text-align: center; height: 20px;">$VAR15$</td>
											<td style="text-align: center; height: 20px;">$VAR16$</td>
											<td style="text-align: center; height: 20px;">$VAR17$</td>
											<td style="text-align: center; height: 20px;">$VAR18$</td>
										</tr>'

SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write]	(
							REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@HTML3
								,'$VAR11$',ISNULL([DriveName],''))
								,'$VAR12$',ISNULL([DriveSize],''))
								,'$VAR13$',ISNULL([DriveFree],''))
								,'$VAR14$',ISNULL([Chart],''))
								,'$VAR15$',ISNULL([GrowthPerWeek],''))
								,'$VAR16$',ISNULL(CAST([DriveFullWks] AS VarChar(50)),''))
								,'$VAR17$',ISNULL(CAST([Ovrrd_Freespace_pct] AS VarChar(50)),''))
								,'$VAR18$',ISNULL([Active],''))

							,@Output_Path+'\'+REPLACE(SQLName,'\','$')+'.aspx'
							,1,1
							)
FROM	(
	SELECT	[SQLName]
		,CASE [Active] WHEN 'y' then '&#10004;' ELSE '' END [Active]
		,[DriveName]
		,dbaadmin.dbo.dbaudf_FormatBytes([DriveSize],'MB') [DriveSize]
		,dbaadmin.dbo.dbaudf_FormatBytes([DriveFree],'MB') [DriveFree]
		, '<span class="ms-rteForeColor-2">'
			+ RIGHT('000'+ CAST(100 - [DriveFree_pct] AS VarChar(50)),3)
			+ '% '
			+ REPLICATE('&#9608;',20 - CAST([DriveFree_pct]/5. AS INT))
			+ '</span>'
			+ '<span class="ms-rteForeColor-6">'
			+ REPLICATE('&#9608;',CAST([DriveFree_pct]/5. AS INT))
			+ ' '
			+ RIGHT('000'+ CAST([DriveFree_pct] AS VarChar(50)),3)
			+ '%'
			+ '</span>' [Chart]
		,dbaadmin.dbo.dbaudf_FormatBytes([GrowthPerWeekMB],'MB') [GrowthPerWeek]
		,[DriveFullWks]
		,[Ovrrd_Freespace_pct]
		,[modDate]
	FROM	[dbacentral].[dbo].[DBA_DiskInfo]
	WHERE	[SQLName] IN (SELECT [SQLNAME] FROM [dbacentral].[dbo].[ServerInfo] WHERE Active = 'y')
	) DATA
ORDER BY	[SQLName],[DriveName]


SET		@HTML3 = '
									</tbody>
								</table>
								<br>
								<br>
								<br>
								<br>'

SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write]	(
							@HTML3
							,@Output_Path+'\'+REPLACE(SQLName,'\','$')+'.aspx'
							,1,1
							)
FROM		[dbacentral].[dbo].[DBA_DiskInfo]
WHERE		[SQLNAME] IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE Active = 'y')
GROUP BY	SQLNAME




	-------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------------
	--	CLUSTER DETAILS SECTION
	-------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------------

SET		@HTML3 = '
								<div>
									<h2 style="text-align&#58;center;">CLUSTER DETAILS</h2>
								</div>
								<table border="1" cellpadding="0" cellspacing="0" bordercolor="#111111" width="100%" height="50" style="text-align: center; border-collapse: collapse;">
									<tbody>
										<tr>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 15px;">CLUSTER NAME</td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 15px;">CLUSTER IP</td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 15px;">VERSION</td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 15px;">LAST CHECKED</td>
										</tr>
										<tr>
											<td style="text-align: center; height: 15px;">$VAR11$</td>
											<td style="text-align: center; height: 15px;">$VAR12$</td>
											<td style="text-align: center; height: 15px;">$VAR13$</td>
											<td style="text-align: center; height: 15px;">$VAR14$</td>
										</tr>
									</tbody>
								</table>
								<br>
								<br>
								<br>
								<br>'

SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write]	(
							REPLACE(REPLACE(REPLACE(REPLACE(@HTML3
								,'$VAR11$',ISNULL([ClusterName],''))
								,'$VAR12$',ISNULL([ClusterIP],''))
								,'$VAR13$',ISNULL([ClusterVer],''))
								,'$VAR14$',ISNULL(CAST(MAX([modDate]) AS VarChar(50)),''))

							,@Output_Path+'\'+REPLACE(SQLName,'\','$')+'.aspx'
							,1,1
							)
FROM		[dbacentral].[dbo].[DBA_ClustInfo]
WHERE		ClusterName IS NOT NULL
	AND	SQLNAME IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE Active = 'y')
GROUP BY	SQLName
		,ClusterName
		,ClusterIP
		,ClusterVer



	-------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------------
	--	CLUSTER RESORCES SECTION
	-------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------------


SET		@HTML3 = '
								<div>
									<h2 style="text-align&#58;center;">CLUSTER RESOURCES</h2>
								</div>
								<table border="1" cellpadding="0" cellspacing="0" bordercolor="#111111" width="100%" height="50" style="text-align: center; border-collapse: collapse;">
									<tbody>
										<tr>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 15px;">GROUP NAME</td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 15px;">TYPE</td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 15px;">NAME</td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 15px;">DETAILS</td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 15px;">DEPENDENCIES</td>
										</tr>'

SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write]	(
							@HTML3
							,@Output_Path+'\'+REPLACE(SQLName,'\','$')+'.aspx'
							,1,1
							)
FROM		[dbacentral].[dbo].[DBA_ClustInfo]
WHERE		ClusterName IS NOT NULL
	AND	SQLNAME IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE Active = 'y')
GROUP BY	SQLNAME


SET		@HTML3 = '
										<tr>
											<td style="text-align: center; height: 15px;">$VAR11$</td>
											<td style="text-align: center; height: 15px;">$VAR12$</td>
											<td style="text-align: center; height: 15px;">$VAR13$</td>
											<td style="text-align: center; height: 15px;">$VAR14$</td>
											<td style="text-align: center; height: 15px;">$VAR15$</td>
										</tr>'

SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write]	(
							REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@HTML3
								,'$VAR11$',ISNULL(GroupName,''))
								,'$VAR12$',ISNULL(ResourceType,''))
								,'$VAR13$',ISNULL(ResourceName,''))
								,'$VAR14$',ISNULL(ResourceDetail,''))
								,'$VAR15$',ISNULL(Dependencies,''))

							,@Output_Path+'\'+REPLACE(SQLName,'\','$')+'.aspx'
							,1,1
							)
FROM		[dbacentral].[dbo].[DBA_ClustInfo]
WHERE		ClusterName IS NOT NULL
	AND	SQLNAME IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE Active = 'y')
ORDER BY	SQLNAME,GroupName,ResourceType,ResourceName


SET		@HTML3 = '
									</tbody>
								</table>
								<br>
								<br>
								<br>
								<br>'

SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write]	(
							@HTML3
							,@Output_Path+'\'+REPLACE(SQLName,'\','$')+'.aspx'
							,1,1
							)
FROM		[dbacentral].[dbo].[DBA_ClustInfo]
WHERE		ClusterName IS NOT NULL
	AND	SQLNAME IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE Active = 'y')
GROUP BY	SQLNAME



	-------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------------
	--	STANDARD AGENT JOBS SECTION
	-------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------------


SET		@HTML3 = '
								<div>
									<h2 style="text-align&#58;center;">STANDARD AGENT JOB DETAILS</h2>
								</div>
								<table border="1" cellpadding="0" cellspacing="0" bordercolor="#111111" width="100%" height="50" class="ms-rteTable-3" style="text-align: center; border-collapse: collapse;">
									<tbody>
										<tr>
											<td bgcolor="#000080" style="text-align: center; width: 200px; height: 15px;">JOB NAME</td>
											<td bgcolor="#000080" style="text-align: center; width: 300px; height: 15px;">DESCRIPTION</td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 15px;">ON</td>
											<td bgcolor="#000080" style="text-align: center; width: 35px; height: 15px;">AVG<br/>DUR<br/>(min)</td>
											<td bgcolor="#000080" style="text-align: center; width: 200px; height: 15px;">STEPS</td>
										</tr>'

SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write]	(
							@HTML3
							,@Output_Path+'\'+REPLACE(SQLName,'\','$')+'.aspx'
							,1,1
							)
FROM		[dbacentral].[dbo].[DBA_JobInfo]
WHERE		[JobName] IS NOT NULL
	AND	[SQLNAME] IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE Active = 'y')
	AND	(
		[JobName] Like 'MAINT%'
	  OR	[JobName] Like 'UTIL%'
	  OR	[JobName] Like 'MON%'
	  OR	[JobName] Like 'LSAlert%'
	  OR	[JobName] Like 'LSBackup%'
	  OR	[JobName] Like 'LSCopy%'
	  OR	[JobName] Like 'SQLdeploy%'
	  OR	[JobName] Like 'RstrDly%'
	  OR	[JobName] Like 'BASE - Local Process'
	  OR	[JobName] Like 'Database Mirroring Monitor Job'
		)
GROUP BY	SQLNAME


SET		@HTML3 = '
										<tr $RC$>
											<td style="text-align: left; height: 15px;">$VAR11$</td>
											<td style="text-align: left; height: 15px;">$VAR12$</td>
											<td style="text-align: center; height: 15px;">$VAR13$</td>
											<td style="text-align: center; height: 15px;">$VAR14$</td>
											<td style="text-align: left; height: 15px;">$VAR15$</td>
										</tr>'

SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write]	(
							REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@HTML3
								,'$VAR11$',ISNULL([JobName],''))
								,'$VAR12$',ISNULL([Description],''))
								,'$VAR13$',ISNULL(CASE [Enabled] WHEN '1' then '&#10004;' ELSE '' END,''))
								,'$VAR14$',ISNULL(CAST([AvgDurationMin] AS VarChar(50)),''))
								,'$VAR15$',ISNULL(REPLACE([JobSteps],',(','<br/>('),''))
								,'$RC$',CASE ROW_NUMBER()OVER(PARTITION BY [SQLName] ORDER BY [JobName]) % 2 WHEN 1 THEN 'class="ms-rteTableOddRow-3"' ELSE 'class="ms-rteTableEvenRow-3"' END)
							,@Output_Path+'\'+REPLACE(SQLName,'\','$')+'.aspx'
							,1,1
							)
--SELECT		ROW_NUMBER()OVER(PARTITION BY [SQLName] ORDER BY [JobName]) % 2
--		,ROW_NUMBER()OVER(PARTITION BY [SQLName] ORDER BY [JobName])
--		,*
FROM		[dbacentral].[dbo].[DBA_JobInfo]
WHERE		[JobName] IS NOT NULL
	AND	[SQLName] IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE Active = 'y')
	AND	(
		[JobName] Like 'MAINT%'
	  OR	[JobName] Like 'UTIL%'
	  OR	[JobName] Like 'MON%'
	  OR	[JobName] Like 'LSAlert%'
	  OR	[JobName] Like 'LSBackup%'
	  OR	[JobName] Like 'LSCopy%'
	  OR	[JobName] Like 'SQLdeploy%'
	  OR	[JobName] Like 'RstrDly%'
	  OR	[JobName] Like 'BASE - Local Process'
	  OR	[JobName] Like 'Database Mirroring Monitor Job'
		)
ORDER BY	[SQLName],[JobName]


SET		@HTML3 = '
									</tbody>
								</table>
								<br>
								<br>
								<br>
								<br>'

SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write]	(
							@HTML3
							,@Output_Path+'\'+REPLACE(SQLName,'\','$')+'.aspx'
							,1,1
							)
FROM		[dbacentral].[dbo].[DBA_JobInfo]
WHERE		[JobName] IS NOT NULL
	AND	[SQLNAME] IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE Active = 'y')
	AND	(
		[JobName] Like 'MAINT%'
	  OR	[JobName] Like 'UTIL%'
	  OR	[JobName] Like 'MON%'
	  OR	[JobName] Like 'LSAlert%'
	  OR	[JobName] Like 'LSBackup%'
	  OR	[JobName] Like 'LSCopy%'
	  OR	[JobName] Like 'SQLdeploy%'
	  OR	[JobName] Like 'RstrDly%'
	  OR	[JobName] Like 'BASE - Local Process'
	  OR	[JobName] Like 'Database Mirroring Monitor Job'
		)
GROUP BY	SQLNAME




	-------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------------
	--	APPLICATION AGENT JOBS SECTION
	-------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------------


SET		@HTML3 = '
								<div>
									<h2 style="text-align&#58;center;">APPLICATION AGENT JOB DETAILS</h2>
								</div>
								<table border="1" cellpadding="0" cellspacing="0" bordercolor="#111111" width="100%" height="50" class="ms-rteTable-3" style="text-align: center; border-collapse: collapse;">
									<tbody>
										<tr>
											<td bgcolor="#000080" style="text-align: center; width: 200px; height: 15px;">JOB NAME</td>
											<td bgcolor="#000080" style="text-align: center; width: 300px; height: 15px;">DESCRIPTION</td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 15px;">ON</td>
											<td bgcolor="#000080" style="text-align: center; width: 35px; height: 15px;">AVG<br/>DUR<br/>(min)</td>
											<td bgcolor="#000080" style="text-align: center; width: 200px; height: 15px;">STEPS</td>
										</tr>'

SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write]	(
							@HTML3
							,@Output_Path+'\'+REPLACE(SQLName,'\','$')+'.aspx'
							,1,1
							) --select SQLNAME
FROM		[dbacentral].[dbo].[DBA_JobInfo]
WHERE		[JobName] IS NOT NULL
	AND	[SQLNAME] IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE Active = 'y')
	AND	[JobName] Like 'APPL%'
GROUP BY	SQLNAME


SET		@HTML3 = '
										<tr $RC$>
											<td style="text-align: left; height: 15px;">$VAR11$</td>
											<td style="text-align: left; height: 15px;">$VAR12$</td>
											<td style="text-align: center; height: 15px;">$VAR13$</td>
											<td style="text-align: center; height: 15px;">$VAR14$</td>
											<td style="text-align: left; height: 15px;">$VAR15$</td>
										</tr>'

SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write]	(
							REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@HTML3
								,'$VAR11$',ISNULL([JobName],''))
								,'$VAR12$',ISNULL([Description],''))
								,'$VAR13$',ISNULL(CASE [Enabled] WHEN '1' then '&#10004;' ELSE '' END,''))
								,'$VAR14$',ISNULL(CAST([AvgDurationMin] AS VarChar(50)),''))
								,'$VAR15$',ISNULL(REPLACE([JobSteps],',(','<br/>('),''))
								,'$RC$',CASE ROW_NUMBER()OVER(PARTITION BY [SQLName] ORDER BY [JobName]) % 2 WHEN 1 THEN 'class="ms-rteTableOddRow-3"' ELSE 'class="ms-rteTableEvenRow-3"' END)
							,@Output_Path+'\'+REPLACE(SQLName,'\','$')+'.aspx'
							,1,1
							)
FROM		[dbacentral].[dbo].[DBA_JobInfo]
WHERE		[JobName] IS NOT NULL
	AND	[SQLName] IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE Active = 'y')
	AND	[JobName] Like 'APPL%'
ORDER BY	[SQLName],[JobName]


SET		@HTML3 = '
									</tbody>
								</table>
								<br>
								<br>
								<br>
								<br>'

SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write]	(
							@HTML3
							,@Output_Path+'\'+REPLACE(SQLName,'\','$')+'.aspx'
							,1,1
							)
FROM		[dbacentral].[dbo].[DBA_JobInfo]
WHERE		[JobName] IS NOT NULL
	AND	[SQLNAME] IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE Active = 'y')
	AND	[JobName] Like 'APPL%'
GROUP BY	SQLNAME




	-------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------------
	--	SPECIAL AGENT JOBS SECTION
	-------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------------


SET		@HTML3 = '
								<div>
									<h2 style="text-align&#58;center;">SPECIAL AGENT JOB DETAILS</h2>
								</div>
								<table border="1" cellpadding="0" cellspacing="0" bordercolor="#111111" width="100%" height="50" class="ms-rteTable-3" style="text-align: center; border-collapse: collapse;">
									<tbody>
										<tr>
											<td bgcolor="#000080" style="text-align: center; width: 200px; height: 15px;">JOB NAME</td>
											<td bgcolor="#000080" style="text-align: center; width: 300px; height: 15px;">DESCRIPTION</td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 15px;">ON</td>
											<td bgcolor="#000080" style="text-align: center; width: 35px; height: 15px;">AVG<br/>DUR<br/>(min)</td>
											<td bgcolor="#000080" style="text-align: center; width: 200px; height: 15px;">STEPS</td>
										</tr>'

SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write]	(
							@HTML3
							,@Output_Path+'\'+REPLACE(SQLName,'\','$')+'.aspx'
							,1,1
							)
FROM		[dbacentral].[dbo].[DBA_JobInfo]
WHERE		[JobName] IS NOT NULL
	AND	[SQLNAME] IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE Active = 'y')
	AND	[JobName] Like 'SPCL%'
GROUP BY	SQLNAME


SET		@HTML3 = '
										<tr $RC$>
											<td style="text-align: left; height: 15px;">$VAR11$</td>
											<td style="text-align: left; height: 15px;">$VAR12$</td>
											<td style="text-align: center; height: 15px;">$VAR13$</td>
											<td style="text-align: center; height: 15px;">$VAR14$</td>
											<td style="text-align: left; height: 15px;">$VAR15$</td>
										</tr>'

SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write]	(
							REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@HTML3
								,'$VAR11$',ISNULL([JobName],''))
								,'$VAR12$',ISNULL([Description],''))
								,'$VAR13$',ISNULL(CASE [Enabled] WHEN '1' then '&#10004;' ELSE '' END,''))
								,'$VAR14$',ISNULL(CAST([AvgDurationMin] AS VarChar(50)),''))
								,'$VAR15$',ISNULL(REPLACE([JobSteps],',(','<br/>('),''))
								,'$RC$',CASE ROW_NUMBER()OVER(PARTITION BY [SQLName] ORDER BY [JobName]) % 2 WHEN 1 THEN 'class="ms-rteTableOddRow-3"' ELSE 'class="ms-rteTableEvenRow-3"' END)
							,@Output_Path+'\'+REPLACE(SQLName,'\','$')+'.aspx'
							,1,1
							)
FROM		[dbacentral].[dbo].[DBA_JobInfo]
WHERE		[JobName] IS NOT NULL
	AND	[SQLName] IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE Active = 'y')
	AND	[JobName] Like 'SPCL%'
ORDER BY	[SQLName],[JobName]


SET		@HTML3 = '
									</tbody>
								</table>
								<br>
								<br>
								<br>
								<br>'

SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write]	(
							@HTML3
							,@Output_Path+'\'+REPLACE(SQLName,'\','$')+'.aspx'
							,1,1
							)
FROM		[dbacentral].[dbo].[DBA_JobInfo]
WHERE		[JobName] IS NOT NULL
	AND	[SQLNAME] IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE Active = 'y')
	AND	[JobName] Like 'SPCL%'
GROUP BY	SQLNAME



	-------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------------
	--	UNCLASIFIED AGENT JOBS SECTION
	-------------------------------------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------------------------------


SET		@HTML3 = '
								<div>
									<h2 style="text-align&#58;center;">UNCLASIFIED AGENT JOB DETAILS</h2>
								</div>
								<table border="1" cellpadding="0" cellspacing="0" bordercolor="#111111" width="100%" height="50" class="ms-rteTable-3" style="text-align: center; border-collapse: collapse;">
									<tbody>
										<tr>
											<td bgcolor="#000080" style="text-align: center; width: 200px; height: 15px;">JOB NAME</td>
											<td bgcolor="#000080" style="text-align: center; width: 300px; height: 15px;">DESCRIPTION</td>
											<td bgcolor="#000080" style="text-align: center; width: 25px; height: 15px;">ON</td>
											<td bgcolor="#000080" style="text-align: center; width: 35px; height: 15px;">AVG<br/>DUR<br/>(min)</td>
											<td bgcolor="#000080" style="text-align: center; width: 200px; height: 15px;">STEPS</td>
										</tr>'

SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write]	(
							@HTML3
							,@Output_Path+'\'+REPLACE(SQLName,'\','$')+'.aspx'
							,1,1
							)
FROM		[dbacentral].[dbo].[DBA_JobInfo]
WHERE		[JobName] IS NOT NULL
	AND	[SQLNAME] IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE Active = 'y')
	AND	[JobName] NOT Like 'SPCL%'
	AND	[JobName] NOT Like 'APPL%'
	AND	[JobName] NOT Like 'MAINT%'
	AND	[JobName] NOT Like 'UTIL%'
	AND	[JobName] NOT Like 'MON%'
	AND	[JobName] NOT Like 'LSAlert%'
	AND	[JobName] NOT Like 'LSBackup%'
	AND	[JobName] NOT Like 'LSCopy%'
	AND	[JobName] NOT Like 'SQLdeploy%'
	AND	[JobName] NOT Like 'RstrDly%'
	AND	[JobName] NOT Like 'BASE - Local Process'
	AND	[JobName] NOT Like 'Database Mirroring Monitor Job'
GROUP BY	SQLNAME


SET		@HTML3 = '
										<tr $RC$>
											<td style="text-align: left; height: 15px;">$VAR11$</td>
											<td style="text-align: left; height: 15px;">$VAR12$</td>
											<td style="text-align: center; height: 15px;">$VAR13$</td>
											<td style="text-align: center; height: 15px;">$VAR14$</td>
											<td style="text-align: left; height: 15px;">$VAR15$</td>
										</tr>'

SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write]	(
							REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@HTML3
								,'$VAR11$',ISNULL([JobName],''))
								,'$VAR12$',ISNULL([Description],''))
								,'$VAR13$',ISNULL(CASE [Enabled] WHEN '1' then '&#10004;' ELSE '' END,''))
								,'$VAR14$',ISNULL(CAST([AvgDurationMin] AS VarChar(50)),''))
								,'$VAR15$',ISNULL(REPLACE([JobSteps],',(','<br/>('),''))
								,'$RC$',CASE ROW_NUMBER()OVER(PARTITION BY [SQLName] ORDER BY [JobName]) % 2 WHEN 1 THEN 'class="ms-rteTableOddRow-3"' ELSE 'class="ms-rteTableEvenRow-3"' END)
							,@Output_Path+'\'+REPLACE(SQLName,'\','$')+'.aspx'
							,1,1
							)
FROM		[dbacentral].[dbo].[DBA_JobInfo]
WHERE		[JobName] IS NOT NULL
	AND	[SQLName] IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE Active = 'y')
	AND	[JobName] NOT Like 'SPCL%'
	AND	[JobName] NOT Like 'APPL%'
	AND	[JobName] NOT Like 'MAINT%'
	AND	[JobName] NOT Like 'UTIL%'
	AND	[JobName] NOT Like 'MON%'
	AND	[JobName] NOT Like 'LSAlert%'
	AND	[JobName] NOT Like 'LSBackup%'
	AND	[JobName] NOT Like 'LSCopy%'
	AND	[JobName] NOT Like 'SQLdeploy%'
	AND	[JobName] NOT Like 'RstrDly%'
	AND	[JobName] NOT Like 'BASE - Local Process'
	AND	[JobName] NOT Like 'Database Mirroring Monitor Job'
ORDER BY	[SQLName],[JobName]


SET		@HTML3 = '
									</tbody>
								</table>
								<br>
								<br>
								<br>
								<br>'

SELECT [DBAadmin].[dbo].[dbaudf_FileAccess_Write]	(
							@HTML3
							,@Output_Path+'\'+REPLACE(SQLName,'\','$')+'.aspx'
							,1,1
							)
FROM		[dbacentral].[dbo].[DBA_JobInfo]
WHERE		[JobName] IS NOT NULL
	AND	[SQLNAME] IN (SELECT SQLNAME FROM [dbacentral].[dbo].[ServerInfo] WHERE Active = 'y')
	AND	[JobName] NOT Like 'SPCL%'
	AND	[JobName] NOT Like 'APPL%'
	AND	[JobName] NOT Like 'MAINT%'
	AND	[JobName] NOT Like 'UTIL%'
	AND	[JobName] NOT Like 'MON%'
	AND	[JobName] NOT Like 'LSAlert%'
	AND	[JobName] NOT Like 'LSBackup%'
	AND	[JobName] NOT Like 'LSCopy%'
	AND	[JobName] NOT Like 'SQLdeploy%'
	AND	[JobName] NOT Like 'RstrDly%'
	AND	[JobName] NOT Like 'BASE - Local Process'
	AND	[JobName] NOT Like 'Database Mirroring Monitor Job'
GROUP BY	SQLNAME























SELECT	[DBAadmin].[dbo].[dbaudf_FileAccess_Write] (@html2,@Output_Path+'\'+REPLACE(SQLName,'\','$')+'.aspx',1,1)
FROM	[dbacentral].[dbo].[ServerInfo]
WHERE	Active = 'y'






--EXEC sp_xp_cmdshell_proxy_account 'AMER\SQLAdminProd2010', 'S3wingm@ch7nE'

--exec xp_CmdShell 'net use r: "https://gettyimages-my.sharepoint.com/personal/steve_ledridge_gettyimages_com/DBCollab/Database Wiki/MSSQL Servers/" /savecred'
--exec xp_CmdShell 'dir r:\'

--exec xp_CmdShell 'G:\MP_G01\Backup\dbasql\CopyWikiToSharepoint.cmd'

----S3wingm@ch7nE /user:AMER\SQLAdminProd2010 

--exec xp_LogEvent 50901, 'Start Wiki Copy to Sharepoint.com'

exec xp_cmdShell 'eventcreate /t information /id 101 /so GETTYSQLDBA /l application /d "Start Wiki Copy to Sharepoint.com"'