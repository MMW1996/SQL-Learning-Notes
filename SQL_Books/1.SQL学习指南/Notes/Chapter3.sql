-- Chapter3 查询入门
-- 3.1select 子句

-- 3.1.1 查询department表中所有列
select * from department;

-- 3.1.2 查询department表中指定的列 
select dept_id,name from department;
select name from department;

-- 3.1.3 查询列中可包含 列名、字符、表达式、函数
select emp_id,'Active',emp_id*2,upper(lname) from employee;

-- 3.1.4 列的别名  空格/AS 
select 
emp_id,'Active' status,emp_id*2 as emp_id_double,upper(lname) lname_u
from 
employee;

-- 3.1.5 去重
select cust_id from account;#不去重
select DISTINCT cust_id from account;#去重
/** 注意去重前是需要对结果集排序的，对于数据量大的查询来说是相当耗时的，
因此因该注意distinct 的合理使用**/

-- 3.2 from子句
-- 3.2.1子查询产生的表
select 
	e.emp_id,e.fname,e.lname
from 
	(select emp_id,fname,lname,start_date,title from employee) e;
	
-- 3.2.2视图 view 
create view employee_vw as  select emp_id,fname,lname,year(start_date) as start_date from employee;

select * from employee_vw;

-- 3.2.3 表连接 
select employee.emp_id,employee.fname,employee.lname,department.name dept_name
from employee inner join department 
on employee.dept_id = department.dept_id
order by employee.emp_id;

-- 3.2.3 定义表别名  空格/AS
select e.emp_id,e.fname,e.lname,d.name dept_name
from employee e inner join department d
on e.dept_id = d.dept_id
order by e.emp_id;

-- 3.3 where 子句
select emp_id,fname,lname,start_date,title from employee where title = 'Head Teller';

-- 3.3.1 AND 
select emp_id,fname,lname,start_date,title from employee where title = 'Head Teller' and start_date>'2006-01-01';

-- 3.3.2 OR
select emp_id,fname,lname,start_date,title from employee where title = 'Head Teller' or start_date>'2006-01-01';

-- 3.4 group by 和 having
select d.name,count(e.emp_id) as num_emp from employee e inner join department d on d.dept_id = e.dept_id group by d.name having count(e.emp_id)>2;

-- 3.5 order by 子句 

-- 3.5.1 由 open_emp_id排序
select open_emp_id, product_cd from account order by open_emp_id;

-- 3.5.2 先按open_emp_id 排序，再按product_cd 排序
select open_emp_id, product_cd from account order by open_emp_id,product_cd;

-- 3.5.3 升序 ASC / 降序 DESC 
select account_id,product_cd,open_date,avail_balance from account order by avail_balance desc;

-- 3.5.4 根据表达式排序
#根据个人id后三位数字排序
select cust_id,cust_type_cd,state,fed_id from customer order by right(fed_id,3);


-- 3.5.6 根据数字占位符排序
#根据查询返回的第二和第五列排序
select emp_id,title,start_date,fname,lname from employee order by 2,5;


-- 3.6 Test
-- 3.6.1
/**获取所有银行雇员的employee ID、名字（first name） 和 姓氏（last name ） ，并先后按照姓氏和名字进行排序**/
select emp_id,fname,lname from employee order by lname,fname;

-- 3.6.2
/**获取所有状态为'ACTIVE'以及余额大于￥2500的账户的account ID、customer ID 和可用余额（available balance）**/
select account_id,cust_id,avail_balance from account where status='ACTIVE' and avail_balance>2500; 

-- 3.6.3
/**针对account表编写查询，以返回开设过账户的雇员ID（使用account.open_emp_id列），并且结果集中每个独立的雇员只包含一行数据 **/
select distinct open_emp_id from account 

-- 3.6.4
select p.product_cd,a.cust_id,a.avail_balance
from product p inner join account a on p.product_cd=a.product_cd
where p.product_type_cd = 'ACCOUNT' 
order by p.product_cd,a.cust_id;