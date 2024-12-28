use ankit_bansal_sql_practise

create table emp1(
emp_id int,
emp_name varchar(20),
department_id int,
salary int,
manager_id int,
emp_age int);

insert into emp1
values
(1, 'Ankit', 100,10000, 4, 39);
insert into emp1
values (2, 'Mohit', 100, 15000, 5, 48);
insert into emp1
values (3, 'Vikas', 100, 10000,4,37);
insert into emp1
values (4, 'Rohit', 100, 5000, 2, 16);
insert into emp1
values (5, 'Mudit', 200, 12000, 6,55);
insert into emp1
values (6, 'Agam', 200, 12000,2, 14);
insert into emp1
values (7, 'Sanjay', 200, 9000, 2,13);
insert into emp1
values (8, 'Ashish', 200,5000,2,12);
insert into emp1
values (9, 'Mukesh',300,6000,6,51);
insert into emp1
values (10, 'Rakesh',300,7000,6,50);
insert into emp1
values (1,'Saurabh', 900,1200,2,50);

create table dept(
dep_id int,
dep_name varchar(20)
);

insert into dept
values (100, 'Analytics');
insert into dept
values (300, 'IT');

create table orders(
 customer_name char(10),
 order_date date,
 order_amount int,
 customer_gender char(6)
 );

  insert into orders values('Shilpa','2020-01-01',10000,'Male');
 insert into orders values('Rahul','2020-01-02',12000,'Female');
 insert into orders values('Shilpa','2020-01-02',12000,'Male');
 insert into orders values('Rohit','2020-01-03',15000,'Female');
 insert into orders values('Shilpa','2020-01-03',14000,'Male');




select * from emp1

## Q1- How to find duplicates in a given table

select emp_id, count(1) from emp1 group by 1 having count(1)>1

## Q2 - Difference Between union and union all

select manager_id from emp1
union all select manager_id from emp1


select manager_id from emp1
union  select manager_id from emp1                ---- removing dublicates 




## Q3 - Second Highest salary in each dep

select * from(select emp1.*, dense_rank() over(partition by department_id order by salary desc) as rn from emp1) a
where rn=2

## Q4 - find all treansaction done by shilpa

select * from orders where  upper(customer_name) = "Shilpa"


## Q5 - update query to swap gender

select * from orders 


update orders set customer_gender =case when customer_gender ='Male' then 'Female'
when customer_gender='Female' then 'Male' end 
