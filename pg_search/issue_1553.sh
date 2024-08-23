#!/bin/bash

local test_index_path=$HOME/.local/tantivy-data/test_bm25_idx
local emails_index_path=$HOME/.local/tantivy-data/emails_bm25_idx

read -r -d '' test_index_data << EOM
{ "id": 1, "data": { "enriched": { "email": "coralee.anderson@harris.example" } } }
{ "id": 2, "data": { "enriched": { "email": "jane.doe@example.com" } } }
{ "id": 3, "data": { "enriched": { "email": "jason.doe@example.com" } } }
{ "id": 4, "data": { "enriched": { "email": "jillian.doe@example.com" } } }
{ "id": 5, "data": { "enriched": { "email": "jake.doe@example.com" } } }
EOM

read -r -d '' emails_index_data << EOM
{ "id": 1, "email": "coralee.anderson@harris.example" }
{ "id": 2, "email": "jane.doe@example.com" }
{ "id": 3, "email": "jason.doe@example.com" }
{ "id": 4, "email": "jillian.doe@example.com" }
{ "id": 5, "email": "jake.doe@example.com" }
EOM

if !command -v tantivy &> /dev/null; then
  cargo install tantivy-cli
fi

if [! -d $test_index_path]; then
  mkdir -p $test_index_path
  tantivy new -i $test_index_path
  cat ~/workspace/paradedb/pg_search/issue_1553.jsonl | tantivy index -i test_bm25_idx
  echo $test_index_data | tantivy index -i $test_index_path
fi
if [! -d $emails_index_path]; then
  mkdir -p $emails_index_path
  tantivy new -i $emails_index_path
  cat ~/workspace/paradedb/pg_search/issue_1553.jsonl | tantivy index -i test_bm25_idx
  echo $emails_index_data | tantivy index -i $emails_index_path
fi


tantivy search -i $test_index_path -q "data.enriched.email:coralee.anderson@harris.example"
tantivy search -i $emails_index_path -q "email:coralee"


