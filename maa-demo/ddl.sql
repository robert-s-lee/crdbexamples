
CREATE TABLE nation  (
      n_nationkey       INTEGER NOT NULL,
      n_name            CHAR(25) NOT NULL,
      n_regionkey       INTEGER NOT NULL,
      n_comment         VARCHAR(152),
      INDEX n_rk        (n_regionkey ASC),
      UNIQUE INDEX n_nk (n_nationkey ASC)
);

CREATE TABLE orders  (
      o_orderkey           INTEGER NOT NULL,
      o_custkey            INTEGER NOT NULL,
--      o_orderstatus        CHAR(1) NOT NULL,
--      o_totalprice         DECIMAL(15,2) NOT NULL,
--      o_orderdate          DATE NOT NULL,
--      o_orderpriority      CHAR(15) NOT NULL,
--      o_clerk              CHAR(15) NOT NULL,
--      o_shippriority       INTEGER NOT NULL,
--      o_comment            VARCHAR(79) NOT NULL,
      c_nationkey       INTEGER NOT NULL,
      primary key          (c_nationkey,o_orderkey)
--     ,unique INDEX (o_orderkey)
)
;

CREATE TABLE lineitem (
      l_orderkey      INTEGER NOT NULL,
--      l_partkey       INTEGER NOT NULL,
--      l_suppkey       INTEGER NOT NULL,
      l_linenumber    INTEGER NOT NULL,
--      l_quantity      DECIMAL(15,2) NOT NULL,
--      l_extendedprice DECIMAL(15,2) NOT NULL,
--      l_discount      DECIMAL(15,2) NOT NULL,
--      l_tax           DECIMAL(15,2) NOT NULL,
--      l_returnflag    CHAR(1) NOT NULL,
--      l_linestatus    CHAR(1) NOT NULL,
--      l_shipdate      DATE NOT NULL,
--      l_commitdate    DATE NOT NULL,
--      l_receiptdate   DATE NOT NULL,
--      l_shipinstruct  CHAR(25) NOT NULL,
--      l_shipmode      CHAR(10) NOT NULL,
--      l_comment       VARCHAR(44) NOT NULL,
      c_nationkey       INTEGER NOT NULL,      
      primary key     (c_nationkey,l_orderkey,l_linenumber)
-- ,unique INDEX     (l_orderkey,l_linenumber)
-- ,CONSTRAINT fk_orderkey FOREIGN KEY (l_orderkey) REFERENCES orders
) INTERLEAVE IN PARENT orders (c_nationkey,l_orderkey)
;

