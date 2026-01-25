----------------------------------------
----------------------------------------
-- パーティション化するときはインデックスの設計をやり直す必要がある。
-- グローバルインデックスはパーティションドロップで壊れる。
-- 他にもいくつも注意点がありそうなので、
-- パーティション導入するときは結構検討が必要そう。
----------------------------------------
----------------------------------------

----------------------------------------
-- CTAS①
-- パーティションあり(文字列)
----------------------------------------
CREATE TABLE many_data_table_dest
PARTITION BY RANGE (create_date)
(
  PARTITION p20150101 VALUES LESS THAN ('20150101'),
  PARTITION p20150201 VALUES LESS THAN ('20150201'),
  PARTITION p20150301 VALUES LESS THAN ('20150301'),
  PARTITION pmax VALUES LESS THAN (MAXVALUE)
)
TABLESPACE MYSPACE
NOLOGGING /* これは本番は怖い */
PARALLEL 2
AS
SELECT * /*+ PARALLEL(many_data_table 2) */
FROM many_data_table
where
  create_date > '20141231'
;

ALTER TABLE many_data_table_dest SPLIT PARTITION pmax
AT ('20150501')
INTO(PARTITION p20150501, PARTITION pmax);


----------------------------------------
-- CTAS② (DATE interval Not Stored)
-- パーティションあり(DATEで作る。だが、自動で追加の仕組みはない)
----------------------------------------
CREATE TABLE many_data_table_dest
PARTITION BY RANGE (create_date_dt)
INTERVAL (NUMTOYMINTERVAL(1,'MONTH'))
(
  PARTITION p0 VALUES LESS THAN (DATE '2015-01-01')
)
TABLESPACE MYSPACE
NOLOGGING /* これは本番は怖い */
PARALLEL 2
AS
SELECT /*+ PARALLEL(many_data_table 2) */
  pk_id1,
  pk_id2,
  v001,
  v002,
  create_date,
  TO_DATE(create_date,'YYYYMMDD') AS create_date_dt
FROM many_data_table
where
  create_date > '20141231'
;

----------------------------------------
-- CTAS③ (DATE interval Stored or virtual)
-- パーティションあり(DATEで作る。自動追加の仕組みもある)
----------------------------------------
CREATE TABLE many_data_table_dest
(
  pk_id1        varchar2(5),
  pk_id2        varchar2(6),
  v001          varchar2(17),
  v002          varchar2(17),
  create_date   varchar2(8),

  create_date_dt DATE GENERATED ALWAYS AS
  (TO_DATE(create_date,'YYYYMMDD'))
  VIRTUAL
)
TABLESPACE MYSPACE
PARTITION BY RANGE (create_date_dt)
INTERVAL (NUMTOYMINTERVAL(1,'MONTH'))
(
  PARTITION p_start VALUES LESS THAN (DATE '2015-01-01')
)
;

insert /*+ APPEND PARALLEL(8) */
into many_data_table_dest (pk_id1,pk_id2,v001,v002,create_date)
select pk_id1,pk_id2,v001,v002,create_date
from many_data_table
where create_date > '20141231'
;

----------------------------------------
-- インデックス作成
----------------------------------------
インデックス作成も並列

----------------------------------------
-- インデックス並列解除
----------------------------------------
ALTER TABLE new_table NOPARALLEL;
ALTER INDEX idx1 NOPARALLEL;

