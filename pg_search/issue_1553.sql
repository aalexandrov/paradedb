DROP TABLE IF EXISTS test CASCADE;
CREATE TABLE test(id int, data jsonb);

INSERT INTO test VALUES
  (1, '{ "enriched": { "email": "coralee.anderson@harris.example" } }'::jsonb),
  (2, '{ "enriched": { "email": "jane.doe@example.com" } }'::jsonb),
  (3, '{ "enriched": { "email": "jason.doe@example.com" } }'::jsonb),
  (4, '{ "enriched": { "email": "jillian.doe@example.com" } }'::jsonb),
  (5, '{ "enriched": { "email": "jake.doe@example.com" } }'::jsonb);

CALL paradedb.drop_bm25(index_name => 'test_bm25_idx');
CALL paradedb.create_bm25(
  index_name => 'test_bm25_idx',
  table_name => 'test',
  key_field => 'id',
  json_fields => paradedb.field('data')
);

CALL paradedb.drop_bm25(index_name => 'test_bm25_idx');
CALL paradedb.create_bm25(
  index_name => 'test_bm25_idx',
  table_name => 'test',
  key_field => 'id',
  json_fields => paradedb.field('data')
);

DROP TABLE IF EXISTS emails CASCADE;
CREATE TABLE emails(id int, email text);
INSERT INTO emails VALUES
  (1, '"coralee.anderson@harris.example'),
  (2, '"jane.doe@example.com'),
  (3, '"jason.doe@example.com'),
  (4, '"jillian.doe@example.com'),
  (5, '"jake.doe@example.com');


CALL paradedb.drop_bm25(index_name => 'emails_bm25_idx');
CALL paradedb.create_bm25(
  index_name => 'emails_bm25_idx',
  table_name => 'emails',
  key_field => 'id',
  text_fields => paradedb.field('email')
);

-- Q1 (works)
-- Parse {
--     query_string: "data.enriched.email:\"coralee.anderson@harris.example\"",
-- }
-- PhraseQuery {
--     field: Field(
--         0,
--     ),
--     phrase_terms: [
--         (
--             0,
--             Term(field=0, type=Json, path=enriched.email, type=Str, "coralee"),
--         ),
--         (
--             1,
--             Term(field=0, type=Json, path=enriched.email, type=Str, "anderson"),
--         ),
--         (
--             2,
--             Term(field=0, type=Json, path=enriched.email, type=Str, "harris"),
--         ),
--         (
--             3,
--             Term(field=0, type=Json, path=enriched.email, type=Str, "example"),
--         ),
--     ],
--     slop: 0,
-- }
SELECT * FROM test_bm25_idx.search('data.enriched.email:"coralee.anderson@harris.example"');

-- Q2 (doesn't work)
-- Regex {
--     field: "data.enriched.email",
--     pattern: ".*harris\\.example",
-- }
SELECT * FROM test_bm25_idx.search(
  query => paradedb.regex(
    field => 'data.enriched.email',
    pattern => '.*harris.*'
  )
);

-- Regex {
--     field: "email",
--     pattern: ".*harris.*",
-- }
-- RegexQuery {
--     regex: Regex(".*harris.*")
--     000 SPLIT 1, 48
--     ...
--     102 Match
--     ------------
--     000  [2, 5, 8, 12, 17, 22, 27, 32, 38, 43, 48]
--     ...
--     047   F4 => 33
--     ,
--     field: Field(
--         0,
--     ),
-- }
SELECT * FROM emails_bm25_idx.search(
  query => paradedb.regex(
    field => 'email',
    pattern => '.*harris.*'
  )
);