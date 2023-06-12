create view specialProduct
with schemabinding
as 
select Sales.SpecialOffer.SpecialOfferID, Description, DiscountPct, Type, Category, StartDate, EndDate, MinQty, MaxQty, Sales.SpecialOffer.ModifiedDate, Product.ProductID, Name from
Sales.SpecialOffer
inner join Sales.SpecialOfferProduct
on Sales.SpecialOffer.SpecialOfferID=Sales.SpecialOfferProduct.SpecialOfferID
inner join Production.Product
on Sales.SpecialOfferProduct.ProductID=Production.Product.ProductID; 
go

create table Sales.SpecialOfferHst
(
ID int IDENTITY(1,1) primary key,
Action nchar(10),
ModifiedDate datetime,
SourceId int,
Username nchar(50)
);
go


Create Unique Clustered Index spprindex
on specialProduct (ProductID, SpecialOfferID);
go

select * from specialProduct;
go

alter trigger InstedOftrigger
on specialProduct
instead of insert, delete, update
as
if exists(select * from deleted) and exists (select * from inserted)
begin

update Sales.SpecialOffer 
set 
Description=(select Description from inserted),
DiscountPct=(select DiscountPct from inserted),
Type=(select Type from inserted),
Category=(select Category from inserted),
StartDate=(select StartDate from inserted),
EndDate=(select EndDate from inserted),
MinQty=(select MinQty from inserted),
MaxQty=(select MaxQty from inserted),
ModifiedDate=(select ModifiedDate from inserted)
where sales.SpecialOffer.SpecialOfferID in  
(select SpecialOfferID from inserted where name in (select name from inserted))

 insert into Sales.SpecialOfferHst (Action,ModifiedDate,SourceId, Username) 
select top 1 'update' ,getdate(), SpecialOfferID, USER_NAME() from inserted;
end

if not exists(select * from deleted) and exists (select * from inserted)
begin

if not exists (select specialOfferID from Sales.SpecialOffer where SpecialOfferId in (select SpecialOfferID from inserted))
insert into Sales.SpecialOffer (SpecialOfferID,Description,DiscountPct,Type, Category,StartDate,EndDate,MinQty,MaxQty,ModifiedDate)
select SpecialOfferID, Description,DiscountPct,Type, Category,StartDate,EndDate,MinQty,MaxQty,ModifiedDate from inserted

insert into Sales.SpecialOfferProduct (SpecialOfferID, ProductID,ModifiedDate)
select SpecialOfferID, ProductID,ModifiedDate from inserted 

insert into Sales.SpecialOfferHst (Action,ModifiedDate,SourceId, Username) 
select top 1 'insert' ,getdate(), SpecialOfferID, USER_NAME() from inserted;

end

if exists(select * from deleted) and not exists (select * from inserted)
begin

insert into Sales.SpecialOfferHst (Action,ModifiedDate,SourceId, Username) 
select top 1 'delete' ,getdate(), SpecialOfferID, USER_NAME() from deleted;

delete from Sales.SpecialOfferProduct 
where Sales.SpecialOfferProduct.ProductId in (select Sales.SpecialOfferProduct.ProductID from Production.Product 
inner join Sales.SpecialOfferProduct on Sales.SpecialOfferProduct.ProductID=Production.Product.ProductID where name in (select name from deleted))


if not exists (select specialOfferId from specialProduct where specialOfferId in (select SpecialOfferID from deleted)) 

delete from Sales.SpecialOffer
where Sales.SpecialOffer.SpecialOfferID in (select SpecialOfferID from deleted where name in (select name from deleted))
end;
go


SET IDENTITY_INSERT sales.SpecialOffer On;

insert into specialProduct(SpecialOfferID,Description,DiscountPct,Type, Category,StartDate,EndDate,MinQty,MaxQty,ModifiedDate, ProductID,Name) values
(28,'discount',0.00,'discount','Reseller',getdate(),getdate(),0,0,getdate(),1,'Adjustable Race');

select * from Sales.SpecialOfferProduct;
select * from Sales.SpecialOffer;

update specialProduct set 
Category='Customer'
where Name='Adjustable Race';

select * from Sales.SpecialOfferProduct;
select * from Sales.SpecialOffer;

delete from specialProduct where name='Adjustable Race';

select * from Sales.SpecialOfferProduct;
select * from Sales.SpecialOffer;

select * from Sales.SpecialOfferHst;



delete from Sales.SpecialOffer where SpecialOfferID=28;
select * from Sales.SpecialOfferProduct;
select * from specialProduct;
select * from Sales.SpecialOffer;
select * from Production.Product;
go


-- 2 задание 

create function getstartdate(@id as int)
returns nvarchar(30)
as 
begin
declare @result nvarchar(30)
select @result= case
when Month(StartDate)=1 then 'January'
when Month(StartDate)=2 then 'February'
when Month(StartDate)=3 then 'March'
when Month(StartDate)=4 then 'April'
when Month(StartDate)=5 then 'May'
when Month(StartDate)=6 then 'June'
when Month(StartDate)=7 then 'July'
when Month(StartDate)=8 then 'August'
when Month(StartDate)=9 then 'September'
when Month(StartDate)=10 then 'October'
when Month(StartDate)=11 then 'November'
when Month(StartDate)=12 then 'December'
end
+', '+cast(day(startdate) as nchar(2))+'. '+
case
when datepart(WEEKDAY,startdate) =1 then 'Sunday'
when datepart(WEEKDAY,startdate) =2 then 'Monday'
when datepart(WEEKDAY,startdate) =3 then 'Tuesday'
when datepart(WEEKDAY,startdate) =4 then 'Wensday'
when datepart(WEEKDAY,startdate) =5 then 'Thursday'
when datepart(WEEKDAY,startdate) =6 then 'Friday'
when datepart(WEEKDAY,startdate) =7 then 'Saturday'
end 
from Sales.SpecialOffer where SpecialOfferID=@id;
return @result
end;
go

select * from Sales.SpecialOffer;

select dbo.getstartdate(2);
go


create function getproduct (@id as int)
returns table
as
return
select distinct name from Production.Product
inner join Sales.SpecialOfferProduct 
on Production.Product.ProductID=Sales.SpecialOfferProduct.ProductID
where Sales.SpecialOfferProduct.SpecialOfferID=@id
go

select * from getproduct(11);

select * from sales.SpecialOffer cross apply getproduct(SpecialOfferID) order by SpecialOfferID;

select * from sales.SpecialOffer outer apply getproduct(SpecialOfferID) order by SpecialOfferID;
go


create function getproductTable (@id as int)
returns @nameOfProducts Table(
name nvarchar(40)
)
as
begin
insert into @nameOfProducts
select distinct name from Production.Product
inner join Sales.SpecialOfferProduct 
on Production.Product.ProductID=Sales.SpecialOfferProduct.ProductID
where Sales.SpecialOfferProduct.SpecialOfferID=@id
return;
end;
go


select * from getproductTable(15);