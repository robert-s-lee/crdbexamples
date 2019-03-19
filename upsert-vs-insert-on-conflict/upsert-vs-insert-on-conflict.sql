
create table t1 (id1 int primary key, id2 int default null, id3 int default 1);

create table t1 (id1 int primary key, id2 int default null
  , id3 int default 1
  , id4 int default 1
  , id5 int default 1
  , id6 int default 1
  , id7 int default 1
  , id8 int default 1
  , id9 int default 1
);

insert into t1 values (1,1,1),(2,2,2),(3,3,3);

# mysql
insert into t1 (id1,id2) values (2,1) on duplicate key update id2=values(id2);

replace into t1 (id1,id2) values (3,1);

# crdb
upsert into t1 (id1,id2) values (2,1);

# crdb
insert into t1 (id1,id2) values (3,1) on conflict (id1) do update set id2=excluded.id2;

about 17% faster with upsert
