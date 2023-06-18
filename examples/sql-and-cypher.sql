--
-- Apache AGE examples, taken from documentation.
--
-- ref: https://age.apache.org/age-manual/master/intro/aggregation.html#data-setup
-- 


-- Create and set-up the cypher table
SELECT * FROM create_graph('graph_name');
SELECT * FROM cypher('graph_name', $$
	CREATE (a:Person {name: 'A', age: 13}),
	(b:Person {name: 'B', age: 33, eyes: "blue"}),
	(c:Person {name: 'C', age: 44, eyes: "blue"}),
	(d1:Person {name: 'D', eyes: "brown"}),
	(d2:Person {name: 'D'}),
	(a)-[:KNOWS]->(b),
	(a)-[:KNOWS]->(c),
	(a)-[:KNOWS]->(d1),
	(b)-[:KNOWS]->(d2),
	(c)-[:KNOWS]->(d2)
$$) as (a agtype);

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
  (4, 'D', NULL, 'brown'),
  (5, 'D', NULL, NULL);

-- Personally would recommend using CTEs to split up the cypher query from the sql query cleanly, as seen in the example below.
WITH graph_query as (
    SELECT *
        FROM cypher('graph_name', $$
        MATCH (n)
        RETURN n.name, n.age
    $$) as (name agtype, age agtype)
)
SELECT sql_p.id, sql_p.name, sql_p.age, graph_query.name = sql_p.name as names_match, graph_query.age = sql_p.age as ages_match
FROM sql_person as sql_p
JOIN sql_p.id = graph_query.id
ORDER BY sql_p.name;

