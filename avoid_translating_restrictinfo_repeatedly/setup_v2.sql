drop function create_partitioned_table;
create or replace function create_partitioned_table(table_name name, num_parts integer, num_cols integer)
returns integer
language plpgsql
as $$
declare
	cnt integer;
	part_name varchar;
	ddl_cmds varchar[];
	ddl_cmd varchar;
	col_clause varchar;
	num_values_per_part integer := 100;
	from_val integer := 0;
	to_val integer := from_val + num_values_per_part;
	first bool;
begin
	-- drop table
	ddl_cmds[1] := 'drop table if exists ' || table_name;

	first := true;
	col_clause := '';
	for cnt in 1 .. num_cols loop
		if not first then
			col_clause := col_clause || ', ';
		end if;

		col_clause := col_clause || 'c' || cnt || ' integer';

		if first then
			col_clause := col_clause || ' primary key';
		end if;

		first := false;
	end loop;

	-- create table
	ddl_cmds[2] := 'create table ' || table_name || '(' || col_clause || ')';
	if num_parts > 0 then
		ddl_cmds[2] := ddl_cmds[2] || ' partition by range(c1)';
	end if;

	-- create partitions
	for cnt in 1 .. num_parts loop
		part_name := table_name || '_p' || cnt;
		ddl_cmds[2 + cnt] := 'create table ' || part_name || ' partition of ' || table_name ||
					' for values from ( ' || from_val || ') to (' || to_val || ')';
		from_val := to_val;
		to_val := from_val + num_values_per_part;
	end loop;

	foreach ddl_cmd in array ddl_cmds loop
		execute ddl_cmd;
	end loop;

	return num_parts;
end;
$$;

drop function measure_query_planning;
create function measure_query_planning(query text, num_runs int, pwj bool)
returns table (run int, planning_time_ms float, plan_mem_used_kb bigint, plan_mem_allocated_kb bigint)
language plpgsql
as $$
declare
	explain_query text := 'EXPLAIN (FORMAT JSON, MEMORY, SUMMARY) ' || query;
	explain_out json;
	pwj_cmd text;
begin
	-- enable/disable pwj
	execute 'set enable_partitionwise_join to ' || case pwj when true then 'on' else 'off' end case;
	-- run it once so that the caches are warmed up
	execute explain_query into explain_out;

	-- run required number of times
	for cnt in 1..num_runs loop
		run := cnt;
		execute explain_query into explain_out;
		planning_time_ms := explain_out->0->>'Planning Time';
		plan_mem_used_kb := (explain_out->0->'Planning'->>'Memory Used')::bigint;
		plan_mem_allocated_kb := (explain_out->0->'Planning'->>'Memory Used')::bigint;
		return next;
	end loop;
end;
$$;

drop function construct_selfjoin_query;
create function construct_selfjoin_query(tabname name, num_join int)
returns text
language sql
strict immutable
as $$
	select 'select * from ' || tabname || ' t1, ' || string_agg(tabname || ' t' || i, ', ') || ' where ' || string_agg('t'||i||'.'||'c1 = t'||(i-1)||'.c1', ' AND ') from generate_series(2, num_join) i;
$$;

drop function measure_join_planning;
create function measure_join_planning(tabname name, max_num_joins int, num_runs int)
returns table (num_joins int, query text, pwj bool, run int, planning_time_ms float, plan_mem_used_kb bigint, plan_mem_allocated_kb bigint)
language sql
as $$
	select num_join, query, pwj.pwj, qp.* from generate_series(2, max_num_joins) num_join, lateral construct_selfjoin_query(tabname, num_join) query, (values (false), (true)) pwj(pwj), lateral measure_query_planning(query, num_runs, pwj.pwj) qp;
$$;

drop function create_tables;
create function create_tables(prefix varchar, numparts int[], num_cols int)
returns setof name
language plpgsql
as $$
declare
	tabname name;
	num_part integer;
begin
	foreach num_part in array numparts loop
		tabname := prefix || num_part;
		perform create_partitioned_table(tabname, num_part, num_cols);
		return next tabname;
	end loop;
end;
$$;

select * from create_tables('t1p', '{0, 10, 100, 500, 1000}'::int[], 2);

drop table msmts;
create table msmts (code_tag text, time_stamp timestamptz, num_parts int, num_joins int, pwj bool, query text, run int, planning_time_ms float, plan_mem_used_kb bigint, plan_mem_allocated_kb bigint);