#!/usr/bin/bash

TABLE_NAME=test_table

psql > /dev/null 2>&1 << EOF
CREATE OR REPLACE FUNCTION create_table_cols(tabname text, num_cols int)
RETURNS VOID AS
\$\$
DECLARE
  query text;
BEGIN
  query := 'CREATE UNLOGGED TABLE ' || tabname || ' (';
  FOR i IN 1..num_cols LOOP
    query := query || 'a_' || i::text || ' int default 1';
    IF i != num_cols THEN
      query := query || ', ';
    END IF;
  END LOOP;
  query := query || ')';
  EXECUTE format(query);
END
\$\$ LANGUAGE plpgsql;
CREATE EXTENSION IF NOT EXISTS pg_prewarm;
EOF

for c in $(seq 10 10); do
	for rows in $(seq 1 5); do
		psql > /dev/null 2>&1 << EOF
DROP TABLE IF EXISTS $TABLE_NAME;
SELECT create_table_cols ('$TABLE_NAME', $c);
INSERT INTO $TABLE_NAME(a_1) SELECT ii FROM generate_series(1, $rows * 1000000) ii;
SELECT pg_prewarm('$TABLE_NAME');
EOF
		echo "columns" $c "rows" $rows"M"
		pgbench -n -t 100 -f query.sql
		pgbench -n -t 100 -f query_with_qual.sql
		echo ""
	done
done

