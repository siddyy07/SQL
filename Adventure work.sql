# we have 'advantureworks' database and in that we have some tables, tables have some coulmns, we need to find data according to our project  
#                                          now we are going to find some question's answers 
# 1. What are the top 10 highest selling products in the database?

USE adventureworks;

SELECT * FROM salesorderdetail;
SELECT * from specialofferproduct;

SELECT * from product;

create database adventure_works1;

Create Table adventure_works1
select * from 
 (
 select * ,
 row_number() over(partition by Rank_ order by productId) as row_no
 from 
 (
 select * from  
(
select  c.productID, `Name`, a.linetotal as Total_Sales,
dense_rank() over( order by a.linetotal desc) as Rank_
from salesorderdetail as a
left join 
specialofferproduct as b    on a.productID = b.productID
left join 
product as c                on b.productID = c.ProductID  
) as a 
where Rank_ <= 10 
) as a 
) as a 
where  row_no = 1 ;

SELECT * FROM adventure_works1;
# 2.Who are the top 10 highest spending customers in the data along with their address and address type information?

SELECT * FROM salesorderheader;
SELECT * FROM address;
SELECT * FROM addresstype;
SEleCt * FROM customeraddress;

create table adventure_works2
select * from 
(
select * ,
row_number () over(partition by Rank_ order by customerID ) as Row_no 
from 
(
select * from 
(
select a.customerId, e.`Name`, b.addressline1, a.totaldue as Total_sales,
dense_rank () OVER (order by a.totaldue) as Rank_
from salesorderheader as a
left join 
address as b                on a.modifieddate = b.modifieddate
left join
customer as  c              on a.customerId = c.customerId
left join
customeraddress  as d       on c.customerId = d.customerId
left join 
addresstype as  e           on d.addresstypeid = e.addresstypeid 
) as a 
where Rank_ <= 10 
) as  a 
) as a 
where rank_ <= 10  and  Row_no = 1 ;

SELECT * FROM adventure_works2;

# 3. Calculate the Sales by Sales Reason Name and Reason Type. Also find the best and worst performing 
     #Sales Reason in terms of Sales 
     
SELECT * FROM salesreason;
SELECT * FROM salesorderheadersalesreason;

CREATE table adventure_works3
select * from 
(
select *, 
row_number() over( partition by `Name` order by Rank_ ) as row_no 
from
(
select c.`name`, c.reasontype, b.totaldue as Total_Sales, 
dense_rank () over (partition by c.`name` order by b.totaldue desc ) as Rank_ 
from salesorderheadersalesreason as a
left join 
salesorderheader as b  on a.salesorderID = b.salesorderID 
left join 
salesreason as c       on a.salesreasonid = c.salesreasonid 
) as a  
)
 as a 
where  row_no = 1 
order by Total_Sales ;

#in above code, we have  best sales reson according to total_sales now in below code we will find worst sales reason as per sales

create table adventure_works3_Worst  
select * from 
(
select *, 
row_number() over( partition by `Name` order by Rank_ ) as row_no 
from
(
select c.`name`, c.reasontype, b.totaldue as Total_Sales, 
dense_rank () over (partition by c.`name` order by b.totaldue  ) as Rank_ 
from salesorderheadersalesreason as a
left join 
salesorderheader as b  on a.salesorderID = b.salesorderID 
left join 
salesreason as c       on a.salesreasonid = c.salesreasonid 
) as a  
)
 as a 
where  row_no = 1 
order by Total_Sales;
SELECT * FROM adventure_works3_Worst ;

#4.Calculate the average number of orders shipped by different Ship methods for  each month and year

CREATE table adventure_works4
select Year_, Month_, Shipment_Type, avg(Total_Shipments) as Total_Shipments
from 
(
select year(a.shipdate) as Year_ , month(a.shipdate) as Month_, b.`Name` as Shipment_Type , totaldue as Total_Shipments
from salesorderheader as a
left join 
shipmethod as b  on     a.shipmethodid = b.shipmethodid  
) as a 
group by Year_, Month_, Shipment_Type
order by Year_, Month_, Shipment_Type ; 

SELECT * FROM adventure_works4;

#5. Calculate the count of orders, maximum and minimum shipped by different Credit Card Type for each month and year

select * from salesorderheader ;
select distinct cardtype from creditcard ;
select * from creditcard ;

create table adventure_works5
select Year_, Month_, cardtype, count(a.CreditCardApprovalCode) as Total_orders, 
min(Total_Sales) as minimum_orders, max(Total_Sales) maximun_orders 
from 
(
select year(orderdate) as Year_, month(orderdate) as Month_, b.cardtype, 
a.CreditCardApprovalCode as CreditCardApprovalCode , a.totaldue	as Total_Sales 	
from salesorderheader as a 
left join
creditcard as b   on  a.creditcardid = b.creditcardid 
) as a
group by Year_, Month_, cardtype 
order by Year_, Month_, cardtype ;
SELECT * FROM adventure_works5;


#6. Which are the top 3 highest selling Sales Person by Territory for each month and year

select * from salesperson ;
select * from  salesorderheader ;
select * from salesterritory ;

CREATE TABLE adventure_works6

select * from   
 (   
select *,
row_number() over (partition by Year_ ,Month_  order by Total_Sales desc ) as Top_3
from 
(
select * ,
dense_rank () over(partition by Year_ , Month_ order by Total_Sales desc ) as Rank_
from                                            
  (                                            
 select * from                                              
 (                                             
select Year_, Month_, Sales_Person, `Name` as Region, sum(totaldue) as Total_Sales  
from 
( 
select year(b.orderdate) as Year_, month(b.orderdate) as Month_, a.salespersonid as Sales_Person , c.`Name`, b.totaldue
from  salesperson as a
left join                                          
salesorderheader as b  on   a.territoryid = b.territoryid 
left join 
salesterritory   as c  on   b.territoryid = c.territoryid 
) as a 
group by Year_, Month_, Sales_Person, `Name` 
order by Year_, Month_, Sales_Person, `Name`
)   as a 
where Total_Sales is not null 
) as a
)  as a  
)as a
where Rank_ <= 3 and  Top_3 <= 3;    

SELECT * FROM adventure_works6; 


#Calculate the count of employees and average tenure per department name and department group name. 
                                
select * from employee ;
 select * from department ;
 select * from employeedepartmenthistory ;
 
 select distinct `Name` from department ;
 
 CREATE TABLE  adventure_works8
 select  `Name`, groupname, count(employeeid),
    avg(Tenure_inDays) ,  avg(Tenure_inYears)
 from 
 (
 select  a.employeeid,  c.`Name`, c.groupname, 
 datediff(curdate(), a.hiredate) as Tenure_inDays,datediff(curdate(), a.hiredate)/365.25 as Tenure_inYears
 from  employee as a
 left join 
 employeedepartmenthistory as  b   on  a.employeeid = b.employeeid 
 left join 
 department as c    on  b.departmentid = c.departmentid 
 ) as a 
 group by `Name`, groupname 
 order by `Name`, groupname ;
 SELECT * FROM adventure_works8;
 







