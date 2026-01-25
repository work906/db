-------------------------------
-- テーブルスペース追加/削除
-------------------------------
-- 新規テーブルスペース作成
CREATE TABLESPACE MYSPACE
DATAFILE '/opt/oracle/oradata/XE/XEPDB1/MYSPACE01.dbf'
SIZE 4G
AUTOEXTEND ON
NEXT 100M
MAXSIZE 4G;

-- デーファイル追加
ALTER TABLESPACE MYSPACE
ADD DATAFILE '/opt/oracle/oradata/XE/XEPDB1/MYSPACE03.dbf'
SIZE 3G
AUTOEXTEND ON
NEXT 100M
MAXSIZE 3G;


-- テーブルスペース削除(データファイルも併せて削除)
DROP TABLESPACE MYSPACEIDX INCLUDING CONTENTS AND DATAFILES;

-- データファイルのみ削除
ALTER TABLESPACE ts1 DROP DATAFILE '/u01/oradata/ts1_02.dbf';


--------------------------------
-- テーブルスペースの容量確認
--------------------------------
SELECT
  ts.tablespace_name
  , ROUND(SUM(df.maxbytes) / 1024 / 1024) AS max#mb# -- テーブルスペースが拡張できる最大サイズ(dbfの最大サイズ)
  , ROUND(SUM(df.bytes) / 1024 / 1024) AS current#mb# -- テーブルスペースの確保領域
  , ROUND(SUM(df.user_bytes) / 1024 / 1024) AS usable#mb# -- データの格納に使える領域(USER_BYTES ＝ BYTES － ファイルヘッダ領域)
  , ROUND(NVL(seg.used_bytes, 0) / 1024 / 1024) AS segment_used#mb# -- 使用済領域
  , ROUND(NVL(free.free_bytes, 0) / 1024 / 1024) AS free#mb# -- 未使用領域(完全に未使用)
  , ROUND(SUM(df.maxbytes - df.bytes) / 1024 / 1024) AS autoextend_left#mb# -- 拡張可能領域
FROM
  dba_tablespaces ts
  LEFT JOIN dba_data_files df 
    ON ts.tablespace_name = df.tablespace_name 
  LEFT JOIN ( 
    SELECT
      tablespace_name
      , SUM(bytes) used_bytes 
    FROM
      dba_segments 
    GROUP BY
      tablespace_name
  ) seg 
    ON ts.tablespace_name = seg.tablespace_name 
  LEFT JOIN ( 
    SELECT
      tablespace_name
      , SUM(bytes) free_bytes 
    FROM
      dba_free_space 
    GROUP BY
      tablespace_name
  ) free 
    ON ts.tablespace_name = free.tablespace_name 
GROUP BY
  ts.tablespace_name
  ,seg.used_bytes
  ,free.free_bytes
ORDER BY
  ts.tablespace_name;

--------------------------------
-- データファイル
--------------------------------
select
   file_name
  ,file_id
  ,tablespace_name
  ,autoextensible
  ,blocks
  ,user_blocks
  ,round(maxbytes / 1024 / 1024) as MAXBYTES#MB# -- テーブルスペースが拡張できる最大サイズ(dbfの最大サイズ)
  ,round(bytes / 1024 / 1024) as BYTES#MB#　-- テーブルスペースの確保領域
  ,round((user_bytes / 1024 / 1024)) as USER_BYTES#MB# -- データの格納に使える領域(USER_BYTES ＝ BYTES － ファイルヘッダ領域)
  ,round((maxbytes - user_bytes) / 1024 / 1024) as autoextend_left#MB#　-- 拡張可能領域
from DBA_DATA_FILES;


--------------------------------
-- セグメント使用量
--------------------------------
-- セグメントの容量
-- テーブルとインデックスの使用量を見れば、どのくらい領域を使っているかわかる
-- データファイルのUSER_BYTES#MB#が限界値のため、テーブルとインデックスの使用量を足せば、
-- あとどのくらい使えるかはわかりそう。
select
   owner
  ,segment_name
  ,partition_name
  ,segment_type
  ,tablespace_name
  ,(bytes / 1024 / 1024) as BYTES#MB#　-- 現在の使用量
  ,blocks -- 使用中のブロック数
  ,extents -- 使用中のエクステント数
from DBA_SEGMENTS
--where tablespace_name like '%UNDO%';
where owner = 'SYSTEM';
--where segment_name like '%MANY_DATA_TABLE%';

-- セグメントタイプでの合計値
-- こっちのほうがセグメントごとの合計値は見やすい
select
   owner
  ,partition_name
  ,segment_type
  ,tablespace_name
  ,(sum(bytes) / 1024 / 1024) as BYTES#MB#
  ,sum(blocks)
  ,sum(extents)
from DBA_SEGMENTS
where owner = 'SYSTEM'
group by
   owner
  ,partition_name
  ,segment_type
  ,tablespace_name
;

select
  tablespace_name
  ,round((sum(bytes) / 1024 / 1024)) as BYTES#MB#
  ,sum(blocks)
  ,sum(extents)
from DBA_SEGMENTS
where owner = 'SYSTEM'
group by
  tablespace_name
;



--------------------------------
-- エクステントから容量計算
--------------------------------
-- セグメント毎の合計値
-- セグメントから確認した内容と変わらない(はず)
select
   owner
  ,segment_name
  ,partition_name
  ,segment_type
  ,tablespace_name
  ,round((sum(bytes) / 1024 / 1024)) as BYTES#MB# -- 現在の使用量
  ,sum(blocks) as blocks　-- 現在の使用ブロック数
  ,count(1) as extent_total -- 現在の使用エクステント数
from DBA_EXTENTS
where owner = 'SYSTEM'
group by
   owner
  ,segment_name
  ,partition_name
  ,segment_type
  ,tablespace_name
;

select
   owner
  ,partition_name
  ,segment_type
  ,tablespace_name
  ,round((sum(bytes) / 1024 / 1024)) as BYTES#MB# -- 現在の使用量
  ,sum(blocks) as blocks　-- 現在の使用ブロック数
  ,count(1) as extent_total -- 現在の使用エクステント数
from DBA_EXTENTS
where owner = 'SYSTEM'
group by
   owner
  ,partition_name
  ,segment_type
  ,tablespace_name
;

-- tablespace毎の合計値
select
   tablespace_name
  ,round((sum(bytes) / 1024 / 1024)) as BYTES#MB# -- 現在の使用量
  ,sum(blocks) as blocks -- 現在の使用ブロック数
  ,count(1) as extent_total -- 現在の使用エクステント数
from DBA_EXTENTS
group by tablespace_name
;


