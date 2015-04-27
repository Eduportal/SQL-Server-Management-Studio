SET NOCOUNT ON;
SELECT		fg.data_space_id
		,fg.name
		,COALESCE((cast((sum(a.used_pages) * 8192/1048576.) as decimal(15, 2))*25)/100,0) 
FROM		sys.fileGroups fg
LEFT JOIN	sys.allocation_units a 
	ON	fg.data_space_id = a.data_space_id

LEFT JOIN	sys.fulltext_indexes fti
	ON	fg.data_space_id = fti.data_space_id

LEFT JOIN	sys.fulltext_catalogs ftc
	ON	fti.fulltext_catalog_id = ftc.fulltext_catalog_id

LEFT JOIN	sys.partitions p 
	ON	p.partition_id = a.container_id
LEFT JOIN	sys.internal_tables it 
	ON	p.object_id = it.object_id
GROUP BY	fg.data_space_id
		,fg.name



SELECT * FROM sys.fulltext_catalogs 
SELECT * FROM sys.fulltext_indexes
SELECT * FROM sys.fileGroups

SELECT FULLTEXTCATALOGPROPERTY ('ftcat_documentindex_9e0efd13ecab427f974e7f1336eb7159','IndexSize')


ftcat_documentindex_9e0efd13ecab427f974e7f1336eb7159

ftfg_ftcat_documentindex_9e0efd13ecab427f974e7f1336eb7159