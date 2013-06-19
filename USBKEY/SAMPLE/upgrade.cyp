CREATE INDEX ON :Actor(name);
CREATE INDEX ON :Director(name);
CREATE INDEX ON :Writer(name);
CREATE INDEX ON :Producer(name);
CREATE INDEX ON :Movie(title);
CREATE INDEX ON :Movie(released);
CREATE INDEX ON :Movie(tagline);
CREATE INDEX ON :User(name);

MATCH n
WHERE has(n.title)
SET n:Movie;

MATCH n
WHERE n-[:ACTED_IN]->()
SET n:Actor;

MATCH n
WHERE n-[:DIRECTED]->()
SET n:Director;

MATCH n
WHERE n-[:WROTE]->()
SET n:Writer;

MATCH n
WHERE n-[:PRODUCED]->()
SET n:Producer;

MATCH n
WHERE n-[:FOLLOWS]-()
SET n:User;

