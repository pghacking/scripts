------ HEAD

select 'planning time PWJ ON' as HEAD;

select code_tag, num_parts, num_joins,
  format ('n=%s avg=%s dev=%s', count(planning_time_ms) filter (where pwj),
          (avg(planning_time_ms) filter (where pwj))::numeric(6, 2),
          (stddev(planning_time_ms) filter (where pwj))::numeric(6,2))
from msmts where code_tag = 'head'
group by code_tag, num_parts, num_joins
order by 1, 2, 3 \crosstabview 2 3 4

select 'planning time PWJ OFF' as HEAD;

select code_tag, num_parts, num_joins,
  format ('n=%s avg=%s dev=%s', count(planning_time_ms) filter (where not pwj),
          (avg(planning_time_ms) filter (where not pwj))::numeric(16, 2),
          (stddev(planning_time_ms) filter (where not pwj))::numeric(16,2))
from msmts where code_tag = 'head'
group by code_tag, num_parts, num_joins
order by 1, 2, 3 \crosstabview 2 3 4

select 'plan mem used kb PWJ ON' as HEAD;

select code_tag, num_parts, num_joins,
  format ('n=%s avg=%s dev=%s', count(plan_mem_used_kb) filter (where pwj),
          (avg(plan_mem_used_kb) filter (where pwj))::bigint,
          (stddev(plan_mem_used_kb) filter (where pwj))::bigint)
from msmts where code_tag = 'head'
group by code_tag, num_parts, num_joins
order by 1, 2, 3 \crosstabview 2 3 4

select 'plan mem used kb PWJ OFF' as HEAD;

select code_tag, num_parts, num_joins,
  format ('n=%s avg=%s dev=%s', count(plan_mem_used_kb) filter (where not pwj),
          (avg(plan_mem_used_kb) filter (where not pwj))::bigint,
          (stddev(plan_mem_used_kb) filter (where not pwj))::bigint)
from msmts where code_tag = 'head'
group by code_tag, num_parts, num_joins
order by 1, 2, 3 \crosstabview 2 3 4

select 'plan mem allocated kb PWJ ON' as HEAD;

select code_tag, num_parts, num_joins,
  format ('n=%s avg=%s dev=%s', count(plan_mem_allocated_kb) filter (where pwj),
          (avg(plan_mem_allocated_kb) filter (where pwj))::bigint,
          (stddev(plan_mem_allocated_kb) filter (where pwj))::bigint)
from msmts where code_tag = 'head'
group by code_tag, num_parts, num_joins
order by 1, 2, 3 \crosstabview 2 3 4

select 'plan mem allocated kb PWJ OFF' as HEAD;

select code_tag, num_parts, num_joins,
  format ('n=%s avg=%s dev=%s', count(plan_mem_allocated_kb) filter (where not pwj),
          (avg(plan_mem_allocated_kb) filter (where not pwj))::bigint,
          (stddev(plan_mem_allocated_kb) filter (where not pwj))::bigint)
from msmts where code_tag = 'head'
group by code_tag, num_parts, num_joins
order by 1, 2, 3 \crosstabview 2 3 4


-------- patched

select 'planning time PWJ ON' as PATCHED;

select code_tag, num_parts, num_joins,
  format ('n=%s avg=%s dev=%s', count(planning_time_ms) filter (where pwj),
          (avg(planning_time_ms) filter (where pwj))::numeric(6, 2),
          (stddev(planning_time_ms) filter (where pwj))::numeric(6,2))
from msmts where code_tag = 'patched'
group by code_tag, num_parts, num_joins
order by 1, 2, 3 \crosstabview 2 3 4

select 'planning time PWJ OFF' as PATCHED;

select code_tag, num_parts, num_joins,
  format ('n=%s avg=%s dev=%s', count(planning_time_ms) filter (where not pwj),
          (avg(planning_time_ms) filter (where not pwj))::numeric(16, 2),
          (stddev(planning_time_ms) filter (where not pwj))::numeric(16,2))
from msmts where code_tag = 'patched'
group by code_tag, num_parts, num_joins
order by 1, 2, 3 \crosstabview 2 3 4

select 'plan mem used kb PWJ ON' as PATCHED;

select code_tag, num_parts, num_joins,
  format ('n=%s avg=%s dev=%s', count(plan_mem_used_kb) filter (where pwj),
          (avg(plan_mem_used_kb) filter (where pwj))::bigint,
          (stddev(plan_mem_used_kb) filter (where pwj))::bigint)
from msmts where code_tag = 'patched'
group by code_tag, num_parts, num_joins
order by 1, 2, 3 \crosstabview 2 3 4

select 'plan mem used kb PWJ OFF' as PATCHED;

select code_tag, num_parts, num_joins,
  format ('n=%s avg=%s dev=%s', count(plan_mem_used_kb) filter (where not pwj),
          (avg(plan_mem_used_kb) filter (where not pwj))::bigint,
          (stddev(plan_mem_used_kb) filter (where not pwj))::bigint)
from msmts where code_tag = 'patched'
group by code_tag, num_parts, num_joins
order by 1, 2, 3 \crosstabview 2 3 4

select 'plan mem allocated kb PWJ ON' as PATCHED;

select code_tag, num_parts, num_joins,
  format ('n=%s avg=%s dev=%s', count(plan_mem_allocated_kb) filter (where pwj),
          (avg(plan_mem_allocated_kb) filter (where pwj))::bigint,
          (stddev(plan_mem_allocated_kb) filter (where pwj))::bigint)
from msmts where code_tag = 'patched'
group by code_tag, num_parts, num_joins
order by 1, 2, 3 \crosstabview 2 3 4

select 'plan mem allocated kb PWJ OFF' as PATCHED;

select code_tag, num_parts, num_joins,
  format ('n=%s avg=%s dev=%s', count(plan_mem_allocated_kb) filter (where not pwj),
          (avg(plan_mem_allocated_kb) filter (where not pwj))::bigint,
          (stddev(plan_mem_allocated_kb) filter (where not pwj))::bigint)
from msmts where code_tag = 'patched'
group by code_tag, num_parts, num_joins
order by 1, 2, 3 \crosstabview 2 3 4

select 'planning time PWJ ON DIFF' as DIFF;

with head_avgs as
(select code_tag, num_parts, num_joins, pwj, avg(planning_time_ms)
avg_pt, stddev(planning_time_ms) stddev_pt
from msmts where code_tag = 'head'
group by code_tag, num_parts, num_joins, pwj),
patched_avgs as
(select code_tag, num_parts, num_joins, pwj, avg(planning_time_ms)
avg_pt, stddev(planning_time_ms) stddev_pt
from msmts where code_tag = 'patched'
group by code_tag, num_parts, num_joins, pwj)
select num_parts,
num_joins,
format('s=%s%% md=%s%% pd=%s%%',
((m.avg_pt - p.avg_pt)/m.avg_pt * 100)::numeric(6, 2),
(m.stddev_pt/m.avg_pt * 100)::numeric(6, 2),
(p.stddev_pt/p.avg_pt * 100)::numeric(6, 2))
from head_avgs m join patched_avgs p using (num_parts, num_joins,
pwj) where pwj order by 1, 2, 3 \crosstabview 1 2 3

select 'plan mem used PWJ ON DIFF' as DIFF;

with head_avgs as
(select code_tag, num_parts, num_joins, pwj, avg(plan_mem_used_kb)
avg_pt, stddev(plan_mem_used_kb) stddev_pt
from msmts where code_tag = 'head'
group by code_tag, num_parts, num_joins, pwj),
patched_avgs as
(select code_tag, num_parts, num_joins, pwj, avg(plan_mem_used_kb)
avg_pt, stddev(plan_mem_used_kb) stddev_pt
from msmts where code_tag = 'patched'
group by code_tag, num_parts, num_joins, pwj)
select num_parts,
num_joins,
format('s=%s%% md=%s%% pd=%s%%',
((m.avg_pt - p.avg_pt)/m.avg_pt * 100)::numeric(6, 2),
(m.stddev_pt/m.avg_pt * 100)::numeric(6, 2),
(p.stddev_pt/p.avg_pt * 100)::numeric(6, 2))
from head_avgs m join patched_avgs p using (num_parts, num_joins,
pwj) where pwj order by 1, 2, 3 \crosstabview 1 2 3

select 'planning time PWJ OFF DIFF' as DIFF;

with head_avgs as
(select code_tag, num_parts, num_joins, pwj, avg(planning_time_ms)
avg_pt, stddev(planning_time_ms) stddev_pt
from msmts where code_tag = 'head'
group by code_tag, num_parts, num_joins, pwj),
patched_avgs as
(select code_tag, num_parts, num_joins, pwj, avg(planning_time_ms)
avg_pt, stddev(planning_time_ms) stddev_pt
from msmts where code_tag = 'patched'
group by code_tag, num_parts, num_joins, pwj)
select num_parts,
num_joins,
format('s=%s%% md=%s%% pd=%s%%',
((m.avg_pt - p.avg_pt)/m.avg_pt * 100)::numeric(6, 2),
(m.stddev_pt/m.avg_pt * 100)::numeric(6, 2),
(p.stddev_pt/p.avg_pt * 100)::numeric(6, 2))
from head_avgs m join patched_avgs p using (num_parts, num_joins,
pwj) where not pwj order by 1, 2, 3 \crosstabview 1 2 3

select 'plan mem used PWJ OFF DIFF' as DIFF;

with head_avgs as
(select code_tag, num_parts, num_joins, pwj, avg(plan_mem_used_kb)
avg_pt, stddev(plan_mem_used_kb) stddev_pt
from msmts where code_tag = 'head'
group by code_tag, num_parts, num_joins, pwj),
patched_avgs as
(select code_tag, num_parts, num_joins, pwj, avg(plan_mem_used_kb)
avg_pt, stddev(plan_mem_used_kb) stddev_pt
from msmts where code_tag = 'patched'
group by code_tag, num_parts, num_joins, pwj)
select num_parts,
num_joins,
format('s=%s%% md=%s%% pd=%s%%',
((m.avg_pt - p.avg_pt)/m.avg_pt * 100)::numeric(6, 2),
(m.stddev_pt/m.avg_pt * 100)::numeric(6, 2),
(p.stddev_pt/p.avg_pt * 100)::numeric(6, 2))
from head_avgs m join patched_avgs p using (num_parts, num_joins,
pwj) where not pwj order by 1, 2, 3 \crosstabview 1 2 3

