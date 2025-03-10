#!/usr/bin/bash

TABLE_NAME=test_table
INDEX1_NAME=test_table_idx_num
INDEX2_NAME=test_table_idx_num_category

psql > /dev/null 2>&1 << EOF
CREATE EXTENSION IF NOT EXISTS pg_prewarm;
EOF

for rows in $(seq 1 5); do
	psql > /dev/null 2>&1 << EOF
DROP TABLE IF EXISTS $TABLE_NAME;
CREATE TABLE $TABLE_NAME(id SERIAL PRIMARY KEY, num INT NOT NULL, category TEXT);
INSERT INTO $TABLE_NAME(num, category) SELECT random() * 1000, CASE WHEN random() < 0.5 THEN 'A' ELSE 'B' END FROM generate_series(1, $rows * 1000000);
ANALYZE $TABLE_NAME;
CREATE INDEX $INDEX1_NAME ON $TABLE_NAME(num);
CREATE INDEX $INDEX2_NAME ON $TABLE_NAME(num, category);
SELECT pg_prewarm('$TABLE_NAME');
SELECT pg_prewarm('$INDEX1_NAME');
SELECT pg_prewarm('$INDEX2_NAME');
EOF
	echo "rows" $rows"M"
	pgbench -n -t 100 -f query.sql
	pgbench -n -t 100 -f query_with_qual.sql
	echo ""
done

