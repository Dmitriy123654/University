CREATE DATABASE NewDatabase;
GO

USE NewDatabase;
GO

CREATE SCHEMA sales;
GO

CREATE TABLE sales.Orders ( OrderNum INT NULL);

USE master
GO
BACKUP DATABASE NewDatabase
TO DISK = N'D:\c#\MSSQL\AllBD\university\laba1\задание 1\SQL1.bak' 
WITH NOFORMAT, NOINIT,
NAME = N'NewDatabase_DbBackup', SKIP, NOREWIND, NOUNLOAD, STATS = 10;
GO

--DROP DATABASE NewDatabase;

RESTORE DATABASE NewDatabase
FROM DISK = N'D:\c#\MSSQL\AllBD\university\laba1\задание 1\AdventureWorks2012-Full Database Backup.bak' WITH  FILE = 1, NOUNLOAD, STATS = 5;
go

use AdventureWorks2012 EXEC sp_changedbowner 'sa'



--Вывести на экран сотрудников, которые родились 
--позже 1980 года (но не в 1980 год) и 
--были приняты на работу позже 1-ого апреля 2003 года.

USE AdventureWorks2012;
GO

SELECT BusinessEntityID,JobTitle,BirthDate,HireDate FROM HumanResources.Employee
WHERE BirthDate >= '1981' AND HireDate>'2003.04.01';

--Вывести на экран сумму часов отпуска и сумму больничных 
--часов у сотрудников. Назовите столбцы с результатами 
--‘SumVacationHours’ и ‘SumSickLeaveHours’ для отпусков и 
--больничных соответственно.

SELECT  SUM(VacationHours) as SumVacationHours, 
		SUM(SickLeaveHours) as SumSickLeaveHours 
FROM HumanResources.Employee

--Вывести на экран первых трех сотрудников, которых 
--раньше всех остальных приняли на работу.

SELECT TOP 3 BusinessEntityID,JobTitle,Gender,BirthDate,HireDate 
FROM HumanResources.Employee
ORDER BY HireDate;


USE AdventureWorks2012;
GO

--Вывести на экран среднее значение почасовой ставки
--для каждого сотрудника

SELECT e.BusinessEntityID,JobTitle, AVG(Rate)AS Rate 
FROM HumanResources.Employee as e
INNER JOIN HumanResources.EmployeePayHistory as eps 
	ON eps.BusinessEntityID=e.BusinessEntityID
group by e.BusinessEntityID,JobTitle;

--Вывести на экран историю почасовых ставок сотрудников 
--с информацией для отчета как показано в примере. 
--Если ставка меньше или равна 50 вывести ‘less or equal 50’;
--больше 50, но меньше или равна 100 – 
--вывести ‘more than 50 but less or equal 100’; 
--если ставка больше 100 вывести ‘more than 100’.

SELECT e.BusinessEntityID,JobTitle,Rate,(CASE
        WHEN Rate  <= 50 THEN 'less or equal 50'
        WHEN Rate  BETWEEN 50.0001 AND 100 THEN 'more than 50 but less or equal 100’'
        WHEN Rate  > 100 THEN 'more than 100'
        ELSE 'Magic'
    END) as RateReport FROM HumanResources.Employee as e
INNER JOIN HumanResources.EmployeePayHistory as eps ON eps.BusinessEntityID=e.BusinessEntityID



--Вычислить максимальную почасовую ставку работающих в 
--настоящий момент сотрудников в каждом отделе. 
--Вывести на экран названия отделов, в которых максимальная 
--почасовая ставка больше 60.
--Отсортировать результат по значению максимальной ставки.

SELECT d.Name, Max(Rate)AS Rate FROM HumanResources.Employee as e
INNER JOIN HumanResources.EmployeePayHistory as eps ON eps.BusinessEntityID=e.BusinessEntityID
JOIN HumanResources.EmployeeDepartmentHistory as edh ON edh.BusinessEntityID=e.BusinessEntityID
JOIN HumanResources.Department AS d ON d.DepartmentID=edh.DepartmentID
where edh.EndDate IS NULL 
group by d.Name
having MAX(rate) > 60
order by Rate;


USE AdventureWorks2012;
GO

--a)создайте таблицу dbo.StateProvince с такой же структурой 
--как Person.StateProvince, кроме поля uniqueidentifier, 
--не включая индексы, ограничения и триггеры;

CREATE TABLE StateProvince (
	StateProvinceID INT NOT NULL PRIMARY KEY,--constraint PK_StateProvince_StateProvinceID PRIMARY KEY
	StateProvinceCode NCHAR(3) NOT NULL,
	CountryRegionCode NVARCHAR(3) NOT NULL references Person.CountryRegion(CountryRegionCode),-- constraint FK_StateProvince_CountryRegion_CountryRegionCode references Person.CountryRegion(CountryRegionCode),
	IsOnlyStateProvinceFlag BIT NOT NULL,
	Name NVARCHAR(50) NOT NULL,
	TerritoryID INT NOT NULL references Sales.SalesTerritory(TerritoryID),-- constraint FK_StateProvince_SalesTerritory_TerritoryID references Sales.SalesTerritory(TerritoryID),
	ModifiedDate DATETIME NOT NULL
);

--для поиска Ключей и всех связей
--	SELECT f.name AS ForeignKey, OBJECT_NAME(f.parent_object_id) AS TableName,
--    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS ColumnName,
--    OBJECT_NAME (f.referenced_object_id) AS ReferenceTableName,
--    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS ReferenceColumnName
--FROM sys.foreign_keys AS f
--INNER JOIN sys.foreign_key_columns AS fc
--ON f.OBJECT_ID = fc.constraint_object_id

--b)используя инструкцию ALTER TABLE, 
--создайте для таблицы dbo.StateProvince составной первичный ключ из полей StateProvinceID и StateProvinceCode;

ALTER TABLE dbo.StateProvince
DROP PK__StatePro__9122A9717FB85B38;

ALTER TABLE dbo.StateProvince
ADD PRIMARY KEY (StateProvinceID,StateProvinceCode);


--c)используя инструкцию ALTER TABLE, 
--создайте для таблицы dbo.StateProvince ограничение для поля TerritoryID, 
--чтобы значение поля могло содержать только четные цифры;
ALTER TABLE dbo.StateProvince
ADD CONSTRAINT CK_TerritoryID  CHECK ((TerritoryID%2)=0);

--d)используя инструкцию ALTER TABLE, 
--создайте для таблицы dbo.StateProvince ограничение DEFAULT для поля TerritoryID, 
--задайте значение по умолчанию 2;

 ALTER TABLE dbo.StateProvince
ADD CONSTRAINT DF_TerritoryID   DEFAULT 2  FOR TerritoryID;

--e)заполните новую таблицу данными из Person.StateProvince. 
--Выберите для вставки только те адреса, которые имеют тип ‘Shipping’ в таблице Person.AddressType. 
--Поле TerritoryID заполните значениями по умолчанию;

USE AdventureWorks2012;



INSERT into dbo.StateProvince (dbo.StateProvince.StateProvinceID,dbo.StateProvince.StateProvinceCode,
	dbo.StateProvince.IsOnlyStateProvinceFlag,
	dbo.StateProvince.Name,dbo.StateProvince.CountryRegionCode,dbo.StateProvince.ModifiedDate) 
select distinct Person.StateProvince.StateProvinceID,Person.StateProvince.StateProvinceCode,
	Person.StateProvince.IsOnlyStateProvinceFlag,
	Person.StateProvince.Name,Person.StateProvince.CountryRegionCode,Person.StateProvince.ModifiedDate
	from Person.StateProvince
join Person.Address ON Person.StateProvince.StateProvinceID=Person.Address.StateProvinceID
join Person.BusinessEntityAddress ON Person.BusinessEntityAddress.AddressID=Person.Address.AddressID
join Person.AddressType ON  Person.BusinessEntityAddress.AddressTypeID = Person.AddressType.AddressTypeID and Person.AddressType.Name='Shipping';
go
--С помощью оконных функций для группы данных из полей
--StateProvinceID и StateProvinceCode 
--выберите только строки с максимальным AddressID. 
SELECT MAX(AddressID) FROM dbo.StateProvince
JOIN Person.Address ON Person.Address.StateProvinceID=dbo.StateProvince.StateProvinceID 
GROUP BY dbo.StateProvince.StateProvinceID,dbo.StateProvince.StateProvinceCode
ORDER BY MAX(AddressID)  DESC
--f)измените тип поля IsOnlyStateProvinceFlag на smallint, разрешите добавление null значений.

ALTER TABLE dbo.StateProvince
ALTER COLUMN IsOnlyStateProvinceFlag SMALLINT null;
