-- 1 задание
use AdventureWorks2012;
select * from Sales.SpecialOffer;
go

alter procedure sales.pivselect
@paramet nvarchar(100)
as
begin
declare @sql nvarchar(max)
set @sql='
select *
from
(select name,Category, DiscountPct from Sales.SpecialOffer
inner join sales.SpecialOfferProduct on Sales.SpecialOffer.SpecialOfferID=sales.SpecialOfferProduct.SpecialOfferID
inner join production.Product on Production.Product.ProductID=Sales.SpecialOfferProduct.ProductID) p pivot
(
max(DiscountPct)
for Category in
('+ @paramet +')
) as pvt'
exec(@sql)
end;

drop procedure sales.pivselect;

--@
EXEC sales.pivselect '[Reseller],[No Discount],[Customer]';


--2 задание

select * from HumanResources.EmployeeDepartmentHistory;
select * from HumanResources.Department;

declare @DepartmentXml xml;
set @DepartmentXml=
(select 
	StartDate "Start", 
	EndDate"end", 
	GroupName"Department/Group", 
	Name "Department/Name"
from HumanResources.EmployeeDepartmentHistory
inner join HumanResources.Department
on HumanResources.EmployeeDepartmentHistory.DepartmentID=HumanResources.Department.DepartmentID
for xml path('Transaction'), root('History'));
--@
select @DepartmentXml;

SELECT    xmlNode.query('.') AS XmlNode
FROM    @DepartmentXml.nodes('/History/Transaction/Department') AS xmlNodes(xmlNode)

insert into #xml
SELECT    xmlNode.query('.') AS XmlNode
FROM    @DepartmentXml.nodes('/History/Transaction/Department') AS xmlNodes(xmlNode);


create table #xml 
(sql xml);
--@
select * from #xml;
