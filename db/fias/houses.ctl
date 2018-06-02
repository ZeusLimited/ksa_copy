LOAD DATA
INFILE 'houses1251.csv'
INTO TABLE FIAS_HOUSES TRUNCATE
FIELDS TERMINATED BY ';;' TRAILING NULLCOLS
(
aoguid "hextoraw(replace(:aoguid,'-',''))",
houseguid "hextoraw(replace(:houseguid,'-',''))",
houseid "hextoraw(replace(:houseid,'-',''))",
buildnum,
housenum,
okato,
oktmo,
postalcode,
strucnum,
enddate "to_date(:enddate, 'YYYYMMDD')",
fullnum "trim(:housenum || nvl2(:buildnum,' корпус ' || :buildnum,'') || nvl2(:strucnum,' строение ' || :strucnum,''))"
)
