-- Chapter7 数据生成、转换和操作
-- 7.1 使用字符串数据
create table str_tb1 (char_fid char(30),
varchar_fid varchar(30),
text_fid text);
-- 7.1.1 生成数据串
insert into str_tb1 values('This is char data',
													 'This is varchar data',
													 'This is text data');
-- 7.1.2字符串超过最大长度
#查看myslq行为模式，当前为默认模式 'strict'
select @@session.sql_mode;

#在此模式下插入超过字符列允许最大长度数据时mysql会抛出异常
-- update str_tb1 set varchar_fid = 'this is a extremely long varchar data';

#现在将行为模式更改为 'ansi'
set @@session.sql_mode = 'ansi';

#再次插入上面的数据，这次没有抛出异常，只是发出了一个警告
update str_tb1 set varchar_fid = 'this is a extremely long varchar data';

#查看该警告(在navicat中看不到)
show warnings;
#查看该数据，可以看到数据串被截断
select varchar_fid from str_tb1;

-- 7.1.3 包含单引号
-- 单引号转义，在单引号前再加一个单引号
update str_tb1 set text_fid = 'this string didn''t work,but it dose now';

-- 反斜杠转义 
update str_tb1 set text_fid = 'This string didn\'t work,but it dose now';

-- 内建函数quote() ,自动为字符串中的单引号/撇号增加转义符
select quote(text_fid) from str_tb1; #'This string didn\'t work,but it dose now'

-- 7.1.4操作字符串
-- 先重设str_tb1中的数据
delete from str_tb1;
insert into str_tb1 values('This string is 28 characters',
													 'This string is 28 characters',
													 'This string is 28 characters');

-- length() 返回字符串的字符数
select length(char_fid) as char_length,
			 length(varchar_fid) as varchar_length,
			 length(text_fid) as text_length
from str_tb1; 

-- position(substr in str) 返回子字符串在字符串中的位置
select position('characters'  in varchar_fid) as p from str_tb1;#19

-- locate(substr,str[,n]) 从位置n开始搜索
select locate('is',varchar_fid,5) from  str_tb1;#13

-- strcmp(str1,str2) 字符串比较 str1 =str2 返回0 str1在str2前，返回 -1，反之返回 1
delete from str_tb1;
insert into str_tb1(varchar_fid) values('12345'),('abcd'),('QRSTUV'),('qrstuv'),('xyz');
#排序
select varchar_fid from str_tb1 order by varchar_fid;
#strcmp()比较
select strcmp('12345','12345') 12345_12345, #自身比较返回0
			 strcmp('abcd','xyz') abcd_xyz, #abcd在xyz之前，返回-1
			 strcmp('abcd','QRSTUV') abcd_QRSTUV, # 同上，返回-1
			 strcmp('qrstuv','QRSTUV') qrstuv_QRSTUV, #strcmp()函数不区分大小写 ，返回0
			 strcmp('xyz','abcd') xyz_abcd #xyz在abcd之后，返回 1
-- like 比较字符串 ，结果返回 1（true）或 0（false）
select name, name like '%ns' ends_with_ns from department;

-- 更复杂匹配可用regexp操作符
select cust_id,cust_type_cd,fed_id, fed_id regexp '.{3}-.{2}.{4}' is_ss_no_format from customer;

delete from str_tb1;
insert into str_tb1(text_fid) values('This string was 29 characters');
-- concat() 字符串拼接
#在text_fid末尾增加一个短句
update str_tb1 set text_fid = concat(text_fid,',but now is longer');
select text_fid from str_tb1;

#为每个银行柜员产生简介字符串
select concat(fname,' ',lname,' has been a ',title,' since ',start_date) emp_narrative from employee where title = 'Teller' or title = 'Head Teller';

-- insert() 字符串替换
-- insert(original_str,start_idx,replace_n,replace_str)
select insert('goodbye world',9,0,'cruel ') string_1,
       insert('goodbye world',9,5,'cruel ') string_2;

-- substring(str,start_index,n)
select substring('goodbye world',9,5) str

-- 7.2 使用数值数据

-- 7.2.1 执行算术运算
--  求余函数 mod()  //也可用 %
select mod(10,4) ; -- 2
-- mod()多用于整形参数，但也可以用于处理实数
select mod(22.75,5); -- 2.75
-- %作用同 mod()
select 22.75%5;

-- 幂运算 pow()  
select pow(2,3) -- 8 

-- 7.2.2 控制数字精度
-- 取整函数 ceil(),floor()
select ceil(2.5) ,floor(2.5)  ;

-- 四舍五入  round(X,N)
select round(2.4),round(2.5);
#round() 还可以指定小数部分保留位数
select round(7.0909,1),round(7.0909,2),round(7.0909,3);
#可选参数可为负,表示小数点左侧取整多少位
select round(145.23,-2); -- 100
select round(17.1,-1); -- 20

-- truncate(X,N) 截断不需要的小数位，不进行四舍五入
select truncate(7.0909,1),truncate(7.0909,2) ,truncate(7.0909,3);
#truncate() 可选参数也可以为负，表示小数点左侧截断多少位
select truncate(145.23,-2),truncate(17.1,-1);

-- 7.2.3 处理有符号数
-- sign(X) X<0 返回 -1 ，X=0 返回 0 ，x>0 返回 1 
select sign(-2),sign(0),sign(2);

-- abs(X) 返回X的绝对值
select abs(-2),abs(2);

-- 7.3 使用时间数据
-- 7.3.1查看当前时区设置
select @@global.time_zone,@@session.time_zone;
#SYSYTEM表示服务器根据数据库所在地使用相应时区设置

-- 7.3.2更改当前时区
#set time_zone = 'Europe/Zurich';

-- 7.4 生成时间数据

-- 7.4.1cast() 函数 
#构建datetimel类型的值
select cast('2020-7-24 22:23:30' as datetime);
#构建 date 和 time 类型的值
select cast('2020-7-24' as date) date,cast('22:23:30' as time) time;

-- 7.4.2 str_to_date 字符串转换为日期
select str_to_date('September 17,2020','%M %d,%Y');

-- 获取当前 日期 /时间 
select current_date(),current_time,current_timestamp();

-- 7.4.3 操作时间数据
-- 添加日期间隔 date_add()
#为当前日期增加5 天
select date_add(current_date(),interval 5 day) ;
#为某时间增加 minute_second 
select date_add(now(),interval '23:32' minute_second);
#为某时间增加 hour_second
select date_add(now(),interval '2:23:32' hour_second);
#为某时间增加 year_month
select date_add(current_date(),interval '1-1' Year_month);

-- last_day() 求当前月最后一天
select last_day(now());

-- dayname()
select dayname(now()) ; 

-- monthname()
select monthname(now());

-- extract() 提取日期中的信息 extract(year|month|week|day|minute from time)
select extract( from now());
 
 -- date_diff() 返回两个日期之间的天数
 select datediff(current_date(),'2019-10-1');
 
 -- 7.5 转换函数
 -- cast()不止可以转换字符串为datetime值
 select 
 cast('123' as signed integer),
 cast('-123' as signed integer),
 cast('123sds234' as signed integer),
 cast('-123sds234' as signed integer);
 
 -- 7.6 Test
 -- 7.6.1 编写查询，返回字符串 'Please find the substring in this string' 的第17和第25个字符
 select substring('Please find the substring in this string' ,17,1),
 substring('Please find the substring in this string' ,25,1);
 
 -- 编写查询，返回数字 -25.76823 的绝对值和符号（-1，0或1），并将返回值四舍五入至百分位
 select abs(-25.76823),sign(-25.76823),round(-25.76823,2);
 
 -- 编写查询，返回当前日期所在月份
 select month(now());
 select extract(month from now());