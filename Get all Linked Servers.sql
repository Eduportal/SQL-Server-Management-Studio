

SELECT		@@SERVERNAME		[From Server]
		,s.name			[Name]
		,s.product		[Type]
		,s.data_source		[To Server]
		--,p.principal_id
		,l.remote_name		[Login]
FROM		sys.servers s
join		sys.linked_logins l
	on	s.server_id = l.server_id
left join	sys.server_principals p
	on	l.local_principal_id = p.principal_id
where		s.is_linked = 1
	and	s.name != 'DYN_DBA_RMT' --GENERIC OPPERATIONS LINKED SERVER CAN BE IGNORED
go