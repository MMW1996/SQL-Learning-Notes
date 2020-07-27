-- Chapter10 再谈连接
-- 10.1外连接
-- 10.1.1 例
-- 返回所有账户，但只返回商业用户的名字
select a.account_id,a.cust_id,b.name
from account a left join business b
on a.cust_id = b.cust_id;

-- 10.1.2 左、右外连接
-- left|gight join 指定左|右 表决定了结果集的行数，右|左 表负责提供与之匹配的值
-- left join 
select c.cust_id,b.name 
from customer c left join business b
on c.cust_id = b.cust_id;

-- right join 
select c.cust_id,b.name 
from customer c right join business b
on c.cust_id = b.cust_id;

-- 10.1.3 三路外连接
-- 获取所有账户列表，并且包含个人客户以及商业用户的企业名称
select a.account_id,a.product_cd,concat(i.fname,' ',i.lname) person_name,b.name business_name
from account a left join individual i on a.cust_id = i.cust_id
left join business b on a.cust_id = b.cust_id;

-- 10.1.4 自外连接
-- 例 返回雇员及雇员主管名称
-- 首先用内连接
select e.fname,e.lname,e_mgr.fname mgr_fname,e_mgr.lname mgr_lname 
from employee e inner join employee e_mgr on e.superior_emp_id = e_mgr.emp_id;

-- 上述查询的缺点是，没有主管的雇员将被遗漏
-- 外连接优化上述查询
select e.fname,e.lname,e_mgr.fname mgr_fname,e_mgr.lname mgr_lname 
from employee e left join employee e_mgr on e.superior_emp_id = e_mgr.emp_id;

-- 10.2 交叉连接
-- 例 
select pt.name,p.product_cd,p.name
from product p cross join product_type pt ;

-- 生成 2020年每一天的日期
-- 首先生成包含1~366数字的数字集
select one.num+ten.num+hundres.num as nums
from 
(
select 0 num union all
select 1 num union all
select 2 num union all
select 3 num union all
select 4 num union all
select 5 num union all
select 6 num union all
select 7 num union all
select 8 num union all
select 9 num ) one 
cross join
(
select 0 num union all
select 10 num union all
select 20 num union all
select 30 num union all
select 40 num union all
select 50 num union all
select 60 num union all
select 70 num union all
select 80 num union all
select 90 num ) ten 
cross join 
(
select 0 num union all
select 100 num union all
select 200 num union all
select 300 num )hundres
order by nums ;

-- 数字集转换为日期集
select date_add('2020-01-01', interval n.nums day) date
from (
select one.num+ten.num+hundres.num as nums
from 
(
select 0 num union all
select 1 num union all
select 2 num union all
select 3 num union all
select 4 num union all
select 5 num union all
select 6 num union all
select 7 num union all
select 8 num union all
select 9 num ) one 
cross join
(
select 0 num union all
select 10 num union all
select 20 num union all
select 30 num union all
select 40 num union all
select 50 num union all
select 60 num union all
select 70 num union all
select 80 num union all
select 90 num ) ten 
cross join 
(
select 0 num union all
select 100 num union all
select 200 num union all
select 300 num )hundres
) n
where date_add('2020-01-01', interval n.nums day)<'2021-01-01'
order by date;

-- 10.3 自然连接
-- 有相同名称列
select a.account_id,a.cust_id,c.cust_type_cd,c.fed_id
from account a natural join customer c;

-- 没有相同名称列，服务器无法生成连接条件而交叉连接两表
select a.account_id,a.cust_id,a.open_branch_id,b.name
from account a natural join branch b;

-- 10.4 Test
-- 10.4.1
/**编写一个查询,它返回所有产品名称及基于该产品的账号(用account表里的product_cd列连接product表).
   查询结果需要包括所有产品,即使这个产品并没有客户开户。**/
 select p.name,a.account_id
 from product p left join account a on p.product_cd = a.product_cd;
 
 -- 10.4.2
/**利用其他外连接类型重写练习1的查询(比如,若在练习1中使用了左外连接这次就使用右外连接),要求查询结果相同**/
 select p.name,a.account_id
 from account a right join product on p.product_cd = a.product_cd;
 
 -- 10.4.3 
 /**编写一个查询,将account表与individua和business两个表外连接(通过account.cust_id列)
   	要求结果集中每个账户一行,查询的列有account.account_id, account.product_cd, 
  	individual.fname, individual.lname和business.name **/
select a.account_id,a.product_cd,i.fname,i.lname,b.name
from account a 
left join individual i on a.cust_id = i.cust_id
left join business b on a.cust_id = b.name;

-- 10.4.设计一个查询,生成集合{1,2,3…,9,100}。(提示:应用交叉连接,至少有两个from子句的子查询。)
select n1.num+n2.num as nums
from 
(
select 1 num union all 
select 2 num union all 
select 3 num union all 
select 4 num union all 
select 5 num union all 
select 6 num union all 
select 7 num union all 
select 8 num union all 
select 9 num union all 
select 10 num) n1
cross join 
 (
select 0  num union all
select 10 num union all 
select 20 num union all 
select 30 num union all 
select 40 num union all 
select 50 num union all 
select 60 num union all 
select 70 num union all 
select 80 num union all 
select 90 num ) n2 
order by nums;

