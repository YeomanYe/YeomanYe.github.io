title: Oracle特殊点总结
tags:
    - Oracle
comments: true
brief: 一些Oracle常用的特殊点总结
categories:
    - 数据库
---
# Oracle特殊点
记录了Oracle与其他数据库的一些不同之处，包括分页查询、信息查看、创建自增序列、添加索引等。
<!-- more -->

## 分页查询
使用rownum进行分页查询
```sql
# 查询某个数量以下时
select s.uuid,rownum from table_name s where rownum < 22;
# 分页查询
select * from ( select  t.*, rownum RN from TABLE_NAME  t ) where RN > 0 and RN <= 15;
select * from ( select  t.*, rownum RN from TABLE_NAME  t ) where RN between 1 and 15;
# 如果需要配需，应该在嵌套一层排序爹子查询
select * from
   (select a.*,rownum row_num from
      (select * from mytable t order by t.id desc) a
   ) b 
where b.row_num between 1 and 10
```

## 查询信息
```sql
# 查询所有表
select table_name from user_tables;
# 显示表的字段
desc table_name;
# 查看当前用户默认表空间
select username,default_tablespace from user_users;
```

## 创建自增序列
创建一个测试表:

```sql
create table userlogin
(
     id   number(6) not null primary key,

     name   varchar2(30)   not null,

);
```

创建一个sequence
```sql
# 创建一个sequence
create sequence userlogin_seq increment by 1 start with 1 minvalue 1 maxvalue 9999999999999 nocache order;
```

创建一个触发器，用于在插入时自动追加序号
```sql
create or replace trigger userlogin_trigger 
before insert on userlogin
for each row 
begin 
      select   userlogin_seq.nextval   into:new.id from sys.dual ; 
end;

/
```

这样在插入时就能自动生成自增的主键

## 添加索引
```sql
# 添加索引，多个字段用,隔开
CREATE INDEX index_name ON table_name(col1,col2); 
```