use master
drop table test01
go
select o.*  into test01
from sys.all_objects o cross join sys.indexes i

alter table test01
add txt varchar(900)

select object_id('test01')

select * from sys.dm_db_index_physical_stats(1, object_id('test01'), null, null, 'detailed')

create index ix on test01(object_id, txt)

select * from sys.dm_db_index_physical_stats(1, object_id('test01'), null, null, 'detailed')

update test01
set txt = replicate('a', 850)

select * from sys.dm_db_index_physical_stats(1, object_id('test01'), null, null, 'detailed')

alter index ix on test01 rebuild

select * from sys.dm_db_index_physical_stats(1, object_id('test01'), null, null, 'detailed')