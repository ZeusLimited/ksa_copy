COPY fias_addrs(aoid, aoguid, parentguid, previd, nextid, aolevel, formalname, offname, shortname, okato, oktmo, regioncode, postalcode, actstatus)
  FROM '/home/deployer/fias/addrobj1251.csv' WITH CSV DELIMITER ';' ENCODING 'windows-1251' QUOTE '$' ESCAPE '$';

COPY fias_houses(aoguid,houseguid,houseid,buildnum,housenum,okato,oktmo,postalcode,strucnum,enddate)
  FROM '/home/deployer/fias/houses1251.csv' WITH CSV DELIMITER ';' ENCODING 'windows-1251' QUOTE '$' ESCAPE '$';
