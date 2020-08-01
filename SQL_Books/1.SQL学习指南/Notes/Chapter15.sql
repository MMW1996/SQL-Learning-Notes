-- Chapter15.元数据
-- 15.1信息模式
-- 15.1.1 检索bank数据库中所有表的名字(包括视图)
select 
	table_name,
	table_type 
from 
	information_schema.tables 
where 
	table_schema = 'bank' 
order by 1;

-- 15.1.2只检索bank中的视图
select 
	table_name,
	table_type 
from 
	information_schema.tables 
where 
	table_schema = 'bank'  and table_type = 'VIEW'
order by 1;

-- 15.1.3 查询表的列信息
select 
	column_name,
	data_type,
	character_maximum_length char_max_len,
	numeric_precision num_prcsn,
	numeric_scale num_scale
from 
	information_schema.`COLUMNS`
where 
	 table_schema = 'bank' and table_name = 'account'
 order by ordinal_position;

-- 15.1.4查询某个表的索引信息
select index_name,non_unique,seq_in_index,column_name
from information_schema.statistics
where table_schema = 'bank' and table_name = 'account'
order by 1,3;

-- 15.1.5检索bank数据库中所有约束
select constraint_name,table_name,constraint_type
from information_schema.table_constraints
where table_schema = 'bank'
order by 1,3;

-- 15.2 使用元数据
-- 15.2.1 模式生成脚本
select * from information_schema.columns where table_schema = 'bank' and table_name = 'account';

-- 15.2.2 生成动态SQL
-- MYSQL 为动态SQL提供了prepare、execute、deallocate语句
-- 例如：
-- 将sql字符串赋予变量try
set @try ='select cust_id,cust_type_cd,fed_id from customer';
-- try被prepare语句提交给数据库引擎
prepare exsql from @try;
-- 执行语句
execute exsql;
-- 之后调用deallocate prepare关闭语句
deallocate prepare exsql;

-- 动态指定条件，在查询中只当占位符
set @try = 
'select 
	product_cd,
	name,product_type_cd,
	date_offered,
	date_retired
 from 
	product 
 where 
	product_cd =?';

prepare exsql1 from @try;
set @procd = 'CHK';

execute exsql1 using @procd;

set @procd = 'SAV';

-- 15.2.3生成动态SQL字符
select 
concat('select ',
	concat_ws(',',cols.col1,cols.col2,cols.col3,cols.col4,cols.col5,cols.col6,cols.col7,cols.col8,cols.col9),' from product where product_cd = ?')
into @try
from 
(
select 
 max(case when ordinal_position = 1 then column_name else null end ) col1,
 max(case when ordinal_position = 2 then column_name else null end ) col2,
 max(case when ordinal_position = 3 then column_name else null end ) col3,
 max(case when ordinal_position = 4 then column_name else null end ) col4,
 max(case when ordinal_position = 5 then column_name else null end ) col5,
 max(case when ordinal_position = 6 then column_name else null end ) col6,
 max(case when ordinal_position = 7 then column_name else null end ) col7,
 max(case when ordinal_position = 8 then column_name else null end ) col8,
 max(case when ordinal_position = 9 then column_name else null end ) col9
 from information_schema.columns
 where table_schema = 'bank' and table_name = 'product'
 group by table_name
) cols;

-- 查看@try
select @try;
-- 提交动态语句
prepare exsql2 from @try;
-- 占位符赋值
set @procd ='MM';
-- 执行
execute exsql2 using @procd ;
-- 关闭语句
deallocate prepare exsql2;

-- 15.3 Test
-- 15.3.1 编写一个查询，列出bank表中所有索引，要求包括表明
desc information_schema.statistics;
select table_name,index_name,index_type from information_schema.statistics;

-- 15.3.2 
/**
编写一个查询，生成的结果可以用于bank.employee表的所有索引，要求结果形式如下：
"ALTER TABLE <table_name> add index <index_name>(<column_list>)"
**/
select 
	*
from information_schema.statistics 
where table_schema = 'bank' and table_name = 'employee';

select 
	concat('ALTER TABLE ',t.table_name,' ADD INDEX ' ,t.index_name,'(',column_name,')',';')
into @cidx
from 
(
select 
	table_schema,
	table_name,
	index_name,
	column_name
from information_schema.statistics 
where table_schema = 'bank' and table_name = 'employee'
) t;