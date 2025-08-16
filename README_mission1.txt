SQL Lab - Mission 1 (Beginner-Friendly)

Files:
- auth_logs.csv
- known_bad_ips.csv
- setup_sqlite.sql

Setup:
1) Create DB & schema:
   sqlite3 security_lab.db < setup_sqlite.sql

2) Import CSVs (inside sqlite prompt):
   .mode csv
   .import auth_logs.csv auth_logs
   .import known_bad_ips.csv known_bad_ips

3) Verify:
   .headers on
   .mode column
   SELECT COUNT(*) FROM auth_logs;
   SELECT COUNT(*) FROM known_bad_ips;

Common path import (optional):
   .mode csv
   .import '/Users/your_user/cybersecurity/sql/mission_1/auth_logs.csv' auth_logs
   .import '/Users/your_user/cybersecurity/sql/mission_1/known_bad_ips.csv' known_bad_ips

Happy hunting!
