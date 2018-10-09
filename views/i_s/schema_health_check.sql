--
-- Name: schema_health_check
-- Desc: database health check 
-- 
-- MariaDB [sys]> select * from schema_health_check;
-- +-----------------+-------------------------------+-----------------+----------+---------------------------------------------------------+
-- | CATEGORY        | DIVISION                      | CURRENT_PERCENT | state    | description                                             |
-- +-----------------+-------------------------------+-----------------+----------+---------------------------------------------------------+
-- | Connection      | Refued Connection             |            99.8 | Critical |                                                         |
-- | Connection      | Connection Usage              |            44.8 | NULL     |                                                         |
-- ...
-- | Open Files      | Open Files Ratio              |             0.2 | NULL     |                                                         |
-- +-----------------+-------------------------------+-----------------+----------+---------------------------------------------------------+
--
--
-- CATEGORY:
--   - Connection
--   - Index
--   - Temporary Table
--   - Table Locks
--   - InnoDB Cache
--   - Key Cache
--   - Query Cache
--   - Open Table
--   - Open Files

CREATE OR REPLACE
ALGORITHM=UNDEFINED
DEFINER = 'root'@'localhost'
SQL SECURITY INVOKER
VIEW `schema_health_check`
AS
SELECT 'Connection' AS CATEGORY
      ,'Aborted Connection' AS DIVISION
      ,round(MAX(IF(variable_name = 'ABORTED_CONNECTS', variable_value, 0)) /
             MAX(IF(variable_name = 'CONNECTIONS', variable_value, 0)) * 100
            ,2) AS CURRENT_PERCENT
      ,CASE 
       WHEN (MAX(IF(variable_name = 'ABORTED_CONNECTS', variable_value, 0)) /
             MAX(IF(variable_name = 'CONNECTIONS', variable_value, 0)) * 100
            ) BETWEEN 30 AND 80
       THEN 'Warning'
       WHEN (MAX(IF(variable_name = 'ABORTED_CONNECTS', variable_value, 0)) /
             MAX(IF(variable_name = 'CONNECTIONS', variable_value, 0)) * 100
            ) > 80
       THEN 'Critical'
       END AS STATUS
      ,'Connection failure ratio' AS Description
  FROM information_schema.global_status
 WHERE variable_name IN ('ABORTED_CONNECTS', 'CONNECTIONS')
UNION ALL
SELECT 'Connection' AS CATEGORY
      ,'Connection Usage' AS DIVISION
      ,round(s.variable_value / v.variable_value * 100, 2) AS CURRENT_PERCENT
      ,CASE 
       WHEN (s.variable_value / v.variable_value * 100
            ) > 90
       THEN 'Warning'
       END AS STATUS
      ,'The ratio of the connected thread compared to the max connections' AS Description
  FROM information_schema.global_status s, information_schema.global_variables v
 WHERE s.variable_name IN ('THREADS_CONNECTED')
   AND v.variable_name IN ('MAX_CONNECTIONS')
UNION ALL
SELECT 'Connection' AS CATEGORY
      ,'Max Connection Used Usage' AS DIVISION
      ,round(s.variable_value / v.variable_value * 100, 2) AS CURRENT_PERCENT
      ,CASE 
       WHEN (s.variable_value / v.variable_value * 100
            ) > 90
       THEN 'Warning'
       END AS STATUS
      ,'The ratio of the most connections to the max connections' AS Description
  FROM information_schema.global_status s, information_schema.global_variables v
 WHERE s.variable_name IN ('MAX_USED_CONNECTIONS')
   AND v.variable_name IN ('MAX_CONNECTIONS')
UNION ALL
SELECT 'Index' AS CATEGORY
      ,'Percentage of Full table scan' AS DIVISION
      ,round(
             (
              MAX(IF(variable_name = 'HANDLER_READ_RND_NEXT', variable_value, 0)) +
              MAX(IF(variable_name = 'HANDLER_READ_RND', variable_value, 0))
             )
             /SUM(variable_value)
            ,2) AS CURRENT_PERCENT
      ,CASE 
       WHEN (
             (
              MAX(IF(variable_name = 'HANDLER_READ_RND_NEXT', variable_value, 0)) +
              MAX(IF(variable_name = 'HANDLER_READ_RND', variable_value, 0))
             )
             /SUM(variable_value)
            ) BETWEEN 20 AND 40
       THEN 'Warning'
       WHEN (
             (
              MAX(IF(variable_name = 'HANDLER_READ_RND_NEXT', variable_value, 0)) +
              MAX(IF(variable_name = 'HANDLER_READ_RND', variable_value, 0))
             )
             /SUM(variable_value)
            ) > 40
       THEN 'Critical'
       END AS STATUS
      ,'Percentage of rows access through the Table Full scan' AS Description
  FROM information_schema.global_status
 WHERE variable_name IN ('HANDLER_READ_RND', 'HANDLER_READ_KEY', 'HANDLER_READ_FIRST', 'HANDLER_READ_RND_NEXT', 'HANDLER_READ_PREV')
UNION ALL
SELECT 'Temporary Table' AS CATEGORY
      ,'Disk Used ratio' AS DIVISION
      ,round(MAX(IF(variable_name = 'CREATED_TMP_DISK_TABLES', variable_value, 0)) /
             MAX(IF(variable_name = 'CREATED_TMP_TABLES', variable_value, 0)) * 100
            ,2) AS CURRENT_PERCENT
      ,CASE 
       WHEN (MAX(IF(variable_name = 'CREATED_TMP_DISK_TABLES', variable_value, 0)) /
             MAX(IF(variable_name = 'CREATED_TMP_TABLES', variable_value, 0)) * 100
            ) BETWEEN 50 AND 75
       THEN 'Warning'
       WHEN (MAX(IF(variable_name = 'CREATED_TMP_DISK_TABLES', variable_value, 0)) /
             MAX(IF(variable_name = 'CREATED_TMP_TABLES', variable_value, 0)) * 100
            ) > 75
       THEN 'Critical'
       END AS STATUS
      ,'The rate at which temporary tables are created on physical disks' AS Description
  FROM information_schema.global_status
 WHERE variable_name IN ('CREATED_TMP_DISK_TABLES', 'CREATED_TMP_TABLES')
UNION ALL
SELECT 'Table Locks' AS CATEGORY
      ,'Lock Connections' AS DIVISION
      ,round(MAX(IF(variable_name = 'TABLE_LOCKS_WAITED', variable_value, 0)) /
             SUM(variable_value) * 100
            ,2) AS CURRENT_PERCENT
      ,CASE 
       WHEN (MAX(IF(variable_name = 'TABLE_LOCKS_WAITED', variable_value, 0)) /
             SUM(variable_value) * 100
            ) BETWEEN 30 AND 60
       THEN 'Warning'
       WHEN (MAX(IF(variable_name = 'TABLE_LOCKS_WAITED', variable_value, 0)) /
             SUM(variable_value) * 100
            ) > 60
       THEN 'Critical'
       END AS STATUS
      ,'Table lock contention' AS Description
  FROM information_schema.global_status
 WHERE variable_name IN ('TABLE_LOCKS_WAITED', 'TABLE_LOCKS_IMMEDIATE')
UNION ALL
SELECT 'InnoDB Cache' AS CATEGORY
      ,'Cache write wait required' AS DIVISION
      ,round(MAX(IF(variable_name = 'INNODB_BUFFER_POOL_WAIT_FREE', variable_value, 0)) /
             MAX(IF(variable_name = 'INNODB_BUFFER_POOL_WRITE_REQUESTS', variable_value, 0)) * 100
            ,2) AS CURRENT_PERCENT
      ,CASE 
       WHEN (MAX(IF(variable_name = 'INNODB_BUFFER_POOL_WAIT_FREE', variable_value, 0)) /
             MAX(IF(variable_name = 'INNODB_BUFFER_POOL_WRITE_REQUESTS', variable_value, 0)) * 100
            ) BETWEEN 0.001 AND 10
       THEN 'Warning'
       WHEN (MAX(IF(variable_name = 'INNODB_BUFFER_POOL_WAIT_FREE', variable_value, 0)) /
             MAX(IF(variable_name = 'INNODB_BUFFER_POOL_WRITE_REQUESTS', variable_value, 0)) * 100
            ) > 10
       THEN 'Critical'
       END AS STATUS
      ,'The rate at which the InnoDB Buffer pool waits before writing' AS Description
  FROM information_schema.global_status
 WHERE variable_name IN ('INNODB_BUFFER_POOL_WAIT_FREE', 'INNODB_BUFFER_POOL_WRITE_REQUESTS')
UNION ALL
SELECT 'InnoDB Cache' AS CATEGORY
      ,'Cache hit ratio' AS DIVISION
      ,round(100 -
             MAX(IF(variable_name = 'INNODB_BUFFER_POOL_READS', variable_value, 0)) /
             MAX(IF(variable_name = 'INNODB_BUFFER_POOL_READ_REQUESTS', variable_value, 0)) * 100
            ,2) AS CURRENT_PERCENT
      ,NULL AS STATUS
      ,'Rate read from InnoDB Buffer Pool' AS Description
  FROM information_schema.global_status
 WHERE variable_name IN ('INNODB_BUFFER_POOL_READS', 'INNODB_BUFFER_POOL_READ_REQUESTS')
UNION ALL
SELECT 'Key Cache' AS CATEGORY
      ,'Cache hit ratio' AS DIVISION
      ,round(100 -
             MAX(IF(variable_name = 'KEY_READS', variable_value, 0)) /
             MAX(IF(variable_name = 'KEY_READ_REQUESTS', variable_value, 0)) * 100
            ,2) AS CURRENT_PERCENT
      ,CASE 
       WHEN (100 -
             MAX(IF(variable_name = 'KEY_READS', variable_value, 0)) /
             MAX(IF(variable_name = 'KEY_READ_REQUESTS', variable_value, 0)) * 100
            ) < 90
       THEN 'Warning'
       END AS STATUS
      ,'Key Cache Usage Rate' AS Description
  FROM information_schema.global_status
 WHERE variable_name IN ('KEY_READS', 'KEY_READ_REQUESTS')
UNION ALL
SELECT 'Query Cache' AS CATEGORY
      ,'Query Cache hit ratio' AS DIVISION
      ,round(100 -
             MAX(IF(variable_name = 'Qcache_free_blocks', variable_value, 0)) /
             MAX(IF(variable_name = 'Qcache_total_blocks', variable_value, 0)) * 100
            ,2) AS CURRENT_PERCENT
      ,CASE 
       WHEN (100 -
             MAX(IF(variable_name = 'Qcache_free_blocks', variable_value, 0)) /
             MAX(IF(variable_name = 'Qcache_total_blocks', variable_value, 0)) * 100
            ) < 25
            OR
            (100 -
             MAX(IF(variable_name = 'Qcache_free_blocks', variable_value, 0)) /
             MAX(IF(variable_name = 'Qcache_total_blocks', variable_value, 0)) * 100
            ) > 80
       THEN 'Warning'
       END AS STATUS
      ,'Query Cache usage rate (less than 25%: Query_cache_size recommended to shrink, 80% exceeded: Qcache_lowmem_prunes recommended to increase query_cache_size if it exceeds 50)' AS Description
  FROM information_schema.global_status
 WHERE variable_name IN ('Qcache_free_blocks', 'Qcache_total_blocks')
UNION ALL
SELECT 'Open Table' AS CATEGORY
      ,'Open Table ratio' AS DIVISION
      ,round(MAX(IF(variable_name = 'OPEN_TABLES', variable_value, 0)) /
             MAX(IF(variable_name = 'OPENED_TABLES', variable_value, 0)) * 100
            ,2) AS CURRENT_PERCENT
      ,CASE 
       WHEN (MAX(IF(variable_name = 'OPEN_TABLES', variable_value, 0)) /
             MAX(IF(variable_name = 'OPENED_TABLES', variable_value, 0)) * 100
            ) < 85
       THEN 'Warning'
       END AS STATUS
      ,'Percentage of tables currently open that have been opened' AS Description
  FROM information_schema.global_status
 WHERE variable_name IN ('OPEN_TABLES', 'OPENED_TABLES')
UNION ALL
SELECT 'Open Table' AS CATEGORY
      ,'Table Open Cache ratio' AS DIVISION
      ,round(s.variable_value / v.variable_value * 100, 2) AS CURRENT_PERCENT
      ,CASE 
       WHEN (s.variable_value / v.variable_value * 100
            ) > 95
       THEN 'Warning'
       END AS STATUS
      ,'Table Open Cache Utilization Rate' AS Description
  FROM information_schema.global_status s, information_schema.global_variables v
 WHERE s.variable_name IN ('OPEN_TABLES')
   AND v.variable_name IN ('TABLE_OPEN_CACHE')
UNION ALL
SELECT 'Open Files' AS CATEGORY
      ,'Open Files Ratio' AS DIVISION
      ,round(s.variable_value / v.variable_value * 100, 2) AS CURRENT_PERCENT
      ,CASE 
       WHEN (s.variable_value / v.variable_value * 100
            ) > 75
       THEN 'Warning'
       END AS STATUS
      ,'File Open Rate' AS Description
  FROM information_schema.global_status s, information_schema.global_variables v
 WHERE s.variable_name IN ('OPEN_FILES')
   AND v.variable_name IN ('OPEN_FILES_LIMIT')
;
