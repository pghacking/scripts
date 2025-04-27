create or replace function create_partitioned_table(table_name varchar, num_parts integer)
returns integer
language plpgsql
as $$
declare
 cnt_part integer;
 part_name varchar;
 ddl_cmd varchar;
 num_values_per_part integer := 100;
 from_val integer := 0;
 to_val integer := from_val + num_values_per_part;
begin
 ddl_cmd := 'create table ' || table_name || '(a integer primary key, b integer) partition by range(a)';
 execute ddl_cmd;
 for cnt_part in 1 .. num_parts loop
  ddl_cmd := 'create table ' || table_name || '_p' || cnt_part || ' partition of ' || table_name ||
     ' for values from ( ' || from_val || ') to (' || to_val || ')';
  execute ddl_cmd;
  from_val := to_val;
  to_val := from_val + num_values_per_part;
 end loop;

 return num_parts;
end;
$$;

drop function measure_query_times;
drop function readable_measure_query_times;

create function measure_query_times(query text,
            num_samples int,
            out measurement varchar,
            out average float,
            out maximum float,
            out minimum float,
            out std_dev float)
returns setof record
language plpgsql
as $$
declare
 total_planning_time float := 0;
 total_execution_time float := 0;
 explain_query text := 'EXPLAIN (FORMAT JSON, MEMORY, SUMMARY, ANALYZE) ' || query;
 explain_out json;
 cnt int;
 stats_rec record;
begin
 -- executed query once to warm up caches before the actual run. XXX we might
 -- want to run it multiple times.
 execute explain_query into explain_out;

 -- table to collect samples
 create temporary table q_times(instance int, planning_time float, planning_memory_used bigint, planning_memory_alloced bigint, execution_time float);

 -- collect samples
 for cnt in 1..num_samples loop
  execute explain_query into explain_out;
  insert into q_times values (cnt,
         (explain_out->0->>'Planning Time')::float,
         (explain_out->0->'Planning'->>'Memory Used')::bigint,
         (explain_out->0->'Planning'->>'Memory Allocated')::bigint,
         (explain_out->0->>'Execution Time')::float);
 end loop;

 -- report statistics
 for stats_rec in
   with stats as
    (select avg(planning_time) pt_avg,
      min(planning_time) pt_min,
      max(planning_time) pt_max,
      stddev(planning_time) pt_sdev,
      avg(planning_memory_used) pmu_avg,
      min(planning_memory_used) pmu_min,
      max(planning_memory_used) pmu_max,
      stddev(planning_memory_used) pmu_sdev,
      avg(planning_memory_alloced) pma_avg,
      min(planning_memory_alloced) pma_min,
      max(planning_memory_alloced) pma_max,
      stddev(planning_memory_alloced) pma_sdev,
      avg(execution_time) et_avg,
      min(execution_time) et_min,
      max(execution_time) et_max,
      stddev(execution_time) et_sdev
     from q_times)
   select 'planning time'::varchar measurement, pt_avg average, pt_min minimum, pt_max maximum, pt_sdev std_dev from stats
    union all
   select 'planning memory used'::varchar measurement, pmu_avg average, pmu_min minimum, pmu_max maximum, pmu_sdev std_dev from stats
    union all
   select 'planning memory alloc'::varchar measurement, pma_avg average, pma_min minimum, pma_max maximum, pma_sdev std_dev from stats
    union all
   select 'execution time'::varchar measurement, et_avg average, et_min minimum, et_max maximum, et_sdev std_dev from stats
  loop
   measurement := stats_rec.measurement;
   average := stats_rec.average;
   minimum := stats_rec.minimum;
   maximum := stats_rec.maximum;
   std_dev := stats_rec.std_dev;
   return next;
 end loop;
 drop table q_times;
end;
$$;

create function readable_measure_query_times(query text, num_samples int,
            out measurement varchar,
            out average text,
            out maximum text,
            out minimum text,
            out std_dev text,
            out std_dev_as_perc_of_avg text)
returns setof record
language SQL
as $$
 select measurement,
   average::numeric(42, 2),
   maximum::numeric(42, 2),
   minimum::numeric(42, 2),
   std_dev::numeric(42, 2),
   (std_dev/average*100)::numeric(42,2) || '%' "std_dev perc of average"
   from measure_query_times(query, num_samples);
$$;

drop table t1, t1_parted;

create table t1 (a integer primary key, b integer);
select create_partitioned_table('t1_parted', 1000);
