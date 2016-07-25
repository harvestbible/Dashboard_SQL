
USE Analytics
/*
Projected expenses for HBCG line chart 
*/

DECLARE @ReportYear INT = 2016
DECLARE @ReportMonth TINYINT = 12

DECLARE @NumSun TINYINT,
@WeeklyBudgetAmount money = 460000,
@BeginningDate DATETIME, @EndingDate DATETIME

SELECT @BeginningDate = '1-1-2016', @EndingDate = '12-31-2016'

-----------------------------------------------------
--Calculate HBC Budget Expense 
-----------------------------------------------------
;WITH dates (date)
AS
(
SELECT @BeginningDate
UNION all
SELECT dateadd(d,1,date)
FROM dates
WHERE date < @EndingDate
)

SELECT  month(date) as BudgetMonth
, year(date) as BudgetYear
--, count(1) as NumSundaysInMonth
,  count(1) * @WeeklyBudgetAmount as Amount
into #t1
from dates d1 where datename(dw, date) = 'sunday'

group by year(date), month(date)
option (maxrecursion 1000)

-----------------------------------------------------
--Calculate 'HCA', 'WITW', 'HBF Budget Expense 
-----------------------------------------------------
;WITH Expenses AS (
	SELECT 
	BudgetMonth, BudgetYear, SUM(t1.amount) as Amount
	FROM [Analytics].[DW].[FactBudgetExpense] t1
	INNER JOIN [Analytics].[DW].[DimFinancialCategory] t2
	ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
	INNER JOIN dw.DimEntity t4
	ON t1.EntityID = t4.EntityID
	AND t1.TenantID = t4.TenantID
	WHERE   t2.TenantID = 3
	and Budgetyear = @ReportYear
	AND
	(
		(t4.Code = 'WITW' AND t2.fundcode IN  ('025', '086')) 
		OR
		(t4.Code IN ('HCA',  'HBF') AND t2.fundcode = '025')
    )

	 GROUP BY BudgetMonth, BudgetYear --, t4.Code
	 )
	 --	 select * from expenses


-----------------------------------------------------
--Combine and Calculate all projected expenses
-----------------------------------------------------
	 ,  ExpensesAll AS
	 (
	SELECT 
	BudgetMonth, BudgetYear,  Amount
	FROM Expenses
	 UNION
	 SELECT 
	 BudgetMonth, BudgetYear,   Amount
	 FROM #t1
	 )

	--select * from ExpensesAll

--	;WITH ExpensesAllSummary AS 
	,  ExpensesAllSummary AS
	 (
	SELECT BudgetMonth, BudgetYear,  SUM(Amount) as Amount
	,  ROW_NUMBER() OVER(ORDER BY [BudgetYear] , [BudgetMonth]) AS RowNum
	FROM ExpensesAll
	GROUP BY BudgetMonth, BudgetYear
	 )

	 --=select * from ExpensesAllSummary

	 select [BudgetMonth], [BudgetYear],  Amount
		,	(SELECT SUM(t2.Amount) from ExpensesAllSummary t2 WHERE t2.RowNum <= t1.RowNum ) AS CumulativeSum
	 FROM ExpensesAllSummary t1
	 order by BudgetMonth, BudgetYear

	 drop table #t1