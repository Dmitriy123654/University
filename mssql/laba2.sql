USE AdventureWorks2012;
GO
--a) добавьте в таблицу dbo.StateProvince поле AddressType типа nvarchar(50);
ALTER TABLe dbo.StateProvince
ADD AddressType NVARCHAR(50);

--b) объявите табличную переменную с такой же структурой как dbo.StateProvince и 

DECLARE @StateProvince2 TABLE 
(
	StateProvinceID INT NOT NULL ,--PRIMARY KEY,--constraint PK_StateProvince_StateProvinceID PRIMARY KEY
	StateProvinceCode NCHAR(3) NOT NULL,
	CountryRegionCode NVARCHAR(3) NOT NULL ,--references Person.CountryRegion(CountryRegionCode),-- constraint FK_StateProvince_CountryRegion_CountryRegionCode references Person.CountryRegion(CountryRegionCode),
	IsOnlyStateProvinceFlag BIT NOT NULL,
	Name NVARCHAR(50) NOT NULL,
	TerritoryID INT NULL ,--references Sales.SalesTerritory(TerritoryID),-- constraint FK_StateProvince_SalesTerritory_TerritoryID references Sales.SalesTerritory(TerritoryID),
	ModifiedDate DATETIME NOT NULL,
	AddressType NVARCHAR(50)
);
--заполните ее данными из dbo.StateProvince. Поле AddressType заполните данными из таблицы Person.AddressType поля Name;
INSERT into @StateProvince2 (StateProvince2.StateProvinceID,StateProvince2.StateProvinceCode,
	StateProvince2.IsOnlyStateProvinceFlag,
	StateProvince2.Name,StateProvince2.CountryRegionCode,StateProvince2.ModifiedDate,
	StateProvince2.AddressType) 
select dbo.StateProvince.StateProvinceID,dbo.StateProvince.StateProvinceCode,
	dbo.StateProvince.IsOnlyStateProvinceFlag,
	dbo.StateProvince.Name,dbo.StateProvince.CountryRegionCode,dbo.StateProvince.ModifiedDate,Person.AddressType.Name
	from dbo.StateProvince
join Person.Address ON dbo.StateProvince.StateProvinceID=Person.Address.StateProvinceID
join Person.BusinessEntityAddress ON Person.BusinessEntityAddress.AddressID=Person.Address.AddressID
join Person.AddressType ON  Person.BusinessEntityAddress.AddressTypeID = Person.AddressType.AddressTypeID;
select * from @StateProvince2;

--c) обновите поле AddressType в dbo.StateProvince данными из табличной переменной, добавьте вначало
--названия каждого штата в поле Name название региона из Person.CountryRegion;
UPDATE dbo.StateProvince 
SET AddressType = temp2.AddressType
FROM (SELECT * FROM @StateProvince2) as temp2
WHERE dbo.StateProvince.StateProvinceID = temp2.StateProvinceId;

UPDATE dbo.StateProvince 
SET dbo.StateProvince.Name = temp1.Name + '  '+ dbo.StateProvince.Name
FROM (SELECT * FROM Person.CountryRegion) as temp1
WHERE temp1.CountryRegionCode = dbo.StateProvince.CountryRegionCode;
select * from dbo.StateProvince


--d) удалите данные из dbo.StateProvince, оставив по одной строке для каждого значения 
--из AddressType с максимальным StateProvinceID;

DELETE  dbo.StateProvince 
FROM (SELECT AddressType,MAX(StateProvinceID) as MaxId, COUNT(StateProvinceID) as TempCount  FROM dbo.StateProvince
	GROUP BY AddressType) AS temp1
WHERE dbo.StateProvince.AddressType=temp1.AddressType and dbo.StateProvince.StateProvinceID  != temp1.MaxId;

DELETE T
FROM
(
SELECT *
, DupRank = ROW_NUMBER() OVER (
              PARTITION BY  dbo.StateProvince.StateProvinceID,dbo.StateProvince.StateProvinceCode,
	dbo.StateProvince.IsOnlyStateProvinceFlag,
	dbo.StateProvince.Name,dbo.StateProvince.CountryRegionCode,dbo.StateProvince.ModifiedDate, dbo.StateProvince.AddressType,dbo.StateProvince.TerritoryId
              ORDER BY (SELECT NULL)
            )
FROM dbo.StateProvince
) AS T
WHERE DupRank > 1 

select * from dbo.StateProvince;	

--e) удалите поле AddressType из таблицы, удалите все созданные ограничения и значения поумолчанию.
--Имена ограничений вы можете найти в метаданных. Например:
--SELECT * FROM AdventureWorks2012.INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'StateProvince';
--Имена значений по умолчанию найдите самостоятельно, приведите код, которым пользовались для поиска;

SELECT * FROM AdventureWorks2012.INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'StateProvince';
sp_help StateProvince;
ALTER TABLE dbo.StateProvince
DROP CK_TerritoryID,DF_TerritoryID;

--f) удалите таблицу dbo.StateProvince.
DROP TABLE dbo.StateProvince;


--a) выполните код, созданный во втором задании второй лабораторной работы. 


--Добавьте в таблицу dbo.StateProvince поля TaxRate SMALLMONEY, CurrencyCode NCHAR(3) и AverageRate MONEY.
--Также создайте в таблице вычисляемое поле IntTaxRate, 
--округляющее значение в поле TaxRate в большую сторону до ближайшего целого.
use AdventureWorks2012;
go
ALTER TABLE dbo.StateProvince
ADD TaxRate SMALLMONEY, CurrencyCode NCHAR(3), AverageRate MONEY;
ALTER TABLE dbo.StateProvince
ADD IntTaxRate AS (CEILING([TaxRate])) PERSISTED ; 

SELECT *FROM dbo.StateProvince
--b) создайте временную таблицу #StateProvince, с первичным ключом по полю StateProvinceID.
--Временная таблица должна включать все поля таблицы dbo.StateProvince за исключением поля IntTaxRate.

SELECT StateProvinceID,StateProvinceCode,IsOnlyStateProvinceFlag,
	Name,CountryRegionCode,ModifiedDate,TerritoryID,
	AddressType, CurrencyCode,AverageRate,TaxRate
INTO #StateProvince
FROM dbo.StateProvince;
-- или
--DROP TABLE #StateProvince;
CREATE TABLE #StateProvince
(
	StateProvinceID INT NOT NULL PRIMARY KEY, --constraint PK_StateProvince_StateProvinceID PRIMARY KEY,----
	StateProvinceCode NCHAR(3) NOT NULL,
	CountryRegionCode NVARCHAR(3) NOT NULL references Person.CountryRegion(CountryRegionCode),--constraint FK_StateProvince_CountryRegion_CountryRegionCode references Person.CountryRegion(CountryRegionCode),-- -- 
	IsOnlyStateProvinceFlag SMALLINT NULL,
	Name NVARCHAR(50) NOT NULL,
	TerritoryID INT NOT NULL references Sales.SalesTerritory(TerritoryID) --constraint FK_StateProvince_SalesTerritory_TerritoryID references Sales.SalesTerritory(TerritoryID)--
		CONSTRAINT DF_TerritoryID   DEFAULT 2 
		CONSTRAINT CK_TerritoryID  CHECK ((TerritoryID%2)=0),-- constraint FK_StateProvince_SalesTerritory_TerritoryID references Sales.SalesTerritory(TerritoryID),
	ModifiedDate DATETIME NOT NULL,
	AddressType NVARCHAR(50),
	TaxRate SMALLMONEY, 
	CurrencyCode NCHAR(3),
	AverageRate MONEY
)

select * from #StateProvince

--c) заполните временную таблицу данными из dbo.StateProvince. 
--Поле CurrencyCode заполните данными из таблицы Sales.Currency. 

INSERT INTO #StateProvince(
	StateProvinceID,StateProvinceCode,IsOnlyStateProvinceFlag,
	Name,CountryRegionCode,ModifiedDate,TerritoryID,
	AddressType, CurrencyCode) 
select distinct temp.StateProvinceID,temp.StateProvinceCode,
	temp.IsOnlyStateProvinceFlag,temp.Name,
	temp.CountryRegionCode,temp.ModifiedDate,
	temp.TerritoryID,temp.AddressType, Sales.Currency.CurrencyCode
from dbo.StateProvince AS temp
JOIN Person.CountryRegion ON Person.CountryRegion.CountryRegionCode = temp.CountryRegionCode
JOIN Sales.CountryRegionCurrency ON Sales.CountryRegionCurrency.CountryRegionCode = Person.CountryRegion.CountryRegionCode
JOIN Sales.Currency ON Sales.CountryRegionCurrency.CurrencyCode=Sales.Currency.CurrencyCode

select * from #StateProvince
--Поле TaxRate заполните значениями налоговой ставки к розничным сделкам (TaxType = 1) из таблицы Sales.SalesTaxRate.
--Если для какого-то штата налоговая ставка не найдена, заполните TaxRate нулем. 

UPDATE #StateProvince
SET TaxRate = Temp2.temp
FROM
(SELECT StateProvinceID,IIF(Sales.SalesTaxRate.TaxType = 1, Sales.SalesTaxRate.TaxRate,0) AS temp
FROM Sales.SalesTaxRate) AS Temp2
WHERE #StateProvince.StateProvinceID = Temp2.StateProvinceID

select * from #StateProvince
--Определите максимальное значение курса обменавалюты (AverageRate) в таблице Sales.CurrencyRate для каждой валюты 
--(указанной в поле ToCurrencyCode) и заполните этими значениями поле AverageRate.
--Определение максимального курса для каждой валюты осуществите в Common Table Expression (CTE).

WITH MaxAverageRateCTE (MaxAverageRate, ToCurrencyCode)
AS
(
    SELECT MAX(AverageRate) AS MaxAverageRate,ToCurrencyCode
    FROM Sales.CurrencyRate
	GROUP BY ToCurrencyCode
)
UPDATE #StateProvince
SET AverageRate = temp2.MaxAverageRate
FROM #StateProvince as temp1
JOIN MaxAverageRateCTE as temp2 ON temp1.CurrencyCode = temp2.ToCurrencyCode collate Cyrillic_General_CI_AS;

select * from #StateProvince
--https://learn.microsoft.com/ru-RU/sql/t-sql/queries/with-common-table-expression-transact-sql?view=azuresqldb-mi-current 
--https://stackoverflow.com/questions/50267340/cannot-resolve-the-collation-conflict-between-cyrillic-general-ci-as-and-sql


--d) удалите из таблицы dbo.StateProvince строки, где CountryRegionCode=’CA’
DELETE dbo.StateProvince
WHERE CountryRegionCode='CA';

select * from dbo.StateProvince
--e) напишите Merge выражение, использующее dbo.StateProvince как target, а временную таблицу как source. 
--Для связи target и source используйте StateProvinceID. 
--Обновите поля TaxRate, CurrencyCode и AverageRate, 
--если запись присутствует в source и target. 
--Если строка присутствует во временной таблице, но не существует в target,
--добавьте строку в dbo.StateProvince. 
--Если в dbo.StateProvince присутствует такая строка, которой не существует во временной таблице, удалите строку из dbo.StateProvince.
MERGE dbo.StateProvince AS Target
USING #StateProvince AS Source
    ON (target.StateProvinceID = Source.StateProvinceID)
WHEN MATCHED 
    THEN UPDATE 
        SET 
		TaxRate = Source.TaxRate,
		CurrencyCode = Source.CurrencyCode,
		AverageRate = Source.AverageRate
WHEN NOT MATCHED 
    THEN INSERT 
        VALUES (Source.StateProvinceID,Source.StateProvinceCode,Source.CountryRegionCode,
		Source.IsOnlyStateProvinceFlag,Source.Name,Source.TerritoryID,Source.ModifiedDate,
		Source.AddressType, Source.CurrencyCode,Source.AverageRate,Source.TaxRate)
WHEN NOT MATCHED BY SOURCE
    THEN 
        DELETE
OUTPUT deleted.*, $action, inserted.*;

select * from dbo.StateProvince;
select * from #StateProvince;


USE AdventureWorks2012;
GO

--a) Создайте таблицу Sales.SpecialOfferHst, которая будет хранить информацию об изменениях втаблице Sales.SpecialOffer.
--Обязательные поля, которые должны присутствовать в таблице: ID — первичный ключIDENTITY(1,1); 
--Action — совершенное действие (insert, update или delete); ModifiedDate — дата ивремя, когда была совершена операция; 
--SourceID — первичный ключ исходной таблицы; UserName— имя пользователя, совершившего операцию. Создайте другие поля, если считаете их нужными.
drop table Sales.SpecialOfferHst;
CREATE TABLE Sales.SpecialOfferHst
(
	ID INT PRIMARY KEY IDENTITY(1,1),
	LogAction VARCHAR(100) NOT NULL CHECK (LogAction IN ('Insert', 'Update', 'Delete')),
	LogDate DATETIME NOT NULL DEFAULT GETDATE(),
	SourceId INT NOT NULL,
	UserName VARCHAR(20)
)
--b) Создайте три AFTER триггера для трех операций INSERT, UPDATE, DELETE для таблицыSales.SpecialOffer. 
--Каждый триггер должен заполнять таблицу Sales.SpecialOfferHst с указанием типаоперации в поле Action.
GO
CREATE TRIGGER Sales_SpecialOffer_Insert2
ON Sales.SpecialOffer
AFTER INSERT AS 
BEGIN
INSERT INTO Sales.SpecialOfferHst(LogAction,LogDate,SourceId,Username)
SELECT 'Insert',ModifiedDate, SpecialOfferID,USER_NAME()  FROM inserted
END
GO

CREATE TRIGGER Sales_SpecialOfFer_Updatee2
ON Sales.SpecialOffer
AFTER UPDATE AS 
BEGIN
INSERT INTO Sales.SpecialOfferHst(LogAction,LogDate,SourceId,Username)
SELECT 'Update',ModifiedDate, SpecialOfferID,USER_NAME()  FROM deleted
END
GO

CREATE TRIGGER Sales_SpecialOfer_Deletedd2
ON Sales.SpecialOffer
AFTER DELETE AS 
BEGIN
INSERT INTO Sales.SpecialOfferHst(LogAction,LogDate,SourceId,Username)
SELECT 'Delete',ModifiedDate, SpecialOfferID,USER_NAME()  FROM deleted
END
GO
--c) Создайте представление VIEW, отображающее все поля таблицы Sales.SpecialOffer. 
--Сделайте невозможным просмотр исходного кода представления.
drop view Sales.SpecialOfferView;
CREATE VIEW Sales.SpecialOfferView
WITH ENCRYPTION AS SELECT * FROM Sales.SpecialOffer
go

--d) Вставьте новую строку в Sales.SpecialOffer через представление. 
--Обновите вставленную строку.Удалите вставленную строку. 
--Убедитесь, что все три операции отображены в Sales.SpecialOfferHst.
use AdventureWorks2012;
INSERT INTO Sales.SpecialOfferView( Description,DiscountPct,Type,Category,StartDate,
	EndDate,MinQty,MaxQty,rowguid,ModifiedDate)
VALUES ('Volume Discount 25 to 40',0.11239,'Volume Discount','Reseller',GETDATE(),
	GETDATE(),12,40,NEWID(),GETDATE());
	
UPDATE Sales.SpecialOfferView
SET DiscountPct=0.198
WHERE SpecialOfferID=16;
SELECT * FROM Sales.SpecialOffer

DELETE FROM Sales.SpecialOfferView
WHERE SpecialOfferID=23;

SELECT * FROM Sales.SpecialOfferHst;
select * from sales.SpecialOffer
