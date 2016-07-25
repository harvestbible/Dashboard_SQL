
/*
Actual Giving vs Projection for all campuses item #1B - budget (projected)
*/

 SELECT 
     SUM(t1.amount) as ProjectedAmount, [EntityCode]
	 -- , t3.[ActualDate]
	 , BudgetMonth
	 , BudgetYear
  FROM [Analytics].[DW].[FactBudgetRevenue] t1
   LEFT JOIN [Analytics].[DW].[DimFinancialCategory] t2
   ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
   WHERE  

   BudgetYear =  year(getdate())

   AND t2.[GLCode] = '30010'
   AND t2.[DepartmentCode] = '3015'
   AND t2.fundcode = '025'  --I added, this was not in the spec
   AND t2.TenantID = 3
	GROUP BY BudgetMonth, BudgetYear, [EntityCode]

