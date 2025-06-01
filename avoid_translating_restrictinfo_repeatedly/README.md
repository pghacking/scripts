#!/bin/bash

psql -d postgres -t < setup.sql

## head
bash benchmark.sh head

## patched
bash benchmark.sh patched

## see results

psql -d postgres < crosstabview_results.sql

