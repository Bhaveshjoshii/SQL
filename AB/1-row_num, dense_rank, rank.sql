create database ankit_bansal_sql_practise 

use ankit_bansal_sql_practise 

create table employee(
emp_id int ,
emp_name varchar(20),
department_id int,
salary  int);

drop table employee

insert into employee values(1,'Ankit',100,10000);
insert into employee values(2,'Mohit',100,15000);
insert into employee values(3,'Vikas',100,10000);
insert into employee values(4,'Rohit',100,5000);
insert into employee values(5,'Mudit',200,12000);
insert into employee values(6,'Agam',200,12000);
insert into employee values(7,'Sanjay',200,9000);
insert into employee values(8,'Ashish',200,5000);

select * from employee

select emp_id, emp_name, department_id,salary
,Rank() over(order by salary desc) as rnk,
dense_rank() over(order by salary desc) as dense_rnk,
row_number() over(order by salary desc) as rn
from employee;

select emp_id, emp_name, department_id,salary
,Rank() over(partition by department_id order by salary desc) as rnk,
dense_rank() over(partition by department_id order by salary desc) as dense_rnk,
row_number() over(partition by department_id order by salary desc) as rn
from employee;

-- find highest salary from each depatment 

select * from (
select emp_id, emp_name, department_id,salary
,Rank() over(partition by department_id order by salary desc) as rnk
from employee) as emp
where rnk=1