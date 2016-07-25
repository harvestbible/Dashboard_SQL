
/*
projected expense for HBF linechart2
*/

DECLARE @Year INT = 2016
DECLARE @lMonth TINYINT = 2

 SELECT 
     SUM(t1.amount) as ProjectedAmount
	 -- , t3.[ActualDate]
	 , BudgetMonth
	 , BudgetYear
  FROM [Analytics].[DW].[FactBudgetExpense] t1
   LEFT JOIN [Analytics].[DW].[DimFinancialCategory] t2
   ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
   	INNER JOIN dw.DimEntity t4
	ON t1.EntityID = t4.EntityID
	AND t1.TenantID = t4.TenantID
	INNER JOIN (
		SELECT DISTINCT 
			CalendarMonth, CalendarYear, CalendarMonthAbbreviation
			
		FROM DW.DimDate
		WHERE
			CalendarDayOfMonth = 1
			AND CalendarYear = @Year
			 
			 ) DimDate
		ON	t1.BudgetMonth = DimDate.CalendarMonth
		AND t1.BudgetYear = DimDate.CalendarYear


   WHERE  t4.Code = 'HBF'
   AND t2.fundcode = '025'  
   AND t2.TenantID = 3
   GROUP BY BudgetYear, BudgetMonth
    ORDER BY BudgetYear, BudgetMonth

