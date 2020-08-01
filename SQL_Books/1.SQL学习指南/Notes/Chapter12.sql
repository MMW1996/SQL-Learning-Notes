-- 12 事务

-- 12.1 锁
-- 12.1.1 锁的两种策略
/** 
锁是数据库服务器用来控制数据库资源被并行使用的一种机制，当数据库的一些内容被锁定时，
任何打算修改或读取此数据的用户必须等到锁被释放，锁的 策略有以下两种：
一：数据库的写操作必须向服务器申请并获得写锁才能修改数据，
	  数据库的读操作必须申请和获得读锁才能查询数据，多用户可以同时读取数据，
	  而一个表（或其他）一次只能分配一个写锁

二：数据库的写操作必须向服务器申请并获得写锁才能修改数据，
       数据库的读操作不需要任何类型的锁就能查询数据，此外，数据库要保证从查
       询到结束看到的是一个一致的数据视图
**/

-- 12.1.1 锁的粒度
/**
表锁：阻止多用户同时修改同一个表的数据
页锁：阻止多用户同时修改某表中同一页的数据
行锁：阻止多用户同时修改某表中同一行的数据
**/

-- 12.2 事务
-- 12.2.1 创建事务
-- oracle 数据库自动开启事务
-- sql sever /mysql 需显式开启事务，单个sql语句会独立于去他语句自动提交

-- 12.2.2 启动事务

start transaction;
-- 关闭自动提交模式
set autocommit = 0;

-- 12.2.3 结束事务
-- 撤回
rollback；
-- 提交
commit

-- 12.3事务保存点
-- 创建事务保存点
savepoint point_name;

-- 撤销之保存点
rolback to savepoint point_name;

-- 12.4 Test
-- 12.4.1 
/**
生成一个事务，它从Frank Tucker 的货币市场账户存款转账￥50 到他的支票账户，
要求插入两行到transaction并更新account表中相应的两行内容
**/
-- 检查FT的货币市场账户（MM）余额 是否大于 ￥50  大于 MM 余额减 50 ，支票账户CHK 加 50 
-- 开启事务
start transaction;
-- 查找FT的客户ID、MM账户ID、CHK账户ID并插入到变量中
select i.cust_id,
(select a.account_id from account a where a.cust_id = i.cust_id and a.product_cd = 'MM') mm_id,
(select a.account_id from account a where a.cust_id = i.cust_id and a.product_cd ='CHK') chk_id
into @cust_id,@mm_id,@chk_id
from individual i
where fname = 'Frank' and lname = 'Tucker';

-- 更新FT账户
insert into transaction(txn_id,txn_date,account_id,txn_type_cd,amount,funds_avail_date)
values
(null,current_date(),@chk_id,'DBT',50,current_date()),
(null,current_date(),@mm_id,'CDT',50,current_date());

update account 
set avail_balance =avail_balance - 50,last_activity_date = current_date() 
where account_id = @mm_id;

update account 
set avail_balance =avail_balance + 50,last_activity_date = current_date() 
where account_id = @chk_id;
-- 提交变更
commit;

