--  Chapter4 过滤

-- 4.1 条件类型

-- 4.1.1 想等条件查询
select pt.name product_type,p.name product 
from product p inner join product_type pt on p.product_type_cd = pt.product_type_cd
where pt.name = 'Customer Accounts';

-- 4.1.2 不等条件查询
select pt.name product_type,p.name product 
from product p inner join product_type pt on p.product_type_cd = pt.product_type_cd
where pt.name <> 'Customer Accounts';

-- 4.1.3 相等条件更新
delete from account where status = 'CLOSE' and year(close_date) =2002;

-- 4.1.4范围条件
select emp_id,fname,lname,start_date from employee where start_date<'2007-01-01';

select emp_id,fname,lname,start_date from employee where start_date<'2007-01-01' and start_date>='2005-01-01';

-- 4.1.5 between(包含上下限) []
select account_id,product_cd,cust_id,avail_balance from account where avail_balance between 3000 and 5000;

-- 4.1.6字符串范围(需知道collation)
select cust_id,fed_id from customer where cust_type_cd ='I' and fed_id between '500-00-0000' and '999-99-9999';

-- 4.1.7 成员条件 in
select account_id,product_cd,cust_id,avail_balance 
from account 
where product_cd = 'CHK' or product_cd = 'SAV' or product_cd = 'CD' or product_cd = 'MM';

-- 4.1.7成员条件 子查询
select account_id,product_cd,cust_id,avail_balance 
from account 
where product_cd in (select product_cd from product where product_type_cd = 'ACCOUNT');

-- 4.1.8 成员条件 not in
select account_id,product_cd,cust_id,avail_balance 
from account 
where product_cd not in ('CHK','SAV','CD','MM');

-- 4.1.9匹配条件
#内建函数匹配部分字符串
select emp_id,fname,lname from employee where left(lname,1) ='T';

#通配符 _  % 
select lname from employee where lname like '_a%e%';

#格式匹配
select cust_id,fed_id from customer where fed_id like '___-__-____';

#多个搜索表达式
select emp_id,fname,lname from employee where lname like 'F%' or  lname like 'G%';

#正则表达式 regexp
select emp_id, fname,lname from employee where lname  regexp '^[FG]';

-- 4.2 NULL
select emp_id,fname,lname,superior_emp_id from employee where superior_emp_id is null;

-- 4.3 Test
-- 4.3.1 
/** 查找所有在2002年开户的所有账户 **/
select account_id from account where year(open_date)='2002';

-- 4.3.2
/**构造查询，查找姓氏（lname）中a 为第二个字符，并且e在a后任意位置出现的非公司客户**/
select * from individual where lname like '_a%e%';

