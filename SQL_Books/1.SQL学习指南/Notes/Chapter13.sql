-- Chapter13 索引 和 约束
-- 13.1 索引
-- 13.1.1 创建索引
-- 为department.name列创建索引(B树)
alter table department add index dept_name_idx (name);

-- 查看指定表中的所有索引
-- 查看department表中的索引
show index from department ;

-- 删除 department.name 上的索引
alter table department drop index dept_name_idx ;

-- 13.1.2 唯一索引
-- 为department.name 创建唯一索引
alter table department add unique dept_name_idx (name);

-- 插入一个名为Operation的索引 ，服务器会抛出错误
#insert into department(dept_id,name) values(666,'Operations') ;

-- 13.1.3 多列索引
-- 为 employee.lname,employee.fname 一起创建索引
-- 为使索引尽可能发挥作用，需仔细考虑列集的顺序。
alter table employee add index emp_names_idx(lname,fname);

-- 13.1.2 索引类型
-- B树索引
-- MySQL、Oracle、SQL Server 默认为B树索引
-- B树索引为树结构组织，由根节点、分支节点、叶节点组成
-- 分支节点用于遍历B树，叶节点用于保存真正的值和位置信息
-- 优势在于处理包含许多不同值的列

-- 位图索引
-- 低基数 ：包含少量值却占据大量行的列
-- 例如account.product_cd 的位图索引中 BUS CD值
/**
--------------------------------------
|Values|1|2|3|4|5|6|7|8|9|。。。|23|24|
--------------------------------------
|  BUS |0|0|0|0|0|0|0|0|0|。。。| 0| 0|
--------------------------------------
|  CD  |0|0|1|0|0|0|0|0|0|。。。| 0| 0|                             |
--------------------------------------
| CHK  |             略               |
--------------------------------------
| MM   |             略               |
--------------------------------------
|SAV   |             略               | 
---------------------------------------
 SBL   |             略               |
---------------------------------------
**/

-- 文本索引
-- Mysql中时全文索引，仅MyISAM引擎中可用

-- 13.1.3使用索引
-- 例：
select emp_id,fname,lname from employee where emp_id in (1,3,9,15);
-- 服务器先使用emp_id 列的主键索引定位 ID为 1,3,9,15的雇员，
-- 之后访问这四行，并检索fname lname

show index from account;
-- 查看执行计划
explain  select cust_id,sum(avail_balance) as tot_bal
from account 
where cust_id in (1,5,9,11)
group by cust_id;

-- 13.1.4 索引的不足
-- 索引的本质：一种特俗类型的表
-- 因此，索引并不是越多越好

-- 13.2 约束
-- 一种简单的强加于表中一列或多列的限制
-- NOT NULL：非空，该字段的值必填
-- UNIQUE：唯一，该字段的值不可重复
-- DEFAULT：默认，该字段的值不用手动插入有默认值
-- CHECK：检查，mysql支持，但不起作用。
-- PRIMARY KEY：主键，该字段的值不可重复并且非空  unique+not null
-- FOREIGN KEY：外键，该字段的值引用了另外的表的字段

-- 13.2.1 创建约束
-- 创建表时创建 
-- constraint idx_name idx_type(colname);
-- 或者alter table增加 
-- alter table table_name add constraint idx_name idx_type (column); 

-- 删除约束
-- alter table table_name drop idx_type idx_name;

-- 13.2.2  级联约束
-- 级联更新 ON UPDATE CASCADE
-- 首先尝试更新product表中product_cd 列为product_type表中不存在的值
-- 由于存在外键约束，更新会失败
-- 即，父表中不存在相应的值，外键约束不允许更改子行
#update product set product_cd = 'MMM' where product_type_cd = 'LOAN';

-- 再尝试更新product_type 表中的父行为 'MMM' 
-- 再次抛出错误，因为product.product_type_cd 中存在'LOAN'值 
#update product_type set product_type_cd = 'MMW' where product_type_cd = 'LOAN';

-- 为实现级联更新,需重建外键约束并在添加新外键时包含 on update casecade 语句
-- 首先删除原有外键
alter table product drop foreign key fk_product_type_cd;
-- 添加新外键约束
alter table product add constraint fk_product_type_cd foreign key(product_type_cd
) references product_type(product_type_cd) on update cascade;

-- 级联删除 ON DELETE CASCADE
-- 例如：
alter table product add constraint fk_product_type_cd foreign key (product_type_cd)
references product_type(product_type_cd) on update cascade on delete cascade;

-- 13.3 Test
-- 13.3.1 修改account表，使客户不能在任何产品中拥有多个账户(最多一个)
start transaction;
alter table account add unique(product_cd,cust_id);
commit;

-- 13.3.2 为transaction表生成多列索引，使之可用于以下两个索引
-- 查询 1 
select txn_date,account_id,txn_type_cd,amount
from transaction 
where txn_date>cast('2008-12-31 23:59:29' as datetime) ;

-- 查询 2 
select txn_date,account_id,txn_type_cd,amount
from transaction 
where txn_date>cast('2008-12-31 23:59:29' as datetime) and amount<1000;

alter table transaction add index txn_date_amount_idx(txn_date,amount);
#alter table transaction drop index txn_date_amount_idx;
-- 查看执行计划
explain select txn_date,account_id,txn_type_cd,amount
from transaction 
where txn_date>cast('2008-12-31 23:59:29' as datetime) ;

explain select txn_date,account_id,txn_type_cd,amount
from transaction 
where txn_date>cast('2008-12-31 23:59:29' as datetime) and amount<1000;
