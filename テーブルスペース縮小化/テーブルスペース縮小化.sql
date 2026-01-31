------------------------------
-- テーブルスペース追加/削除
-------------------------------
-- 新規テーブルスペース作成(テーブル)
CREATE TABLESPACE MYTBLSPACE
DATAFILE '/opt/oracle/oradata/XE/XEPDB1/MYTBLSPACE01.dbf'
SIZE 2G
AUTOEXTEND OFF;
--MAXSIZE 2G;
--NEXT 100M


-- デーファイル追加
ALTER TABLESPACE MYTBLSPACE
ADD DATAFILE '/opt/oracle/oradata/XE/XEPDB1/MYTBLSPACE02.dbf'
SIZE 2G
AUTOEXTEND OFF;
--NEXT 100M
--MAXSIZE 2G;

-- 新規テーブルスペース作成(インデックス)
CREATE TABLESPACE MYIDXSPACE
DATAFILE '/opt/oracle/oradata/XE/XEPDB1/MYIDXSPACE01.dbf'
SIZE 2G
AUTOEXTEND OFF;
--NEXT 100M
--MAXSIZE 2G;

ALTER TABLESPACE MYIDXSPACE
ADD DATAFILE '/opt/oracle/oradata/XE/XEPDB1/MYIDXSPACE02.dbf'
SIZE 2G
AUTOEXTEND OFF;
--NEXT 100M
--MAXSIZE 2G;

-- テーブルスペース削除(データファイルも併せて削除)
DROP TABLESPACE MYTBLSPACE INCLUDING CONTENTS AND DATAFILES;

-- データファイルのみ削除
ALTER TABLESPACE MYSPACE DROP DATAFILE '/opt/oracle/oradata/XE/XEPDB1/MYSPACE03.dbf';

-- AUTOEXTEND切り替え
ALTER DATABASE DATAFILE
'/opt/oracle/oradata/XE/XEPDB1/MYTBLSPACE01.dbf'
AUTOEXTEND ON
MAXSIZE 2G;

----------------------------
-- dbfにエクステントあるか確認
----------------------------
SELECT *
FROM dba_extents
WHERE file_id = (
  SELECT file_id
  FROM dba_data_files
  WHERE file_name LIKE '%MYSPACE01.dbf%'
);

select
   *
from
  dba_extents extents
where
  rownum < 2;

select
   *
from
  dba_data_files
where
  rownum < 2;  


select
  *
from
  (
    select
      files.tablespace_name
     ,files.file_name
     ,extents.file_id
     ,extents.segment_name
     ,MAX(extents.block_id + extents.blocks - 1) as HWM
    from
      dba_data_files files
      left join dba_extents extents
        on  files.file_id = extents.file_id
    where
      files.tablespace_name = 'MYTBLSPACE'
    group by
       files.tablespace_name
      ,files.file_name
      ,extents.file_id
      ,extents.segment_name
  ) t
order by
    t.file_name
   ,t.hwm desc
;


----------------------------
-- RECYCLEBINに残っているとと縮小操作不可
-- (デッドロックエラーになる)
----------------------------
SHOW RECYCLEBIN;
SELECT object_name FROM user_recyclebin;

PURGE DBA_RECYCLEBIN;

 --------------------
 -- SHRINK,MOVE
 --------------------
-- MOVE
ALTER TABLE MANY_DATA_TABLE3 ENABLE ROW MOVEMENT;

-- SHRINK
ALTER TABLE MANY_DATA_TABLE2 SHRINK SPACE;

 --------------------
 -- RESIZE
 --------------------
 -- 使用中最大ブロック確認
SELECT MAX(block_id + blocks - 1) AS high_block
FROM dba_extents
WHERE file_id = '16';

-- ブロックサイズ確認
SELECT value FROM v$parameter WHERE name = 'db_block_size';

-- リサイズ
ALTER DATABASE DATAFILE
'/opt/oracle/oradata/XE/XEPDB1/MYTBLSPACE02.dbf'
RESIZE 360M;
