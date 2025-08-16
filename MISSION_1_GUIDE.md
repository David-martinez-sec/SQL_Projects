# Mission 1 — Full Guide (Auth Log Triage)

You’re a junior SOC analyst investigating suspicious logins. This guide explains **what each step does and why**, with troubleshooting and quality-of-life tips.

---

## Contents
- `auth_logs.csv` — synthetic login events: `event_id, timestamp, username, ip_address, success`
- `known_bad_ips.csv` — small threat list: `ip_address, source, confidence`
- `setup_sqlite.sql` — schema + indexes (timestamp, username, ip_address)
- *(local only)* `security_lab.db` — your SQLite database

---

## Setup

### 1) Create DB & tables
```bash
sqlite3 security_lab.db < setup_sqlite.sql
```
**Why:** Feeds the schema file into SQLite to create the tables and indexes.

### 2) Import CSVs (choose ONE method)

**Method A — Header-safe (works everywhere):**
```bash
tail -n +2 auth_logs.csv > auth_logs_nh.csv
tail -n +2 known_bad_ips.csv > known_bad_ips_nh.csv

sqlite3 security_lab.db <<'SQL'
.mode csv
.import auth_logs_nh.csv auth_logs
.import known_bad_ips_nh.csv known_bad_ips
SQL
```

**Method B — Newer SQLite (>= 3.32) with `--skip 1`:**
```bash
sqlite3 security_lab.db <<'SQL'
.mode csv
.import --skip 1 auth_logs.csv auth_logs
.import --skip 1 known_bad_ips.csv known_bad_ips
SQL
```

### 3) Verify
```sql
.headers on
.mode column
SELECT COUNT(*) AS rows_auth FROM auth_logs;
SELECT COUNT(*) AS rows_bad  FROM known_bad_ips;
```

---

## Why these steps?
- **`.mode csv`** tells the SQLite shell how to parse input.
- **`.import`** loads rows from a CSV into a table.
- We index **timestamp**, **username**, and **ip_address** because hunts often filter/aggregate on these columns.

---

## Mission Queries (with explanations)

### A) Recent failed logins — *surface active brute force*
```sql
SELECT event_id, timestamp, username, ip_address
FROM auth_logs
WHERE success = 0
ORDER BY timestamp DESC
LIMIT 20;
```
- **What:** Failed attempts, newest first.
- **Why:** Check if failures cluster in time or target specific users.

### B) Users with most failures — *identify targeted/weak accounts*
```sql
SELECT username, COUNT(*) AS failed_attempts
FROM auth_logs
WHERE success = 0
GROUP BY username
ORDER BY failed_attempts DESC;
```
- **What:** Aggregates failures per user.
- **Why:** Accounts at the top may need MFA review or password reset.

### C) Noisiest IPs — *find scanners or automated attacks*
```sql
SELECT ip_address, COUNT(*) AS attempts
FROM auth_logs
GROUP BY ip_address
ORDER BY attempts DESC
LIMIT 10;
```
- **What:** Counts all attempts per IP.
- **Why:** Very “chatty” IPs are often brute-forcers or scripted probes.

### D) Cross-check with known bad IPs — *correlate external intel*
```sql
SELECT a.ip_address,
       COUNT(*) AS total_attempts,
       kb.source,
       kb.confidence
FROM auth_logs AS a
LEFT JOIN known_bad_ips AS kb
  ON a.ip_address = kb.ip_address
GROUP BY a.ip_address
ORDER BY total_attempts DESC
LIMIT 10;
```
- **What:** Joins your logs to the intel list.
- **Why:** Prioritize triage for IPs that are both noisy **and** known-bad.

> Swap `LEFT JOIN` for `INNER JOIN` if you only want IPs that appear in the bad list.

---

## Quality-of-life in the SQLite shell
Run these each session:
```sql
.headers on
.mode column
.timer on      -- show query durations
```
Inspect structure:
```sql
.schema
```
Export results to CSV:
```sql
.once results.csv
SELECT * FROM auth_logs LIMIT 50;
```

---

## Troubleshooting

**Headers got imported as data?**  
- Re-import using the header-safe method (strip headers), or delete the bad row:
```sql
DELETE FROM auth_logs WHERE event_id = 'event_id';
DELETE FROM known_bad_ips WHERE ip_address = 'ip_address';
```

**“no such table”**  
- The schema step didn’t run; re-run:
```bash
sqlite3 security_lab.db < setup_sqlite.sql
```

**Slow queries**  
- Indexes are included, but if you changed the schema, re-create them:
```sql
CREATE INDEX IF NOT EXISTS idx_auth_ts ON auth_logs(timestamp);
CREATE INDEX IF NOT EXISTS idx_auth_user ON auth_logs(username);
CREATE INDEX IF NOT EXISTS idx_auth_ip ON auth_logs(ip_address);
```

---

## What you’re practicing
- Reading and writing practical SQL for security
- Aggregation and grouping to detect anomalies
- Joining internal logs with external intel
- Thinking like a SOC analyst while querying

*All data here is synthetic and safe to publish.*
