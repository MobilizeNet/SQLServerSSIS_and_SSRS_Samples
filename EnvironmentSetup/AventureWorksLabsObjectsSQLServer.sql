USE [AdventureWorks2019]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/****** Object:  View [HumanResources].[vPowerBIEmployee] ******/
CREATE VIEW [HumanResources].[vPowerBIEmployee] 
AS 
SELECT
  P.[FirstName] AS 'FirstName'
  , P.[LastName] AS 'LastName'
  , E.[JobTitle] AS 'JobTitle'
  , E.[BirthDate] AS 'BirthDate'
  , E.[Gender] AS 'Gender'
  , D.Name AS 'Department'
  , D.GroupName AS 'Group Department'
FROM 
  [HumanResources].[Employee] E 
  INNER JOIN [Person].[Person] P 
    ON P.BusinessEntityID = E.BusinessEntityID
  INNER JOIN [HumanResources].[EmployeeDepartmentHistory] DH 
    ON DH.BusinessEntityID = P.BusinessEntityID
  INNER JOIN [HumanResources].Department D 
    ON D.DepartmentID = DH.DepartmentID
;  
GO

/****** Object:  View [HumanResources].[vPowerBISales] ******/
CREATE VIEW [HumanResources].[vPowerBISales] 
AS 
SELECT 
  SOH.[SalesOrderID]  AS 'SalesOrderID'
  , SOH.[CustomerID] AS 'CustomerID'
  , SOH.[SalesPersonID] AS 'SalesPersonID'
  , SOH.[TerritoryID] AS 'TerritoryID'
  , SOH.[SubTotal] AS 'SubTotal'
  , SOH.[TaxAmt] AS 'TaxAmt'
  , SOH.[Freight] AS 'Freight'
  , SOH.[TotalDue] AS 'TotalDue'
  , SOD.[OrderQty] AS 'OrderQty' 
  , SOD.[UnitPrice] AS 'UnitPrice'
  , P.[Name] AS 'Product Name'
  , S.[Group] AS 'Territory Group Name'
  , S.[Name]	 AS 'Territory Name'
  , PSC.Name AS 'Product Sub Category Name'
  , PC.Name AS 'Product Category Name'	  
FROM 
  [Sales].[SalesOrderHeader] SOH
  INNER JOIN [Sales].[SalesOrderDetail] SOD 
    ON SOD.SalesOrderID = SOH.SalesOrderID
  INNER JOIN [Production].[Product] P 
    ON P.ProductID = SOD.ProductID
  INNER JOIN [Production].[ProductSubcategory] PSC 
    ON PSC.ProductSubcategoryID = P.ProductSubcategoryID
  INNER JOIN [Production].[ProductCategory] PC 
    ON PC.ProductCategoryID = PSC.ProductCategoryID
  INNER JOIN [Sales].[Customer] C 
    ON C.CustomerID = SOH.CustomerID
  INNER JOIN [Sales].[SalesTerritory] S 
    ON S.TerritoryID = SOH.TerritoryID
;
GO

/****** Object:  View [HumanResources].[vPowerBIEmployee] ******/
CREATE   PROCEDURE [HumanResources].[SP_PowerBIEmployee]
AS
BEGIN
  SELECT
    P.[FirstName] AS 'FirstName'
    , P.[LastName] AS 'LastName'
    , E.[JobTitle] AS 'JobTitle'
    , E.[BirthDate] AS 'BirthDate'
    , E.[Gender] AS 'Gender'
    , D.Name AS 'Department'
    , D.GroupName AS 'Group Department'
  FROM 
    [HumanResources].[Employee] E 
    INNER JOIN [Person].[Person] P 
      ON P.BusinessEntityID = E.BusinessEntityID
    INNER JOIN [HumanResources].[EmployeeDepartmentHistory] DH 
      ON DH.BusinessEntityID = P.BusinessEntityID
    INNER JOIN [HumanResources].Department D 
      ON D.DepartmentID = DH.DepartmentID
  RETURN
END
;
GO