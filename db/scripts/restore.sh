# This file should be placed at the PostgreSQL Server

/usr/pgsql-10/bin/pg_restore --clean -v -j 4 -F d -d raoesv -U postgres $1
