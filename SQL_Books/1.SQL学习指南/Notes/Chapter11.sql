-- Chapter11 条件逻辑
-- 11.1 case表达式
-- 11.1.1 查找型case表达式
select c.cust_id,c.fed_id,
case 
	when c.cust_type_cd = 'I' then
		(select concat(i.fname,' ',i.lname) 
		 from individual i 
		 where i.cust_id = c.cust_id)
	when c.cust_type_cd = 'B' then
		(select b.name
		 from business b
		 where b.cust_id = c.cust_id)
	else 'Unknown'
end name
from customer c;

-- 11.1.2 简单case表达式
select c.cust_id,c.fed_id,
case c.cust_type_cd
	when 'I' then
		(select concat(i.fname,' ',i.lname) 
		 from individual i 
		 where i.cust_id = c.cust_id)
	when 'B' then
		(select b.name
		 from business b
		 where b.cust_id = c.cust_id)
	else 'Unknown'
end name
from customer c;

-- 11.2 case表达式范例
-- 11.2.1 结果集变换
-- 将下列结果集转换为单行多列
select year(open_date) year ,count(*) how_many 
from account
where open_date>'1999-12-31' and open_date<'2006-01-01' 
group by year(open_date);

select 
	 sum(case
	     when extract(year from open_date) = 2000 then 1 else 0 end ) year_2000,
         sum(case
	     when extract(year from open_date) = 2001 then 1 else 0 end ) year_2000,
	 sum(case
	     when extract(year from open_date) = 2002 then 1 else 0 end ) year_2000,
	 sum(case
	     when extract(year from open_date) = 2003 then 1 else 0 end ) year_2000,
	 sum(case
	     when extract(year from open_date) = 2004 then 1 else 0 end ) year_2000,
	 sum(case
	     when extract(year from open_date) = 2005 then 1 else 0 end ) year_2000
from account 
where open_date>'1999-12-31' and open_date<'2006-01-01' ;

-- 选择性聚集
-- 查找账户余额与transaction表中的原始数据不相符的数据
-- 借款交易 乘以 -1 （DBT类型）
select concat('ALERT! Account #', a.account_id, ' has INCORRECT balance!')
from account a
where (a.avail_balance, a.pending_balance) != (select 
    sum(
		case 
		when t.funds_avail_date > current_timestamp() then 0
		when t.txn_type_cd = 'DBT' then t.amount * -1
		else t.amount
		end
    ), 
    sum(
		case 
		when t.txn_type_cd = 'DBT' then t.amount * -1
		else t.amount
		end
    )
    from transaction t
    where t.account_id = a.account_id
);

-- 存在性检查
-- 检查客户是否有支票账户和储蓄账户
select c.cust_id, c.fed_id, c.cust_type_cd,
	case 
	when exists (
	    select 1
            from account a
            where a.cust_id = c.cust_id
	    and a.product_cd = 'CHK'
        ) then 'Y'
        else 'N'
	end has_checking,
        case
	when exists (
	    select 1
            from account a
            where a.cust_id = c.cust_id
	    and a.product_cd = 'SAV'
	) then 'Y'
	else 'N'
	end has_savings
from customer c;

-- 简单case表达式为每位客户计算账户数目
select c.cust_id,c.fed_id,c.cust_type_cd,
case (select count(*) from account a where a.cust_id = c.cust_id)
when 0 then 'None'
when 1 then '1'
when 2 then '2'
else '3+'
end num_accounts 
from customer c;

-- 除零错误
-- 表达式分母为0 时,mysql 将结果置为null
select 100/0;

-- case避免计算结果
select a.cust_id, a.product_cd, a.avail_balance / 
	case
	when prod_tots.tot_balance = 0 then 1
        else prod_tots.tot_balance
	end percent_of_total
from account a inner join (
    select a.product_cd, sum(a.avail_balance) tot_balance
    from account a
    group by a.product_cd
) prod_tots
on a.product_cd = prod_tots.product_cd;

-- 有条件更新

-- null值处理
-- 用case语句替换null值
select emp_id,fname,lname,
	case 
	when title is null then 'Unknown'
	else title 
	end title 
from employee;

-- 11.3 
-- 11.3.1
/**
重写下面的查询,要求使用查找型case表达式替换简单case表达式,并且查询结果相同。
请读者尽可能少使用when子句
**/
SELECT emp_id,
	CASE title
		WHEN 'President' THEN 'Management'
		WHEN 'Vice President' THEN 'Management'
		WHEN 'Treasurer' THEN 'Management'
		WHEN 'Loan Manager' THEN 'Management'
		When 'Operations Manager' then 'Operations'
		WHEN 'Head Teller' THEN 'Operations'
		When 'Teller' then 'Operations'
		ELSE 'Unknown'
	END
FROM employee;

select emp_id,
	case 
	when title in ('President','Vice President','Treasurer','Loan Manager') then 'Management'
	when title in ('Operations Manager','Head Teller','Teller') then 'Operations'
	else 'Unknown'
	end title 
from employee;

-- 11.3.2
/**
重写下面的查询,要求结果集为单行4列(每个分行1列)的
其中4列分别以branch_1~branch_4命名。
**/
SELECT open_branch_id, COUNT(*)
FROM account
GROUP BY open_branch_id;

select
	sum(
		case
			when open_branch_id = 1 then 1 else 0 end
     ) branch_1,
	sum(
		case
			when open_branch_id = 2 then 1 else 0 end
    ) branch_2,
	sum(
		case
			when open_branch_id = 3 then 1 else 0 end
    ) branch_3,
	sum(
		case
			when open_branch_id = 4 then 1 else 0 end
    ) branch_4    
from account;
