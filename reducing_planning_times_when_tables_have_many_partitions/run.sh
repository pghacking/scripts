#!/usr/bin/bash

STUDENT_TABLE=students
SCORE_TABLE=scores
GPA_TABLE=gpas

for i in $(seq 0 10); do
    PARTITION_NUM=$((2**$i))
    psql > /dev/null 2>&1 << EOF
DROP TABLE IF EXISTS $STUDENT_TABLE;
DROP TABLE IF EXISTS $SCORE_TABLE;
DROP TABLE IF EXISTS $GPA_TABLE;
CREATE TABLE $STUDENT_TABLE(id int, name text) PARTITION BY RANGE (id);
CREATE TABLE $SCORE_TABLE(student_id int, course int, score int) PARTITION BY RANGE (student_id);
CREATE TABLE $GPA_TABLE(student_id int, gpa double precision) PARTITION BY RANGE (student_id);
EOF

    for j in $(seq 0 $(($PARTITION_NUM-1))); do
        psql > /dev/null 2>&1 << EOF
CREATE TABLE child_${j}_of_students PARTITION OF students FOR VALUES FROM (${j} * 100) TO ((${j} + 1) * 100);
CREATE TABLE child_${j}_of_scores PARTITION OF scores FOR VALUES FROM (${j} * 100) TO ((${j} + 1) * 100);
CREATE TABLE child_${j}_of_gpas PARTITION OF gpas FOR VALUES FROM (${j} * 100) TO ((${j} + 1) * 100);
EOF
    done

    data_num=$((PARTITION_NUM*100-1))
    psql > /dev/null 2>&1 << EOF
INSERT INTO students SELECT id, md5(id::text) FROM generate_series(0, $data_num) AS id;
INSERT INTO scores SELECT student_id, course, (random() * 100)::int FROM generate_series(0, $data_num) AS student_id, generate_series(1, 4) AS course;
INSERT INTO gpas SELECT student_id, random() * 5 FROM generate_series(0, $data_num) AS student_id;

ALTER TABLE students ADD PRIMARY KEY (id);
CREATE INDEX ON scores (student_id);
ALTER TABLE gpas ADD PRIMARY KEY (student_id);

ANALYZE students;
ANALYZE scores;
ANALYZE gpas;
EOF
    echo "partition number: " $PARTITION_NUM
    pgbench -n -T 10 -f query.sql
    echo ""
done
