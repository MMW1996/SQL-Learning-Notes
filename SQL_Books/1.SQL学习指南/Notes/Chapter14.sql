-- Chapter14 视图 VIEW
-- 14.1 什么是视图
-- 例如：
create view 
customer_vw (cust_id,fed_id,cust_type_cd,address,city,state,zipcode)as 
select cust_id,fed_id,cust_type_cd,address,city,state,postal_code from customer;

-- 视图是一种临时表，在创建时，数据库并不储存数据，仅存储视图的定义
-- 使用视图时可用select语句中任何子句

-- 14.2 为什么使用视图
-- 14.2.1 数据安全
-- 创建一个仅允许查询企业用户的视图
create view business_customer_vw(cust_id,fed_id,cust_type_cd,address,city,state,zipcode)
as
select 
cust_id,concat('ends in',substr(fed_id,8,4)) fed_id,cust_type_cd,address,city,state,postal_code
from customer where cust_type_cd ='B';

select * from business_customer_vw;
-- 14.2.2 数据聚合
-- 生成报表展示 账户数目 和 每个客户的储蓄余额
create view cust_total_vw
(
   cust_id,
	 cust_type_cd,
	 cust_name,
	 num_accounts,
	 tot_deposits
)
as 
select cst.cust_id,cst.cust_type_cd,
case when cst.cust_type_cd = 'B' 
then (select bus.name from business bus where bus.cust_id = cst.cust_id)
else (select concat(ind.fname,' ',ind.lname) from individual ind where ind.cust_id = cst.cust_id)
end cust_name,
sum(case when act.status = 'ACYIVE' then 1 else 0 end ) tot_active_accounts,
sum(case when act.status = 'ACYIVE' then act.avail_balance else 0 end) tot_balance
from customer cst inner join account act on act.cust_id = cst.cust_id
group by cst.cust_id,cst.cust_type_cd;

select * from cust_total_vw;
-- 14.2.3 隐藏复杂性
-- 例如：展示雇员数目，活跃账户总数，每个分行的交易总数
create view branch_activity_vw
(
	branch_name,
    city,
    state,
    num_employees,
    num_active_accounts,
    tot_transactions
)
as 
select b.name, b.city, b.state,
	(
		select count(*)
        from employee e
        where e.assigned_branch_id = b.branch_id
    ) num_emps,
    (
		select count(*)
        from account a
        where a.status = 'ACTIVE' and a.open_branch_id = b.branch_id
    ) num_active_accounts,
    (
		select count(*)
        from transaction t
        where t.execution_branch_id = b.branch_id
    ) tot_transactions
from branch b;

select * from branch_activity_vw;

-- 连接分区数据
-- 有时一张大表在设计时会被分为多个小块，若需要查询所有数据时查询时就需要查询多个表
create view transaction_vw
(
  txn_date,
	account_id,
	txn_type_cd,
	amount,
	teller_emp_id,
	execution_branch_id,
	funds_avail_date
)
as 
select 
txn_date,account_id,txn_type_cd,amount,teller_emp_id,execution_branch_id,fund_avail_date
from transaction_historic
union all
select 
txn_date,account_id,txn_type_cd,amount,teller_emp_id,execution_branch_id,fund_avail_date
from transaction_current;

-- 可更新的视图
-- 需满足以下条件
-- 没有使用聚合函数 max() min() 等
-- 视图没有使用 group by having子句
-- select from 子句中不存在子查询
-- 视图中没有使用 union union all distinvt
-- from子句中包括不止一个表或可更新视图
-- 若不止一个表或view，则from子句只使用内连接

-- 14.3 Test
-- 14.3.1
create view mgr_emp
(
	supervisor_name,
	employee_name 
) 
as 
select 
concat(sup.fname,' ',sup.lname) superior_name,
concat(emp.fname,' ',emp.lname) employee_name
from employee emp left join employee sup on sup.emp_id = emp.superior_emp_id
order by superior_name asc;

-- 14.3.2
-- 除了查询各分行开立的所有账户的余额,银行总裁还想要一张显示各分行名字及城市的报表。
-- 创建一个生成这些数据的视图。
create view branch_info
(
  branch_id,
	branch_name,
	branch_city,
	tot_avail
)
as 
select b.branch_id,b.name,b.city,sum(a.avail_balance) as tot_avail
from branch b inner join account a on b.branch_id = a.open_branch_id
group by b.branch_id;