use AdventureWorks2012;
GO
--a) �������� ������������� VIEW, ������������ ������ �� ������ Sales.SpecialOffer � Sales.SpecialOfferProduct,
--� ����� Name �� ������� Production.Product. 
--�������� ���������� ���������� ������ � ������������� �� ����� ProductID, SpecialOfferID.
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

--b) �������� ���� INSTEAD OF ������� ��� ������������� �� ��� �������� INSERT, UPDATE,DELETE. 
--������� ������ ��������� ��������������� �������� � �������� Sales.SpecialOffer � Sales.SpecialOfferProduct ��� ���������� Product Name. 
--���������� �� ������ ����������� � ������� Sales.SpecialOfferProduct.
--�������� �� ������� Sales.SpecialOffer ����������� ������ � ��� ������,���� ��������� ������ ������ �� ��������� �� Sales.SpecialOfferProduct.

CREATE TRIGGER view1_Trigger
ON view1
INSTEAD OF INSERT

--c) �������� ����� ������ � �������������, ������ ����� ������ SpecialOffer ��� ������������� Product (�������� ��� �Adjustable Race�). 
--������� ������ �������� ����� ������ � ������� Sales.SpecialOffer � Sales.SpecialOfferProduct. 
--�������� ����������� ������ ����� �������������.������� ������. 