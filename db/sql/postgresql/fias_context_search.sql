CREATE EXTENSION pg_trgm;
CREATE INDEX i_fias_addrs_fullname ON fias_addrs USING gin (lower(fullname) gin_trgm_ops);
