
/*
Projected Revenue HBF line chart1 #1B - budget (projected)
*/
DECLARE @RevenueYear INT = 2016

 SELECT 
     SUM(t1.amount) as ProjectedAmount
	 -- , t3.[ActualDate]
	 , BudgetMonth
	 , BudgetYear
  FROM [Analytics].[DW].[FactBudgetRevenue] t1
   LEFT JOIN [Analytics].[DW].[DimFinancialCategory] t2
   ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
   	INNER JOIN dw.DimEntity t4
	ON t1.EntityID = t4.EntityID
	AND t1.TenantID = t4.TenantID
	
   WHERE  

   BudgetYear = @RevenueYear -- year(getdate())
   	AND t4.Code = 'HBF'
   AND t2.fundcode = '025' 
   AND t2.TenantID = 3
	GROUP BY BudgetMonth, BudgetYear

