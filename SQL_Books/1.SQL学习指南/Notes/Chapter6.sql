-- Chapter6 使用集合
-- 6.1union操作符 集合并
-- 6.1.1示例union 去除重复值
select 'IND' type_cd,cust_id,lname name
from individual
union
select 'BUS' type_cd ,cust_id,name 
from business;

-- 6.1.2示例 union all 不去出重复值
select 'IND' type_cd,cust_id,lname name
from individual
union all
select 'BUS' type_cd ,cust_id,name 
from business
union all
select 'BUS' type_cd ,cust_id,name 
from business;

-- 6.2intersect 操作符 集合交
/**mysql 暂不支持
select emp_id,fname,lname from employee 
intersect 
select cust_id,fname,lname from individual;
**/

-- 6.3except 操作符 集合差
-- except 按重复元素重复次数去重,except all 按重复元素去重
/** 
mysql 暂不支持
select emp_id from employee where assigned_branch_id = 2
and (title = 'Teller' or title = 'Head Teller')
except 
select distinct open_emp_id from account where open_branch = 2;
**/

-- 6.4复合查询结果集排序
-- 需从第一个查询中选择列名
-- 若将下面查询中order by 子句中的emp_id换成 open_emp_id 则会报错
select emp_id,assigned_branch_id from employee where title = 'Teller'
union 
select open_emp_id,open_branch_id
from account
where product_cd = 'SAV' order by emp_id;

-- 6.5集合操作优先级
select cust_id from account where product_cd in ('SAV','MM')
union all
select a.cust_id 
from account a inner join branch b on a.open_branch_id = b.branch_id 
where b.name = 'Woburn Branch'
union 
select cust_id from account where avail_balance between 500 and 2500;
#复合查询包含三个或三个以上查询语句时，执行时被至上而下执行和解析

-- 6.7Test
-- 6.7.1
/**
编写一个查询，查找所有个人用户以及雇员的姓氏和名字
**/
select fname,lname from individual
union all 
select fname,lname from employee;

-- 6.7.2
/**对以上结果集按lname 排序 **/
select fname,lname from individual
union all 
select fname,lname from employee
order by lname;