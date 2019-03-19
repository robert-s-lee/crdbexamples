

https://gist.github.com/marko-asplund/5561404

CREATE TABLE empsalary (
  empno BIGSERIAL PRIMARY KEY,
  depname TEXT,
  location TEXT,
  salary DECIMAL
);

INSERT INTO empsalary VALUES (11, 'develop', 'fi', 5200);
INSERT INTO empsalary VALUES (7, 'develop', 'fi', 4200);
INSERT INTO empsalary VALUES (9, 'develop', 'fi', 4500);
INSERT INTO empsalary VALUES (8, 'develop', 'fi', 6000);
INSERT INTO empsalary VALUES (10, 'develop', 'se', 5200);
INSERT INTO empsalary VALUES (5, 'personnel', 'fi', 3500);
INSERT INTO empsalary VALUES (2, 'personnel', 'fi', 3900);
INSERT INTO empsalary VALUES (3, 'sales', 'se', 4800);
INSERT INTO empsalary VALUES (1, 'sales', 'se', 5000);
INSERT INTO empsalary VALUES (4, 'sales', 'se', 4800);

https://www.postgresql.org/docs/9.1/static/tutorial-window.html

SELECT depname, empno, salary, avg(salary) OVER (PARTITION BY depname) FROM empsalary;
SELECT depname, empno, salary, rank() OVER (PARTITION BY depname ORDER BY salary DESC) FROM empsalary;
SELECT salary, sum(salary) OVER () FROM empsalary;
SELECT salary, sum(salary) OVER (ORDER BY salary) FROM empsalary;

SELECT sum(salary) OVER w, avg(salary) OVER w
  FROM empsalary
  WINDOW w AS (PARTITION BY depname ORDER BY salary DESC);


SELECT distinct depname, row_number() OVER(PARTITION BY depname order by depname) FROM empsalary;
SELECT depname, row_number() OVER(PARTITION BY depname order by depname) FROM empsalary;
SELECT depname, ROW_NUMBER() OVER(PARTITION BY depname order by depname) FROM empsalary;
SELECT depname, ROW_NUMBER() OVER(PARTITION BY depname ) FROM empsalary;
SELECT depname,location, ROW_NUMBER() OVER(PARTITION BY depname,location ) FROM empsalary;


SELECT depname, empno, salary
FROM
  (SELECT depname, empno, salary,
          rank() OVER (PARTITION BY depname ORDER BY salary DESC, empno) AS pos
     FROM empsalary
  ) AS ss
WHERE pos < 3;



https://blog.jooq.org/2013/10/09/sql-trick-row_number-is-to-select-what-dense_rank-is-to-select-distinct/


https://blog.jooq.org/2014/08/12/the-difference-between-row_number-rank-and-dense_rank/


SELECT v, ROW_NUMBER() OVER(ORDER BY v)
FROM t

SELECT DISTINCT v, DENSE_RANK() OVER(ORDER BY v)
FROM t;

SELECT DISTINCT v, DENSE_RANK() OVER(partition by v ORDER BY v)
FROM t;

