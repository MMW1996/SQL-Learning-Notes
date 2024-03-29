-- Chapter2 创建和使用数据库
-- 登录mysql数据库并选择要使用的数据库
-- mysql -u user_name -p database

-- 2.1数据库的创建
drop database if exists bank;
create database bank;

-- 表的创建
use bank;
drop table if exists person;
create table person
(person_id smallint unsigned,
 fname varchar(20) comment 'first name',
 lname varchar(20) comment 'last name',
 gender enum('M','F') ,
 birth_date date,
 street varchar(30),
 city varchar(20),
 state varchar(20),
 country varchar(20),
 postal_code varchar(20),
 constraint pk_person primary key(person_id));

-- 创建 fevorite_food 表
drop table if exists favorite_food;
create table favorite_food
(person_id smallint unsigned,
food varchar(20),
constraint pt_favorite_food primary key(person_id,food),
constraint fk_favorite_person_id foreign key(person_id) references person(person_id) );

-- 确认表是否创建
desc  favorite_food;
desc person;


-- 2.2 操作和修改表
-- 为person.person_id 添加自增特性
alter table favorite_food drop foreign key fk_favorite_person_id; 
alter table person modify person_id smallint unsigned auto_increment ;
alter table favorite_food add constraint fk_favorite_person_id foreign key(person_id) references person(person_id);
/** 由于person_id存在外键，因此直接修改会报错，因此这里先暂时将外键约束删除
    为person.person_id 增加auto_increment 后在重新创建外键**/

-- insert
-- insert 为willia turner创建一行
insert into person(person_id,fname,lname,gender,birth_date) values(1,'william','turner','M','1972-05-27');

-- willian 喜欢的三种食物
insert into favorite_food values(1,'pazza'),(1,'cookies'),(1,'nachos');

-- 列出这三种食物并按食物排序
select * from favorite_food where person_id =1 order by food;

-- insert 为susan smith创建一行
insert into person values(null,'susan','smith','F','1975-11-02','23 Maple st','Arlington','VA','USA','20220');

-- 查询该表,可以看到susan的id被自动赋值为2
select * from person;

-- update
-- 更新william的住址信息
update person  set 
street='1225 Tremont St',
city='Boston',
state='MA',
country='USA',
postal_code ='02138'
where person_id=1;

-- delete
-- 删除一行信息
set foreign_key_checks=0;
delete from person where person_id=2;
set foreign_key_checks=1;
/**这里还是由于foreign key 的原因，直接删除会触发外键约束报错，因此先暂时关闭外键约束检查，删除后再恢复。**/


--  2.3
/**
下面列出一些常见的会导致错误的语句，以及mysql服务器是如何应答的

2.3.1 主键不唯一
insert into person(person_id,fname,lname,gender,birth_date) values(1,'Charles','Fulton','M','1968-01-15');
> 1062 - Duplicate entry '1' for key 'person.PRIMARY'

2.3.2不存在的外键
insert into favorite_food(person_id,food) values(99,'rice');
> 1452 - Cannot add or update a child row: a foreign key constraint fails (`bank`.`favorite_food`, CONSTRAINT `fk_favorite_person_id` FOREIGN KEY (`person_id`) REFERENCES `person` (`person_id`))

由于favorite.person_id 上存在外键约束，引用了person.person_id ,可将person表视为父表，favorite_food 表视为子表，则在favorite_food表中创建一行前，必须先在person表中创建一行。

2.3.3列值不合法
update person set gender='T' where person_id=1;
> 1265 - Data truncated for column 'gender' at row 1
 gender列为enum类型，定义值只能为 'M' ,'F'
 
 2.3.4 无效的日期转换
 update person set birth_date='DEC-21-1980 ' where person_id=1;
 > 1292 - Incorrect date value: 'DEC-21-1980 ' for column 'birth_date' at row 1
要构建用于产生日期类型的字符串，该字符串必须符合要求的格式，否则会产生转换错误
通常，显式指定字符串格式比依赖默认格式更好，如使用str_to_date()函数
**/

