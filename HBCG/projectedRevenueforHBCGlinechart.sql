
USE Analytics
/*
Projected revenue for HBCG line chart 1
*/

DECLARE @ReportYear INT = 2016
DECLARE @ReportMonth TINYINT = 12

;WITH Revenue AS (
	SELECT 
	SUM(t1.amount) as Amount,  t1.[BudgetMonth], t1.[BudgetYear]  --, t4.Code
  , ROW_NUMBER() OVER(ORDER BY t1.[BudgetYear] , t1.[BudgetMonth]) AS RowNum

	FROM [Analytics].[DW].[FactBudgetRevenue] t1
	INNER JOIN [Analytics].[DW].[DimFinancialCategory] t2
	ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
	INNER JOIN dw.DimEntity t4
	ON t1.EntityID = t4.EntityID
	AND t1.TenantID = t4.TenantID

	WHERE   t2.TenantID = 3
	and Budgetyear = @ReportYear
	AND
		(
		(t4.Code IN ('HCA', 'HBF') AND t2.fundcode = '025') 
		OR
		(t4.Code = 'HBC' AND t2.fundcode = '025' AND t2.[GLCode] = '30010' AND t2.[DepartmentCode] = '3015')
		OR
		(t4.Code = 'WITW' AND t2.fundcode IN  ('025', '086')) 
		)

	 GROUP BY BudgetMonth, BudgetYear --, t4.Code
	
	 )

	 --select * from Revenue

	 select Amount,  tr.[BudgetMonth], tr.[BudgetYear] --,  tr.[code] 
	 , (SELECT SUM(tc.Amount) from Revenue tc WHERE tc.RowNum <= tr.RowNum ) AS CumulativeSum
	 FROM Revenue tr 
	 ORDER BY  tr.[BudgetMonth], tr.[BudgetYear]  