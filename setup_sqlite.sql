-- Beginner SQL Cybersecurity Lab Setup (SQLite)
-- Run in a terminal: sqlite3 security_lab.db < setup_sqlite.sql
PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS auth_logs;
CREATE TABLE auth_logs (
  event_id    INTEGER PRIMARY KEY,
  timestamp   TEXT NOT NULL,           -- ISO 'YYYY-MM-DD HH:MM:SS'
  username    TEXT NOT NULL,
  ip_address  TEXT NOT NULL,
  success     INTEGER NOT NULL CHECK (success IN (0,1))
);

-- To import CSV via sqlite3 shell:
-- .mode csv
-- .import auth_logs.csv auth_logs

DROP TABLE IF EXISTS known_bad_ips;
CREATE TABLE known_bad_ips (
  ip_address TEXT PRIMARY KEY,
  source     TEXT,
  confidence INTEGER
);

-- .mode csv
-- .import known_bad_ips.csv known_bad_ips

-- Helpful indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_auth_ts ON auth_logs(timestamp);
CREATE INDEX IF NOT EXISTS idx_auth_user ON auth_logs(username);
CREATE INDEX IF NOT EXISTS idx_auth_ip ON auth_logs(ip_address);
