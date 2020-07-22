-- Chapter5 连接

-- 5.1 笛卡尔积（cross join）
select e.fname,e.lname,d.name from employee e cross join department d;

-- 5.2 内连接 
select e.fname,e.lname,d.name from employee e inner join department d  on e.dept_id=d.dept_id;

#在列名相同情况下还可用 using子句 简化写法
select e.fname,e.lname,d.name from employee e inner join department d  using(dept_id);

-- 5.3 ANSI 写法 
select a.account_id,a.cust_id,a.open_date,a.product_cd
from account a inner join employee e 
on a.open_emp_id=e.emp_id
inner join branch b
on e.assigned_branch_id = b.branch_id
where e.start_date <'2007-01-01' 
and (e.title = 'Teller' or e.title = 'Head Teller' )
and b.name = 'woburn Branch';

-- 5.4连接三个或更多的表
select a.account_id,c.fed_id,e.fname,e.lname 
from customer c inner join account a on a.cust_id = c.cust_id
								inner join employee e on a.open_emp_id =e.emp_id 
where c.cust_type_cd = 'B';

-- 5.5连续两次使用同一个表
select a.account_id,e.emp_id,b_a.name open_branch ,b_e.name emp_branch
from account a 
inner join branch b_a on a.open_branch_id = b_a.branch_id
inner join employee e on a.open_emp_id = e.emp_id
inner join branch b_e on e.assigned_branch_id = b_e.branch_id 
where a.product_cd = 'CHK';

-- 5.6自连接
#列出每个雇员名字及其主管名字
select e.fname,e.lname,e_mgr.fname mgr_fname,e_mgr.lname  mgr_lname
from employee e inner join employee e_mgr
on e.superior_emp_id = e_mgr.emp_id;

-- 5.7相等连接和不等连接
select concat(e1.fname,'',e1.lname) as player_1 ,'VS' as vs ,concat(e2.fname,'',e2.lname) as player_2
from employee e1 inner join employee e2 on e1.emp_id < e2.emp_id 
where e1.title='Teller' and e2.title= 'Teller';

-- 5.8Test
-- 5.8.1
select e.emp_id ,e.fname,e.lname ,b.name from employee e inner join branch b on e.assigned_branch_id = b.branch_id;

-- 5.8.2
/**编写查询，返回所有非商务顾客的账户ID（cust_typew_id='I' ）、顾客的联邦个人识别号码（fed_id）
以及账户所依赖的产品名称（name）**/
select a.account_id,c.fed_id,p.name 
from account a 
inner join customer c on a.cust_id = c.cust_id
inner join product p on a.product_cd = p.product_cd
where c.cust_type_cd = 'I';

-- 5.3 
/** 编写查询查找所有主管位于另一个部门的雇员，需要获取该雇员的ID、姓氏和名字**/
select e.emp_id,e.fname,e.lname from employee e inner join employee e_mgr on  e.superior_emp_id = e_mgr.emp_id
where e.dept_id <> e_mgr.dept_id;
