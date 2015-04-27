use WCDS; 
go   

declare @OriginalSystemBackup table 
        ( 
        iOriginalSystemID int not null, 
        vchOriginalSystemName nvarchar(30) not null, 
        iCreatedBy int not null, 
        dtCreated datetime not null, 
        iModifiedBy int not null, 
        dtModified datetime not null 
        ); 
declare @rowcount int 





DELETE dbo.AuthSiteAccess        
where OriginalSystemID in
(
select CAST(SystemID AS INT) from dbo.SecuritySystem with(nolock) where OwningCompanyId in (1,100,123) and SystemId != 9999
)

delete dbo.OriginalSystem 
where iOriginalSystemID in
(
select CAST(SystemID AS INT) from dbo.SecuritySystem with(nolock) where OwningCompanyId in (1,100,123) and SystemId != 9999
)

delete dbo.ScopingBundle
where SystemID in
(
select SystemID from dbo.SecuritySystem with(nolock) where OwningCompanyId in (1,100,123) and SystemId != 9999
)

delete dbo.AgreementFilter
where SystemID in
(
select SystemID from dbo.SecuritySystem with(nolock) where OwningCompanyId in (1,100,123) and SystemId != 9999
)

delete dbo.SecuritySecret
where SystemID in
(
select SystemID from dbo.SecuritySystem with(nolock) where OwningCompanyId in (1,100,123) and SystemId != 9999
)


delete dbo.SecuritySystem
where OwningCompanyId in (1,100,123) 
and SystemId != 9999

set @rowcount = @@rowcount 

while @rowcount = 1 
begin 
        delete top (1) 
        from dbo.OriginalSystem 
		output deleted.* 
		into @OriginalSystemBackup 
		where vchOriginalSystemName in (select top 1 SystemName from dbo.SecuritySystem with(nolock) where OwningCompanyId in (1,100,123) and SystemId != 9999)

end

