----------------
-- Extensions --
----------------

-- Geospatial
CREATE EXTENSION IF NOT EXISTS postgis;

-- Timeseries
CREATE EXTENSION IF NOT EXISTS timescaledb;

-- Vector
CREATE EXTENSION IF NOT EXISTS vector;

-- Graph / Cypher
CREATE EXTENSION IF NOT EXISTS age;

-- Hyper log log
CREATE EXTENSION IF NOT EXISTS hll;

-- Machine learning
CREATE EXTENSION IF NOT EXISTS pgml;

-- Oldschool uuid, todo, upgrade to allow uuid v6 or v7
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Standard extensions
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- apache age requires ag_catalog on search path
SET search_path = ag_catalog, "$user", public;

-- Speed up; see: https://github.com/pgvector/pgvector#exact-search
SET max_parallel_workers_per_gather = 4;
