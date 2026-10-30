-- =====================================================================
--  ScriptWell : master install script
--  Run as the application user, e.g.
--    sqlplus scriptwell/scriptwell@//localhost:1521/FREEPDB1 @00_install.sql
--  (In SQL Developer: open this file and press F5 "Run Script")
-- =====================================================================
SET DEFINE OFF
SET SERVEROUTPUT ON
WHENEVER SQLERROR CONTINUE

@@01_schema.sql
@@02_functions.sql
@@03_packages.sql
@@04_triggers.sql
@@05_seed.sql

PROMPT
PROMPT ==== Objects with compilation errors (should be none) ====
SELECT name, type, line, text FROM user_errors ORDER BY name, sequence;

PROMPT ==== Row counts ====
SELECT 'categories' tbl, COUNT(*) cnt FROM categories UNION ALL
SELECT 'books',  COUNT(*) FROM books  UNION ALL
SELECT 'users',  COUNT(*) FROM users  UNION ALL
SELECT 'orders', COUNT(*) FROM orders;
