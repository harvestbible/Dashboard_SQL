USE analytics

DECLARE @BudgetYear int = 2016
DECLARE @BudgetMonth int = 5

SELECT  t3.[CalendarMonth] as BudgetMonth, t3.[CalendarYear] as BudgetYear
, SUM(t1.amount) as Expense --, t2.GLCode 
	 
FROM [Analytics].[DW].[FactExpense] t1
INNER JOIN [Analytics].[DW].[DimFinancialCategory] t2
ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
INNER JOIN [Analytics].DW.DimDate T3
ON t1.DateID = t3.DateID
INNER JOIN DW.DimEntity T4
ON t1.EntityID = t4.EntityID
   
WHERE  
t3.[CalendarYear] = @BudgetYear --(getdate())
AND t3.[CalendarMonth] <= @BudgetMonth  --month(getdate())  --3
--AND t3.[CalendarMonth] = @BudgetMonth  --month(getdate())  --3


AND t4.Code = 'HBC'
AND t2.fundcode = '025'  
AND t2.GLCode NOT IN ('30010', '30058', '30075', '30046', '90139', '90145', '90260')
AND t2.DepartmentCode <> '9120'
AND t2.TenantID = 3
GROUP BY  t3.[CalendarYear], t3.[CalendarMonth] --, t2.GLCode 
--order by t3.[CalendarYear], t3.[CalendarMonth] --, t2.GLCode 

UNION All
SELECT t3.[CalendarMonth] as BudgetMonth, t3.[CalendarYear] as BudgetYear
  , SUM(t1.amount) as Expense --, t2.GLCode 
FROM [DW].[FactFinancialOther] T1
INNER JOIN [Analytics].[DW].[DimFinancialCategory] t2
ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
INNER JOIN [Analytics].DW.DimDate T3
ON t1.DateID = t3.DateID

WHERE  t3.[CalendarYear] = @BudgetYear 
AND t3.[CalendarMonth] <= @BudgetMonth 
and t2.entitycode = 'HBC'
AND t2.fundcode = '025'  
--AND t2.GLCode NOT IN ('30010', '30058', '30075', '30046')
AND t2.GLCode  IN ('24225', '24230', '24233',  '24235', '24272', '15026','15146','15151')

--AND t2.DepartmentCode <> '9120'
AND t2.TenantID = 3
GROUP BY  t3.[CalendarMonth], t3.[CalendarYear] --, t2.GLCode 

UNION All

SELECT t3.[CalendarMonth] as BudgetMonth, t3.[CalendarYear] as BudgetYear
  , -1 * SUM(t1.amount) as Expense
FROM [DW].[FactRevenue] T1
INNER JOIN [Analytics].[DW].[DimFinancialCategory] t2
ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
INNER JOIN [Analytics].DW.DimDate T3
ON t1.DateID = t3.DateID

WHERE  t3.[CalendarYear] = @BudgetYear 
AND t3.[CalendarMonth] <= @BudgetMonth 
and t2.entitycode = 'HBC'
AND t2.fundcode = '025'  
--AND t2.GLCode  IN ('30010', '30058', '30075', '30046')

 AND t2.GLCode  IN ('30030','30042','31025','32010','32012','35115','35004', '37010','37020','37021','37025')
--AND t2.DepartmentCode = '9120'
AND t2.TenantID = 3
GROUP BY  t3.[CalendarMonth], t3.[CalendarYear]
