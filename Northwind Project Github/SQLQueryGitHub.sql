--1. find duplicates
select ShipCity,COUNT(*) as[c] from Orders group by ShipCity having COUNT(*) > 1 

--2. delete duplicates
with d as (
select ShipCity,row_number() over( partition by ShipCity order by (select NULL)) as [row number] from Orders
)
delete shipcity from d where [c] >1 

--3. This query Display the employee who placed the highest number of orders in February and March, along with the count of their orders:
select top 1 e.EmployeeID,COUNT(orderid) as[c]
from orders o inner join Employees e
on o.EmployeeID = e.EmployeeID
where month(o.OrderDate) in (2,3)
group by e.EmployeeID
order by COUNT(orderid) desc


--4. This query Display the last 5 rows from the Employees table:
select * from ( select *, ROW_NUMBER() over (order by (select NULL)) as rn
    from Employees
) as sub
where rn > (select count(*) - 5 from Employees)


--5. This query Display the product name, price, and units in stock for products that have more units in stock than the maximum amount of any product in category 5:
select UnitsInStock, ProductName, UnitPrice, CategoryID from Products where UnitsInStock > (select MAX(UnitsInStock) from Products where CategoryID = 5)


--6. This query Display the category names and total price for categories, along with the average total price of all categories:
with sales as (
select c.CategoryName,SUM(p.UnitPrice) as [total price]
from Categories c inner join Products p 
on c.CategoryID = p.CategoryID
group by CategoryName
)
select CategoryName,[total price], AVG([total price]) over () as average from sales


--7. This query Display the categories where the average product price is higher than the overall average, including the maximum product price in those categories:
select top 1 p.UnitPrice,c.CategoryID
from Categories c inner join Products p
on c.CategoryID =p.CategoryID 
where UnitPrice > (select AVG(UnitPrice) from Products)
order by p.UnitPrice desc


--8. This query counting the number of products priced above the average product price:
select COUNT(case when UnitPrice > ( select AVG(UnitPrice) from Products) then UnitPrice else NULL end) from Products


--9. This query Display the full names of employees hired after the first 3 employees: 
select FirstName + ' ' + LastName, HireDate
from Employees  where HireDate > ( select MIN(HireDate) from (
select top 3 HireDate from Employees order by HireDate ) as [FirstThreeEmployees]
)


--10. This query Display the category names that have more products than the number of employees:
select distinct c.CategoryName,p.ProductID
from Categories c inner join Products p
on c.CategoryID = p.CategoryID
where p.ProductID > (select COUNT(EmployeeID) from Employees)


--11. This query Display the number of orders per year:
select COUNT(od.OrderID), year(o.OrderDate)  
from [Order Details] od inner join Orders o 
on od.OrderID  = o.OrderID 
group by year(o.OrderDate)


--12. Report that display the number of orders per customer per city, per customer per country, and overall:
select c.City,c.Country, COUNT(OrderID) as [order amount] 
from Orders o inner join Customers c
on o.CustomerID =c.CustomerID
group by grouping sets( c.City,c.Country,())


--13. This query Display the category name, product name, product price, previous product price, and next product price in descending order:
select c.CategoryName,p.ProductName,p.UnitPrice,
LAG(p.UnitPrice) over (order by p.UnitPrice) as [previous price],
LEAD(p.UnitPrice) over (order by p.UnitPrice) as [next price]
from Products p inner join Categories c
on p.CategoryID=c.CategoryID
order by p.UnitPrice  


--14. Report that display the product number, order number, and service rating based on the time between order date and shipped date:
select od.ProductID,o.OrderID, datediff(day, o.OrderDate,o.ShippedDate) [Days of Service], 
case
	when DATEDIFF(day,o.OrderDate,o.ShippedDate) >10 then 'Bad Service'
	when datediff(day, o.OrderDate,o.ShippedDate) between 4 and 10 then 'OK Service'
	when datediff(day, o.OrderDate,o.ShippedDate) <=3 then 'Good Service'
	else 'No Relevent' 
end as [Services Types]
from [Order Details] od inner join Orders o
on od.OrderID =o.OrderID


--15. Report that display the product name, order number, revenue from the product, and day of the week of the order:
select p.ProductName,OrderDate,o.OrderID, od.UnitPrice * od.Quantity as [revenue],
case 
	when datepart(WEEKDAY,o.OrderDate) in(6,7) then 'weekend'
	else 'weekday'
end as [DayOfWeek]
from Orders o inner join [Order Details] od
on o.OrderID = od.OrderID 
inner join Products p 
on p.ProductID = od.ProductID


--16. Report that display the number of orders for customer 'SAVEA' in 1996 and 1997, and for customer 'ERNSH' in 1996 and 1997:
select c.CustomerID,COUNT(o.orderID)
from Orders o inner join Customers c
on o.CustomerID = c.CustomerID
where c.CustomerID in('SAVEA', 'ERNSH') and YEAR(OrderDate) in(1996,1997) 
group by c.CustomerID


--17. Report that display the top 5 customers with the highest number of orders, including customer number, company name, order count, and customer ranking:
select top 5 c.CustomerID,c.CompanyName, count(o.orderID) as [orders amount],
ROW_NUMBER() over (order by count(o.orderID) desc) as [rank]
from Orders o inner join Customers c
on o.CustomerID=c.CustomerID
group by c.CustomerID,c.CompanyName
order by  count(o.orderID) desc


--18. This query display the next details:
-- amount of orders on each customer on each city
-- amount of orders on each customer on each country
-- amount oh orders
select c.City,c.Country, COUNT(OrderID) as [order amount] 
from Orders o inner join Customers c
on o.CustomerID =c.CustomerID
group by grouping sets( c.City,c.Country)


--19. This Query display the top 3 customers with the lowest order counts, where the customer names start with 'A' or 'L':
select top 3 c.CustomerID,COUNT(o.OrderID) 
from Customers c inner join Orders o
on c.CustomerID = o.CustomerID
where c.CustomerID like 'A%' or c.CustomerID like 'L%'
group by c.CustomerID
order by COUNT(o.OrderID) asc


--20. This Display the customers whose freight cost is above the average, sorted by contact name:
select o.CustomerID,c.ContactName 
from Orders o inner join Customers c
on o.CustomerID =c.CustomerID
where Freight > (select AVG(Freight) from Orders)
order by ContactName asc


--21. Report that detailing the city, company name, and contact name of customers from cities starting with 'A' or 'B' who have placed orders worth more than $1000 in total:
select * from Customers
select * from [Order Details] 
select c.City, c.CompanyName,c.ContactName, SUM(od.Quantity * od.UnitPrice) AS TotalOrderValue
from Customers c inner join Orders o 
on c.CustomerID = o.CustomerID
inner join [Order Details] od
on o.OrderID = od.OrderID
where City like 'A%' or City like 'B%' 
group by c.City, c.CompanyName,c.ContactName
having SUM(od.Quantity * od.UnitPrice) > 1000


--22. Report that listing all even OrderID values where the order's total price is above the median total price of all orders:
select o.OrderID , sum(od.UnitPrice * od.Quantity)
from  [Order Details] od inner join Orders o
on od.OrderID = o.OrderID
where o.OrderID %2=0 
group by o.OrderID
having  sum(od.UnitPrice * od.Quantity) >  sum(od.UnitPrice * od.Quantity) /2

--23. This query lists employees who do not have any supervisors, along with the number of employees they directly supervise.
select  concat(FirstName,' ',LastName) ,count(employeeid) from Employees where ReportsTo is null group by FirstName,LastName

--24. Report that displaying ContactName, ContactTitle, and CompanyName of customers whose ContactTitle does not include the word "Sales" and who have placed at least one order in the last 6 months.
select c.ContactName, c.ContactTitle,c.CompanyName, count(o.OrderID) as [order count]
from Customers c inner join Orders o  
on c.CustomerID = o.CustomerID
where ContactTitle not like '%Sales%' and OrderDate >='1997-12-01'
group by c.ContactName, c.ContactTitle,c.CompanyName
having count(o.OrderID) >= 1


--25. This query displays the CompanyName and ContactName for all customers who do not have a fax number and have made a purchase in the last year. 
--It also includes the total amount spent by each customer.
select  CompanyName,ContactName,Fax ,o.OrderDate
from Customers c inner join orders o 
on c.CustomerID = o.CustomerID
where Fax is null and year(OrderDate) = (select  MAX(year(OrderDate)) from Orders)

----26. Report that displays the total average, average of UnitPrice rounded to the next and previous whole numbers, total price of UnitsInStock 
--and maximum number of orders from the products table. All saved as AveragePrice, TotalPriceOnStock and MaxOrder respectively.
with [AveragePrice, TotalStock and MaxOrder respectively] as(
select AVG(unitprice)as [avg],ceiling(AVG(unitprice)) as[round to up number],FLOOR(AVG(UnitPrice))as[round to down number],SUM(UnitPrice * UnitsInStock) as [total],MAX(UnitsOnOrder) as [max]
from Products
)
select * from [AveragePrice, TotalStock and MaxOrder respectively]


--DDL Operations and String Manipulations:
--Create test table
create table testTBL (
intcol int,
varcharCol varchar(5),
nvarcharcol nvarchar(5),
datcol date,
decimalcol decimal (8,2),
charcol char (1),
floatCol float
);

-- Insert data into the test table
insert into testTBL (intcol, varcharCol, nvarcharcol, datcol, decimalcol, charcol, floatCol) values 
(60,'test','test1','1998-08-04',50.02,'!',16.456);

-- Add a discounted price column to [Order Details] table
ALTER TABLE [Order Details] ADD Discounted_Price DECIMAL(10, 2);
-- Update discounted prices based on unit price and discount
UPDATE [Order Details] SET Discounted_Price = UnitPrice * (1 - discount);

-- Delete employee Janet from the Employees table
delete Employees where FirstName ='Janet' -- Employee Janet left the company

-- Example string manipulations
SELECT LEFT(FirstName, 8) AS LeftThreeChars from Employees; 
SELECT RIGHT(FirstName, 8) AS LeftThreeChars from Employees;
select FirstName,LastName, CONCAT(FirstName,' ', LastName) as [Full Name] from Employees -- full name by CONCAT function
select FirstName,REPLACE(FirstName,'a','A') from Employees where FirstName ='Rahul Gandhi'
select SUBSTRING(FirstName, 6,4) from Employees where FirstName = 'Rahul Gandhi'
select FirstName,TRIM(FirstName) from Employees --check for unnecessary space
select FirstName, LOWER(FirstName) from Employees where FirstName = 'Rahul Gandhi' --display the names in lower letters
select FirstName, UPPER(FirstName) from Employees where FirstName = 'Rahul Gandhi' --display the names in upper letters

