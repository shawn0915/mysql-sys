--
-- View: schema_index_check
-- 
-- Check tables with no primary key and tables that haven't use innodb
--
-- mysql> select * from schema_index_check;
-- 
-- +-------------+------------+--------+------+-------+--------+
-- | schema_name | table_name | engine | nopk | ftidx | gisidx |
-- +-------------+------------+--------+------+-------+--------+
-- | sbtest      | t918       | InnoDB | nopk |       |        |
-- | sbtest      | t_binlog   | InnoDB | nopk |       |        |
-- +-------------+------------+--------+------+-------+--------+
-- 


CREATE OR REPLACE
  ALGORITHM = UNDEFINED
  DEFINER = 'root'@'localhost'
  SQL SECURITY INVOKER 
VIEW schema_index_check (
  schema_name,
  table_name,
  engine,
  nopk,
  ftidx,
  gisidx
) AS
select distinct t.table_schema as schema_name, t.table_name, t. engine,
if ( isnull(c.constraint_name), 'nopk', '' ) as nopk,
if ( s.index_type = 'fulltext', 'fulltext', '' ) as ftidx,
if ( s.index_type = 'spatial', 'spatial', '' ) as gisidx
from information_schema. tables as t
left join information_schema.key_column_usage as c
on ( t.table_schema = c.constraint_schema and t.table_name = c.table_name and c.constraint_name = 'primary' )
left join information_schema.statistics as s
on ( t.table_schema = s.table_schema and t.table_name = s.table_name and s.index_type in ('fulltext', 'spatial'))
where t.table_schema not in ( 'information_schema', 'performance_schema', 'mysql', 'sys' ) and t.table_type = 'base table'
and ( t.engine <> 'innodb' or c.constraint_name is null or s.index_type in ('fulltext', 'spatial'))
order by t.table_schema, t.table_name
;
