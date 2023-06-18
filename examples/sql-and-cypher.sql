--
-- Apache AGE examples, taken from documentation.
--
-- ref: https://age.apache.org/age-manual/master/intro/aggregation.html#data-setup
-- 

-- Example SQL commands which must be run for each session
LOAD 'age';
SET search_path = ag_catalog, "$user", public;

-- Create and set-up the cypher table
SELECT * FROM create_graph('graph_name');
SELECT * FROM cypher('graph_name', $$
	CREATE (a:Person {name: 'A', age: 13}),
	(b:Person {name: 'B', age: 33, eyes: "blue"}),
	(c:Person {name: 'C', age: 44, eyes: "blue"}),
	(d1:Person {name: 'D1', eyes: "brown"}),
	(d2:Person {name: 'D2'}),
	(a)-[:KNOWS]->(b),
	(a)-[:KNOWS]->(c),
	(a)-[:KNOWS]->(d1),
	(b)-[:KNOWS]->(d2),
	(c)-[:KNOWS]->(d2)
$$) as (a agtype);

-- To remove:
-- SELECT * FROM drop_graph('graph_name', true);

-- Create and set-up the SQL table

CREATE TABLE sql_person (
  person_id INTEGER,
  name VARCHAR(255),
  age INTEGER,
  eyes VARCHAR(255)
);

-- Insert into the SQL table

INSERT INTO sql_person (person_id, name, age, eyes)
VALUES
  (1, 'A', 13, NULL),
  (2, 'B', 33, 'blue'),
  (3, 'C', 44, 'blue'),
  (4, 'D1', NULL, 'brown'),
  (5, 'D2', NULL, NULL);


-- Cyper in CTE
-- ref: https://age.apache.org/age-manual/master/advanced/advanced.html#using-cypher-in-a-cte-expression
WITH graph_query as (
    SELECT *
        FROM cypher('graph_name', $$
        MATCH (n)
        RETURN n.name, n.age, id(n)
    $$) as (name agtype, age agtype, id agtype)
)
SELECT * FROM graph_query;

-- Cypher in join (no cte)
-- ref: https://age.apache.org/age-manual/master/advanced/advanced.html#using-cypher-in-a-join-expression 
SELECT t.person_id, 
    t.name as "sql_name",
    t.age as "sql_age",
    graph_query.name as "graph_name",
    graph_query.age as "graph_age",
    graph_query.eyes as "graph_eyes",
    graph_query.name::text = t.name as names_match,
    graph_query.age::integer = t.age as ages_match
FROM sql_person AS t
JOIN cypher('graph_name', $$
        MATCH (n:Person)
        RETURN n.name, n.age, n.eyes, id(n)
$$) as graph_query(name agtype, age agtype, eyes agtype, id agtype)
ON t.name = graph_query.name::text;


-- Cypher in join (with cte)
-- ref: (none)
WITH graph_query as (
    SELECT *
        FROM cypher('graph_name', $$
        MATCH (n)
        RETURN n.name, n.age
    $$) as (name agtype, age agtype)
)
SELECT sql_p.person_id, sql_p.name, sql_p.age, graph_query.name::text = sql_p.name as names_match, graph_query.age = sql_p.age as ages_match
FROM sql_person as sql_p
JOIN graph_query ON sql_p.name = graph_query.name::text
ORDER BY sql_p.name;
