#!/bin/bash
codetag=$1
tabquery="select c.relname, count(i.inhrelid) num_parts from pg_class c left join pg_inherits i on i.inhparent = c.oid where relname like 't1p%' and (
(relkind = 'r' and not relispartition) or relkind = 'p') group by (c.relname);"
for tabentry in `psql -A -t -d postgres -c "$tabquery"`; do
	tab=`echo $tabentry | cut -f1 -d '|'`
	num_parts=`echo $tabentry | cut -f2 -d '|'`
	echo "measuring with table $tab having $num_parts partitions"
	tabdef="msmts (code_tag, time_stamp, num_parts, num_joins, pwj, query, run, planning_time_ms, plan_mem_used_kb, plan_mem_allocated_kb)"
	values="select '$codetag', now(), $num_parts, mjp.num_joins, mjp.pwj, mjp.query, mjp.run, mjp.planning_time_ms, mjp.plan_mem_used_kb, mjp.plan_mem_allocated_kb from measure_join_planning('$tab', 5, 10) mjp"
	psql -d postgres -c "insert into $tabdef $values;"
done