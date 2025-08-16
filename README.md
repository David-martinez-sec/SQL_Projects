# SQL Cybersecurity Lab — Mission 1

Beginner-friendly SQL lab: triage auth logs, spot brute force, and cross-check a small threat feed.

## Files
- `auth_logs.csv` — simulated auth events
- `known_bad_ips.csv` — threat intel (tiny sample)
- `setup_sqlite.sql` — schema + indexes
- *(local)* `security_lab.db` (created on your machine; not tracked)

## Quick Start
```bash
sqlite3 security_lab.db < setup_sqlite.sql

# Import (header-safe, works everywhere)
tail -n +2 auth_logs.csv > auth_logs_nh.csv
tail -n +2 known_bad_ips.csv > known_bad_ips_nh.csv

sqlite3 security_lab.db <<'SQL'
.mode csv
.import auth_logs_nh.csv auth_logs
.import known_bad_ips_nh.csv known_bad_ips
SQL
```

## Verify (inside sqlite)
```sql
.headers on
.mode column
SELECT COUNT(*) AS rows_auth FROM auth_logs;
SELECT COUNT(*) AS rows_bad  FROM known_bad_ips;
```

## Mission Queries (see full guide for explanations)
A) Recent failed logins
```sql
SELECT event_id,timestamp,username,ip_address
FROM auth_logs
WHERE success=0
ORDER BY timestamp DESC
LIMIT 20;
```

B) Users with most failures
```sql
SELECT username,COUNT(*) AS failed_attempts
FROM auth_logs
WHERE success=0
GROUP BY username
ORDER BY failed_attempts DESC;
```

C) Noisiest IPs
```sql
SELECT ip_address,COUNT(*) AS attempts
FROM auth_logs
GROUP BY ip_address
ORDER BY attempts DESC
LIMIT 10;
```

D) Cross-check with bad IPs
```sql
SELECT a.ip_address,COUNT(*) AS total_attempts,kb.source,kb.confidence
FROM auth_logs a
LEFT JOIN known_bad_ips kb ON a.ip_address=kb.ip_address
GROUP BY a.ip_address
ORDER BY total_attempts DESC
LIMIT 10;
```

➡️ For detailed context, troubleshooting, and export tips, see **MISSION_1_GUIDE.md**.
