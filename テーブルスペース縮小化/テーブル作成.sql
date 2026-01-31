CREATE TABLE many_data_table1
(
 pk_id1        varchar2(5),
 pk_id2        varchar2(6),
 v001          varchar2(17),
 v002          varchar2(17),
 create_date   varchar2(8),
 CONSTRAINT many_data_table1_pk PRIMARY KEY(pk_id1, pk_id2)
 USING INDEX TABLESPACE MYIDXSPACE
)
TABLESPACE MYTBLSPACE;

CREATE TABLE many_data_table2
(
 pk_id1        varchar2(5),
 pk_id2        varchar2(6),
 v001          varchar2(17),
 v002          varchar2(17),
 create_date   varchar2(8),
 CONSTRAINT many_data_table2_pk PRIMARY KEY(pk_id1, pk_id2)
 USING INDEX TABLESPACE MYIDXSPACE
)
TABLESPACE MYTBLSPACE;

CREATE TABLE many_data_table3
(
 pk_id1        varchar2(5),
 pk_id2        varchar2(6),
 v001          varchar2(17),
 v002          varchar2(17),
 create_date   varchar2(8),
 CONSTRAINT many_data_table3_pk PRIMARY KEY(pk_id1, pk_id2)
 USING INDEX TABLESPACE MYIDXSPACE
)
TABLESPACE MYTBLSPACE;
