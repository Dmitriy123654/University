use AdventureWorks2012;
GO
--a) Создайте представление VIEW, отображающее данные из таблиц Sales.SpecialOffer и Sales.SpecialOfferProduct,
--а также Name из таблицы Production.Product. 
--Создайте уникальный кластерный индекс в представлении по полям ProductID, SpecialOfferID.
CREATE VIEW view1
WITH SCHEMABINDING
AS SELECT Sales.SpecialOffer.Category,Sales.SpecialOffer.Description,Sales.SpecialOffer.DiscountPct,
	Sales.SpecialOffer.EndDate,Sales.SpecialOffer.MaxQty,Sales.SpecialOffer.MinQty,
	Sales.SpecialOffer.ModifiedDate as ModifiedDate1,Sales.SpecialOffer.rowguid as rowguid1,Sales.SpecialOffer.StartDate,Sales.SpecialOffer.Type,
	Sales.SpecialOfferProduct.ModifiedDate,Sales.SpecialOfferProduct.ProductID,Sales.SpecialOfferProduct.rowguid,
	Sales.SpecialOfferProduct.SpecialOfferID,Production.Product.Name  FROM Sales.SpecialOffer 
INNER JOIN Sales.SpecialOfferProduct ON Sales.SpecialOffer.SpecialOfferID=Sales.SpecialOfferProduct.SpecialOfferID
INNER JOIN Production.Product ON Sales.SpecialOfferProduct.ProductID = Production.Product.ProductID;
GO

CREATE UNIQUE CLUSTERED INDEX Index_View1
   ON dbo.view1 (ProductID, SpecialOfferID);
GO

SELECT * FROM view1;
--DROP VIEW view1;
-- GO

--b) Создайте один INSTEAD OF триггер для представления на три операции INSERT, UPDATE,DELETE. 
--Триггер должен выполнять соответствующие операции в таблицах Sales.SpecialOffer и Sales.SpecialOfferProduct для указанного Product Name. 
--Обновление не должно происходить в таблице Sales.SpecialOfferProduct.
--Удаление из таблицы Sales.SpecialOffer производите только в том случае,если удаляемые строки больше не ссылаются на Sales.SpecialOfferProduct.

CREATE TRIGGER view1_Trigger
ON view1
INSTEAD OF INSERT

--c) Вставьте новую строку в представление, указав новые данные SpecialOffer для существующего Product (например для ‘Adjustable Race’). 
--Триггер должен добавить новые строки в таблицы Sales.SpecialOffer и Sales.SpecialOfferProduct. 
--Обновите вставленные строки через представление.Удалите строки. 