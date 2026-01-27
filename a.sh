#!/bin/bash

function execute_sql() {

RESULT=$(sqlplus -s SYSTEM/password123456@//localhost:1521/XEPDB1 <<'EOF'
WHENEVER SQLERROR EXIT 100
WHENEVER OSERROR  EXIT 200
set echo off feedback off heading off pagesize 0 verify off
set serveroutput on

VAR v_result VARCHAR2(200)
VAR rc NUMBER
BEGIN
  EXECUTE IMMEDIATE 'delete from aaaaa';

  :rc := 0;
EXCEPTION
  WHEN OTHERS THEN
    :v_result := SQLERRM;
    :rc := 1;

END;
/
PRINT v_result
EXIT :rc
EOF
)
exitcode=$?

printf '%s\n' "$RESULT"

return $exitcode
}

result=$(execute_sql)
echo "exit $?"
echo "result=$result"
