CREATE INDEX i_fias_addrs_region ON fias_addrs USING hash (regioncode);
CREATE INDEX i_fias_addrs_aoguid ON fias_addrs(aoguid) where actstatus = 't';
CREATE INDEX i_fias_addrs_parentguid ON fias_addrs(parentguid);


CREATE EXTENSION IF NOT EXISTS pg_trgm;
ALTER EXTENSION pg_trgm SET SCHEMA public;

CREATE INDEX i_fias_addrs_fullname ON fias_addrs USING GIN (lower(fullname) gin_trgm_ops);
