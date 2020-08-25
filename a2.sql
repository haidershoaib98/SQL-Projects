-- Add below your SQL statements. 
-- You can create intermediate views (as needed). Remember to drop these views after you have populated the result tables.
-- You can use the "\i a2.sql" command in psql to execute the SQL commands in this file.

-- Query 1 statements
CREATE VIEW temp AS
	SELECT C.cname AS nName, C.cid AS nCID, C.height AS neighbourHeight
	FROM neighbour n1 JOIN country C ON n1.neighbor = C.cid;

CREATE VIEW temp1 AS
	SELECT cid AS c1id, cname AS c1name
	FROM neighbour N JOIN country C ON N.country = C.cid;

CREATE VIEW temp2 AS
	SELECT c1id, c1name, nCID AS c2id, nName AS c2name  
	FROM temp t JOIN neighbour N_1 ON t.nCID = N_1.neighbor JOIN temp1 t1 ON t1.c1id = N_1.country
	GROUP BY c1id, c1name, nCID, nName;

CREATE VIEW temp3 AS
	SELECT neighbour.country AS nID, max(neighbourHeight) AS maxHeight
	FROM temp t_1 JOIN neighbour ON t_1.nCID = neighbour.neighbor
	GROUP BY neighbour.country;


CREATE VIEW temp4 AS
	SELECT cid AS c2id, cname AS c2name   
	FROM temp3 t3 JOIN country C2 ON t3.maxHeight = C2.height;

INSERT INTO query1
SELECT c1id, c1name, c2id, c2name
FROM temp1 JOIN neighbour N3 ON temp1.c1id = N3.country JOIN temp4 t4 ON t4.c2id = N3.neighbor 	
GROUP BY c1id, c1name, c2id, c2name
ORDER BY c1name ASC;

DROP VIEW
	temp, temp1, temp2, temp3, temp4;


-- Query 2 statements

CREATE VIEW landlock AS
	SELECT cid FROM Country
	EXCEPT
	SELECT cid FROM oceanAccess;

INSERT INTO query2
SELECT C.cid, C.cname
FROM Country C JOIN landlock L ON C.cid = L.cid
ORDER BY cname ASC;

DROP VIEW
	landlock;
	

-- Query 3 statements

CREATE VIEW landlock AS
	SELECT cid FROM Country
	EXCEPT
	SELECT cid FROM oceanAccess;


CREATE VIEW oneCountry AS
	SELECT cid AS c1id, count(N.neighbor) AS numNeighbour
	FROM landlock L JOIN neighbour N ON L.cid = N.country
	GROUP BY L.cid;

CREATE VIEW oneNeighbour AS
	SELECT O.c1id, N1.neighbor AS c2id
	FROM oneCountry O JOIN neighbour N1 ON O.c1id = N1.country
	WHERE numNeighbour = 1;
	
CREATE VIEW final AS
	SELECT C.cid AS c1id, C.cname AS c1name, c2id 
	FROM Country C JOIN oneNeighbour O1 ON C.cid = O1.c1id
	ORDER BY C.cid ASC;



INSERT INTO query3
SELECT c1id, c1name, c2id, C1.cname AS c2name
FROM Country C1 JOIN final F ON F.c2id = C1.cid
ORDER BY F.c1name ASC;

DROP VIEW
	landlock, oneCountry, oneNeighbour, final;


-- Query 4 statements

CREATE VIEW temp AS
	SELECT cid, oceanA.oid, oname
	FROM oceanAccess oceanA JOIN ocean O ON oceanA.oid = O.oid
	ORDER BY oname DESC;

INSERT INTO query4
SELECT C.cname, oA.oname FROM temp oA JOIN country C ON oA.cid = C.cid
UNION
SELECT C1.cname, oA1.oname FROM temp oA1 JOIN neighbour N ON oA1.cid = N.neighbor JOIN country C1 ON N.neighbor = c1.cid
ORDER BY cname ASC;


DROP VIEW
	temp;

-- Query 5 statements

CREATE VIEW temp AS
	SELECT cid, avg(hdi_score) AS avghdi
	FROM hdi
	WHERE year <= 2013 AND year >= 2009
	GROUP BY cid;

INSERT INTO query5	
SELECT T.cid, cname, avghdi
FROM temp T JOIN country C ON T.cid = C.cid
ORDER BY avghdi DESC
LIMIT 10;

DROP VIEW
	temp;

-- Query 6 statements

CREATE VIEW t1 AS
	SELECT cname, A.cid AS cid
	FROM hdi AS A,hdi AS B,hdi AS C,hdi AS D,hdi AS E,country
	WHERE country.cid=A.cid AND B.cid=C.cid AND D.cid=E.cid AND country.cid=B.cid AND country.cid=C.cid AND country.cid=D.cid AND country.cid=E.cid AND B.cid = D.cid AND B.cid=E.cid AND C.cid = E.cid AND A.year=2009 AND B.year=2010 AND C.year=2011 AND D.year=2012 AND E.year=2013
	AND A.hdi_score<B.hdi_score AND B.hdi_score < C.hdi_score AND C.hdi_score<D.hdi_score AND D.hdi_score < E.hdi_score;

INSERT INTO query6 
SELECT cid, cname 
FROM t1
ORDER BY cname ASC;

DROP VIEW 
	t1;


-- Query 7 statements
CREATE VIEW t1 AS
	SELECT R.cid AS cid, R.rid AS rid, R.rname AS rname, ((R.rpercentage/100)* C.population) AS followersA
	FROM religion R,country C
	WHERE C.cid=R.cid;

CREATE VIEW t2 AS
	SELECT rid, rname, sum(followersA) AS followers
	FROM t1
	GROUP BY rid,rname;

INSERT INTO query7
SELECT rid,rname,followers 
FROM t2 
ORDER BY followers DESC;

DROP VIEW 
	t1, t2;



-- Query 8 statements
CREATE VIEW t1 AS
	SELECT L.cid AS cid, max(lpercentage) AS per
	FROM language L
	GROUP BY cid;
CREATE VIEW t2 AS
	SELECT L.cid AS cid,L.lid AS lid,L.lname AS lname,L.lpercentage AS lpercentage
	FROM t1,language L
	WHERE t1.cid=L.cid AND t1.per=L.lpercentage;
CREATE VIEW t3 AS
	SELECT C.cid AS c1,CN.cid AS c2,C.lname AS lname
	FROM neighbour N, t2 C, t2 CN
	WHERE N.country=C.cid AND N.neighbor=CN.cid AND C.lname=CN.lname;
CREATE VIEW t4 AS
	SELECT C.cname AS c1name, CN.cname AS c2name, t3.lname AS lname
	FROM t3, country C, country CN
	WHERE t3.c1=C.cid AND t3.c2=CN.cid;

INSERT INTO query8	
SELECT c1name,c2name,lname FROM t4 
ORDER BY lname ASC, c1name DESC;

DROP VIEW 
	t1, t2, t3, t4;



-- Query 9 statements

CREATE VIEW t1 AS
	SELECT OA.cid, OA.oid,oname, depth
	FROM oceanAccess OA, ocean O
	WHERE OA.oid=O.oid;

CREATE VIEW t2 AS
	SELECT C.cid,C.cname,C.height,COALESCE(t1.oid,0) AS newO, COALESCE(depth,0) AS newD, (C.height+depth) AS span 
	FROM t1 LEFT OUTER JOIN country C ON C.cid=t1.cid;

CREATE VIEW t3 AS	
	SELECT t2.cname AS cname, t2.span AS totalspan	
	FROM t2
	where t2.span IN (SELECT max(span)
	FROM t2);

INSERT INTO query9
SELECT cname, totalspan
FROM t3;

DROP VIEW 
	t1, t2, t3;


-- Query 10 statements
CREATE VIEW t1 AS
	SELECT country.cname AS cname, sum(length) as totalL
	FROM neighbour, country
	where neighbour.country=country.cid
	GROUP BY country.cname;

CREATE VIEW t2 AS
	SELECT t1.cname, t1.totalL AS borderslength 
	FROM t1 
	WHERE t1.totalL IN (SELECT max(totalL) FROM t1);

INSERT INTO query10 
SELECT cname, borderslength 
FROM t2;

DROP VIEW 
	t1, t2;
