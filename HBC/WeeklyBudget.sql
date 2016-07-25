

/*
Actual Giving vs Projection for all campuses - budget (projected)
*/

 SELECT 
     SUM(t1.amount) / 52 as ProjectedAmount
	 , BudgetYear
  FROM [Analytics].[DW].[FactBudgetRevenue] t1
   LEFT JOIN [Analytics].[DW].[DimFinancialCategory] t2
   ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
   WHERE  
   BudgetYear = '2016'
   AND [GLCode] = '30010'
   AND [DepartmentCode] = '3015'
    AND fundcode = '025'  --I added, this was not in the spec
	--  and (fundcode = '025' or  fundcode = '315') --I added, this was not in the spec
	GROUP BY BudgetYear
	
 

