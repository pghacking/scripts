#!/usr/bin/bash

TABLE_NAME=test_table

psql > /dev/null 2>&1 << EOF
CREATE OR REPLACE FUNCTION create_table_cols(tabname text, num_cols int)
RETURNS VOID AS
$func$
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
$func$ LANGUAGE plpgsql;
CREATE EXTENSION IF NOT EXISTS pg_prewarm;
EOF

for c in $(seq 5 5 30); do
	for rows in $(seq 1 10); do
		psql > /dev/null 2>&1 << EOF
DROP TABLE IF EXISTS $TABLE_NAME;
SELECT create_table_cols ('$TABLE_NAME', $c);
INSERT INTO $TABLE_NAME SELECT FROM generate_series(1, $rows * 1000000);
SELECT pg_prewarm('$TABEL_NAME');
EOF
		# run select count(*) 10x
		for r in $(seq 1 10); do
			s=$(psql -t -A -c "SELECT EXTRACT(EPOCH FROM now())")
			psql -c "SELECT count(*) from $TABLE_NAME" > /dev/null 2>&1
			d=$(psql -t -A -c "SELECT 1000 * (EXTRACT(EPOCH FROM now()) - $s)")
			echo "columns" $c "rows" $rows"M" $r $d
		done
	done
done

