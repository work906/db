/*-------------------------------
 * テーブル/ビュー/インデックス
 *-------------------------------*/
 -- テーブル
select owner, table_name, tablespace_name, status, avg_row_len, sample_size, logging, backed_up, num_rows, blocks, last_analyzed, partitioned
from DBA_TABLES
where TABLE_NAME = 'MANY_DATA_TABLE';

-- インデックス名・その他情報
select * from USER_INDEXES;
-- インデックスに使用されているカラム
select * from USER_IND_COLUMNS;

-- ビュー定義
select * from USER_VIEWS;

-- シーケンス
select * from USER_SEQUENCES;

-- シノニム
select * from USER_SYNONYMS;

/*-------------------------------
 * 領域
 *-------------------------------*/
-- テーブルスペース
select tablespace_name, block_size, round(max_extents / 1024 /1024) as max_extents#MB#, round(max_size / 1024 / 1024) as max_size#MB#, status, contents, logging, retention, bigfile
from DBA_TABLESPACES;

-- データファイル
select file_name, file_id, tablespace_name, round(bytes / 1024 / 1024) as BYTES#MB#, blocks, status, autoextensible, round(maxbytes / 1024 / 1024) as MAXBYTES#MB#, (user_bytes / 1024 / 1024) as USER_BYTES#MB#, user_blocks, online_status
from DBA_DATA_FILES;

-- セグメント使用量
select owner, segment_name, partition_name, segment_type, tablespace_name, (bytes / 1024 / 1024) as BYTES#MB#, blocks, extents, max_extents, max_size, buffer_pool
from DBA_SEGMENTS
--where segment_name = 'MANY_DATA_TABLE';
where segment_name like '%SYSSMU1%';

-- エクステント
select owner, segment_name, partition_name, segment_type, tablespace_name, extent_id, file_id, block_id, (bytes / 1024 / 1024) as BYTES#MB#, blocks
from DBA_EXTENTS
where segment_name = 'MANY_DATA_TABLE';

-- テーブルスペースの完全な空き領域
select tablespace_name, file_id, block_id, (bytes / 1024 / 1024) as BYTES#MB#, blocks
from DBA_FREE_SPACE
where TABLESPACE_NAME = 'SYSTEM';



/*-------------------------------
 * 統計情報
 *-------------------------------*/
-- カラム統計
select owner, table_name, column_name, num_distinct, last_analyzed, global_stats, user_stats
from DBA_TAB_COL_STATISTICS
where table_name = 'MANY_DATA_TABLE';
-- インデックス統計
select owner, index_name, index_type, table_owner, table_name, uniqueness, tablespace_name, max_extents, logging, blevel, leaf_blocks, distinct_keys, num_rows, last_analyzed, partitioned, generated, buffer_pool, global_stats, user_stats, visibility, segment_created
from DBA_INDEXES
where table_name = 'MANY_DATA_TABLE';

/*-------------------------------
 * バックアップ
 *-------------------------------*/
select * from V$BACKUP;
select * from V$ARCHIVED_LOG;

/*-------------------------------
 * REDO
 *-------------------------------*/
select * from V$LOG;
select * from V$LOGFILE order by GROUP#;

/*-------------------------------
 * UNDO領域
 *-------------------------------*/
-- 現在の使用状況
select * from V$TRANSACTION;
-- 時系列の消費
select * from V$UNDOSTAT v;
select * from V$TABLESPACE;
-- UNDO セグメント
select * from DBA_ROLLBACK_SEGS;
-- 設定
select * from V$PARAMETER;



/*-------------------------------
 * プロシージャ
 *-------------------------------*/
 -- プロシージャ全般
select * from DBA_OBJECTS;
-- トリガー
select owner, trigger_name, trigger_type, triggering_event, table_owner, base_object_type, table_name, column_name, status, description, action_type, trigger_body
from DBA_TRIGGERS where table_name = 'MANY_DATA_TABLE';

-- 依存関係
select * from DBA_DEPENDENCIES;

-- ソース
select * from DBA_SOURCE;

-- 実行権限
select * from DBA_TAB_PRIVS;


/*-------------------------------
 * レプリケーション
 *-------------------------------*/
 /*
  * Data Guard
  */
 -- 設定有無
SELECT database_role, open_mode
FROM   v$database;

-- レプリケーションの送信先
SELECT *
FROM v$archive_dest WHERE status = 'VALID';

 /*
  * Golden Gate
  */
-- 設定有無
SELECT * FROM dba_capture;
SELECT * FROM dba_apply;

 /*
  * Streams
  */
SELECT *
FROM dba_streams_configuration;

/*
 * マテリアライズドビューによるレプリケーション
 */
-- 設定有無(M<ASTER_LINKがあれば別DBから複製している)
SELECT owner, mview_name, master_link
FROM   dba_mviews;

-- マスタ側
SELECT * FROM dba_mview_logs;

