set client_min_messages to NOTICE;

-- 2 way join
select * from readable_measure_query_times('select * from t1 a, t1 b where a.a = b.a', 10);
set enable_partitionwise_join to false;
select * from readable_measure_query_times('select * from t1_parted a, t1_parted b where a.a = b.a', 10);
set enable_partitionwise_join to true;
select * from readable_measure_query_times('select * from t1_parted a, t1_parted b where a.a = b.a', 10);

-- 3 way join
select * from readable_measure_query_times('select * from t1 a, t1 b, t1 c where a.a = b.a and b.a = c.a', 10);
set enable_partitionwise_join to false;
select * from readable_measure_query_times('select * from t1_parted a, t1_parted b, t1_parted c where a.a = b.a and b.a = c.a', 10);
set enable_partitionwise_join to true;
select * from readable_measure_query_times('select * from t1_parted a, t1_parted b, t1_parted c where a.a = b.a and b.a = c.a', 10);

-- 4 way join
select * from readable_measure_query_times('select * from t1 a, t1 b, t1 c, t1 d where a.a = b.a and b.a = c.a and c.a = d.a', 10);
set enable_partitionwise_join to false;
select * from readable_measure_query_times('select * from t1_parted a, t1_parted b, t1_parted c, t1_parted d where a.a = b.a and b.a = c.a and c.a = d.a', 10);
set enable_partitionwise_join to true;
select * from readable_measure_query_times('select * from t1_parted a, t1_parted b, t1_parted c, t1_parted d where a.a = b.a and b.a = c.a and c.a = d.a', 10);

-- 5 way join
select * from readable_measure_query_times('select * from t1 a, t1 b, t1 c, t1 d, t1 e where a.a = b.a and b.a = c.a and c.a = d.a and d.a = e.a', 10);
set enable_partitionwise_join to false;
select * from readable_measure_query_times('select * from t1_parted a, t1_parted b, t1_parted c, t1_parted d, t1_parted e where a.a = b.a and b.a = c.a and c.a = d.a and d.a = e.a', 10);
set enable_partitionwise_join to true;
select * from readable_measure_query_times('select * from t1_parted a, t1_parted b, t1_parted c, t1_parted d, t1_parted e where a.a = b.a and b.a = c.a and c.a = d.a and d.a = e.a', 10);
