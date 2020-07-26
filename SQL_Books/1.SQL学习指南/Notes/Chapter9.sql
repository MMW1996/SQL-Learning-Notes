-- Chapter9 子查询

-- 9.1 什么是子查询
-- 子查询定义：指包含在另一个SQL语句内部的查询
-- 例如：
select account_id,product_cd,cust_id,avail_balance
from account 
where account_id = (
	select max(account_id) 
	from account );

-- 9.2子查询类型
-- 非关联子查询
-- 关联子查询

-- 9.3 非关联子查询
-- 9.3.1 标量子查询 
-- 例：查询所有不在Woburn分行开户的账户的相关数据
select account_id,product_cd,cust_id,avail_balance
from account 
where open_emp_id <> (
	select e.emp_id 
	from employee e inner join branch b 
	on e.assigned_branch_id = b.branch_id
	where e.title = 'Head Teller' and b.city = 'Woburn');
	
-- 9.3.2 多行单列子查询
-- in 查询是主管的雇员
select emp_id,fname,lname,title 
from employee 
where emp_id in (
	select superior_emp_id
	from employee);
	
-- not in 检查不管理别人的雇员
select emp_id, fname, lname, title
from employee
where emp_id not in (
	select superior_emp_id 
  from employee
  where superior_emp_id is not null);

		
-- all运算符
-- 查找雇员ID与任何主管都不同的所有雇员，即非主管雇员
select emp_id, fname, lname, title
from employee
where emp_id <> all (
	select superior_emp_id
    from employee
    where superior_emp_id is not null
);

-- 查找所有可用余额小于Frank Tucker所有账户的账户
select account_id, cust_id, product_cd, avail_balance
from account
where avail_balance < all (
	select a.avail_balance
  from account a inner join individual i
	on a.cust_id = i.cust_id
	where i.fname = 'Frank' and i.lname = 'Tucker');

-- any运算符
-- 查找所有可用余额大于Frank Tucker任意账户的账户
select account_id, cust_id, product_cd, avail_balance
from account
where avail_balance > any (
	select a.avail_balance
  from account a inner join individual i
	on a.cust_id = i.cust_id
	where i.fname = 'Frank' and i.lname = 'Tucker');
	
-- 9.3.3 多列子查询
-- 例如：查询在所有Woburn分行柜员开立的账户
select account_id, product_cd, cust_id
from account
where (open_branch_id, open_emp_id) in (
	select b.branch_id, e.emp_id
  from employee e inner join branch b
  on e.assigned_branch_id = b.branch_id
	where b.name = 'Woburn Branch'
	and (e.title = 'Teller' or e.title = 'Head Teller'));

-- 9.4 关联子查询
-- 9.4.1 等值关联 和 不等值关联
-- 例如：查询所有账户数为2 的客户的相关信息
select c.cust_id, c.cust_type_cd, c.city
from customer c
where 2 = (
	select count(*)
  from account a
  where a.cust_id = c.cust_id);

-- 例如：查询所有可用余额在5000 到 10000 的客户的相关信息
select c.cust_id, c.cust_type_cd, c.city
from customer c
where (
	select sum(a.avail_balance)
  from account a
  where a.cust_id = c.cust_id
) between 5000 and 10000;

-- 9.4.2 exists子句
-- exists只关心是否存在
select a.account_id, a.product_cd, a.cust_id, a.avail_balance
from account a
where exists (
	select 1
   from transaction t
   where t.account_id = a.account_id
	 and t.txn_date = '2008-09-22');
	 
 -- not exists 查找所有非商业客户
 select a.account_id, a.product_cd, a.cust_id
from account a
where not exists (
	select 1
  from business b
  where b.cust_id = a.cust_id);

-- 9.4.3 操作数据
-- 关联子查询更新account表
update account a
set a.last_activity_date = (
	select max(t.txn_date)
  from transaction t
  where t.account_id = a.account_id);

-- 9.5 何时使用子查询
-- 9.5.1作为数据源
select d.dept_id, d.name, e_cnt.how_many
from department d inner join (
	select dept_id, count(*) how_many
  from employee
  group by dept_id
) e_cnt
on d.dept_id = e_cnt.dept_id;

-- 9.5.2数据加工
-- 1 生成组定义
select 'Small Fry' name, 0 low_limit, 4999.99 high_limit
union all
select 'Average Joes' name, 5000 low_limit, 9999.99 high_limit
union all
select 'Heavy Hitters' name, 10000 low_limit, 9999999.99 high_limit;

-- 2 生成分组
select groups.name, count(*) num_customers
from (
	select sum(a.avail_balance) cust_balance
	from account a inner join product p
	on a.product_cd = p.product_cd
	where p.product_type_cd = 'ACCOUNT'
	group by a.cust_id
) cust_rollup
inner join (
	select 'Small Fry' name, 0 low_limit, 4999.99 high_limit
	union all
	select 'Average Joes' name, 5000 low_limit, 9999.99 high_limit
	union all
	select 'Heavy Hitters' name, 10000 low_limit, 9999999.99 high_limit
) groups
on cust_rollup.cust_balance between groups.low_limit and groups.high_limit
group by groups.name;


-- 9.5.3面向任务
-- 依据账户类型、开户雇员以及开户对所有储蓄账户余额求和
select p.name product, b.name branch, 
	concat(e.fname, ' ', e.lname) name, 
    account_groups.tot_deposits
from (
	select product_cd, open_branch_id branch_id, open_emp_id emp_id, 
		sum(avail_balance) tot_deposits
    from account
    group by product_cd, open_branch_id, open_emp_id
) account_groups
inner join employee e on e.emp_id = account_groups.emp_id
inner join branch b on b.branch_id = account_groups.branch_id
inner join product p on p.product_cd = account_groups.product_cd
where p.product_type_cd = 'ACCOUNT';

-- 9.5.4 用于过滤条件
-- 查找开户最多的员工
select open_emp_id, count(*) how_many
from account
group by open_emp_id
having count(*) = (
	select max(emp_cnt.how_many)
  from (
		select count(*) how_many
    from account
    group by open_emp_id
       ) emp_cnt
);

-- 9.5.5 作为表达式生成器
-- 查询雇员数据，首先按雇员老板姓氏排序，其次按雇员姓氏排序
select e.emp_id, 
	concat(e.fname, ' ', e.lname) emp_name, 
    (
		select concat(boss.fname, ' ', boss.lname)
		from employee boss
		where boss.emp_id = e.superior_emp_id
    ) boss_name
from employee e
where e.superior_emp_id is not null
order by (
	select boss.lname
    from employee boss
    where boss.emp_id = e.superior_emp_id
), e.lname;

-- 9.6 Test
-- 9.6.1
/**对 account表编写一个查询: 
   过滤条件使用的非关联子查询实现对product表查找所有贷款账户(product.product_type_cd='LOAN')
   结果包括账号ID、产品代码、客户ID和可用余额**/
select a.account_id, a.product_cd, a.cust_id, a.avail_balance
from account a
where a.product_cd in (
	select p.product_cd
  from product p
  where p.product_type_cd = 'LOAN');


-- 9.6.2重做练习9.6.1,对 product表使用关联子查询获得同样的结果。
select a.account_id, a.product_cd, a.cust_id, a.avail_balance
from account a
where exists (
	select 1
  from product p
  where a.product_cd = p.product_cd
	and p.product_type_cd = 'LOAN'
);


-- 9.6.3 将下面的查询与employee表连接,以展示每个雇员的经验
/**SELECT 'trainee' name, '2008-01-01' start_dt, '2009-12-31' end_dt
UNION ALL
SELECT 'worker' name, '2006-01-01' start_dt, '2007-12-31' end_dt
UNION ALL
SELECT 'mentor' name, '2004-01-01' start_dt, '2005-12-31' end_dt;**/
-- 子查询别名定义为 levels,它包含雇员ID、名字、姓氏以及经验等级(levels.name)。
-- (提示: 利用不等条件构建连接条件,确定 employee.start_date列位于哪个等级)
select concat(e.fname, ' ', e.lname) name, l.name e_level
from employee e inner join
	(
		SELECT 'trainee' name, '2008-01-01' start_dt, '2009-12-31' end_dt
		UNION ALL
		SELECT 'worker' name, '2006-01-01' start_dt, '2007-12-31' end_dt
		UNION ALL
		SELECT 'mentor' name, '2004-01-01' start_dt, '2005-12-31' end_dt
    ) l
	on e.start_date between l.start_dt and l.end_dt;

-- 9.6.4 对employee构建一个查询,检索雇员ID、名字、姓氏及其所属部门和分行的名字。请不要连接任何表。
select e.emp_id,fname,lname,
 (select d.name from department d where d.dept_id = e.dept_id) dept_name,
 (select b.name from branch b where b.branch_id = e.assigned_branch_id) branch_name
from employee e;




