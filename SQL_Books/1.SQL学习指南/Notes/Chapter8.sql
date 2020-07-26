-- Chapter8 分组与聚合

-- 8.1.1 分组查询开户职员
select open_emp_id from account group by open_emp_id;

-- 8.1.2 使用聚合函数查询每个开户职员创建的账户数
select open_emp_id,count(*) as account_cnt from account group by open_emp_id;

-- 8.1.3 使用聚合函数查询每个开户职员创建的账户数并过滤掉创建账户数少于 5 个的职员
select open_emp_id,count(*) as account_cnt from account group by open_emp_id having account_cnt45;

-- 8.1.4聚合函数
-- 下面例子中每列都是有聚合函数产生的，没有使用group by 子句，因此是一个隐式分组
select 
max(avail_balance) max_balance,
min(avail_balance) min_balance,
avg(avail_balance) avg_balance,
sum(avail_balance) sum_balance,
count(*) num_accounts
from account
where product_cd = 'CHK';

-- 8.1.5 使用表达式
select max(pending_balance - avail_balance) as max_uncleared from account;

-- 8.2 聚合函数处理null值
#create table 
drop table if exists number_tb1;
create table number_tb1(val smallint);
#insert data
insert into number_tb1 values(1),(3),(5);

-- 无null值
select count(*) num_rows,
count(val) num_vals,
sum(val) sum_vals,
max(val) max_val,
avg(val) avg_val
from number_tb1;

insert into number_tb1 values(null);
-- 有 null值 
select count(*) num_rows,
count(val) num_vals,
sum(val) sum_vals,
max(val) max_val,
avg(val) avg_val
from number_tb1;

/** 以上例子说明 max() min() avg() sum()忽略null值，
count(*) 统计 行的数目 ，count(column) 对column列包
含的值的数目进行统计并且忽略null值**/

-- 8.3产生分组
-- 8.3.1 单列分组
select product_cd,sum(avail_balance) pro_balance from account group by product_cd;

-- 8.3.2 多列分组
-- 如 根据产品和开户支行进行统计
select product_cd,open_branch_id ,sum(avail_balance) tot_balance 
from account 
group by product_cd,open_branch_id;

-- 8.3.4 表达式分组
select extract(year from start_date) year,count(*) how_many 
from employee 
group by extract(year from start_date) ;

-- with rollup 产生合计数
select product_cd,open_branch_id,sum(avail_balance) tot_balance 
from account
group by product_cd,open_branch_id with rollup;

-- 8.4 分组过滤条件
-- 8.4.1 分组后过滤 
select product_cd,sum(avail_balance) pro_balance
from account
where status = 'ACTIVE'
group by product_cd
having sum(avail_balance) >= 10000;

-- 8.4.2 having子句中还可包含其他不在select子句中的聚合函数
select product_cd,sum(avail_balance) pro_balance
from account
where status = 'ACTIVE'
group by product_cd
having min(avail_balance) >= 100 and max(avail_balance)<=10000;

-- 8.5Test
-- 8.5.1 构建查询，对account表中的数据行进行统计
select count(*) as num_rows from account;

-- 8.5.2 修改上面查询，使之对每个客户所持有的账户统计，并且显式每个客户的id及其账户数
#desc account;
select cust_id,count(account_id) as accounts from account group by cust_id;

-- 8.5.3 修改上面查询，使之只包含至少持有两个账户的客户
select cust_id,count(account_id) as accounts from account group by cust_id having count(account_id) >=2;

-- 8.5.4查找至少包含一个账户的产品和支行组合的可用余额合计数，并根据余额合计数对结果进行排序（降序 desc）
select product_cd,open_branch_id,sum(avail_balance) as sum_ava
from account 
group by product_cd,open_branch_id 
having count(account_id) >=1 
order by sum(avail_balance) desc;
