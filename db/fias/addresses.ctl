LOAD DATA
INFILE 'addrobj1251.csv'
INTO TABLE FIAS_ADDRS TRUNCATE
FIELDS TERMINATED BY ';;'
(
aoid "hextoraw(replace(:aoid,'-',''))",
aoguid "hextoraw(replace(:aoguid,'-',''))",
parentguid "hextoraw(replace(:parentguid,'-',''))",
previd "hextoraw(replace(:previd,'-',''))",
nextid "hextoraw(replace(:nextid,'-',''))",
aolevel,formalname,offname,shortname,okato,oktmo,regioncode,postalcode,actstatus
)
