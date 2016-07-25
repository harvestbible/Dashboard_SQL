
USE Analytics
/*
actual Expense for HBCG line chart 1
*/

DECLARE @ReportYear INT = 2016
DECLARE @ReportMonth TINYINT = 12

-----------------------------------------------------
--Calculate Actual Expenses
-----------------------------------------------------
; WITH Expenses AS (
	SELECT 
	 t3.[CalendarMonth] , t3.[CalendarYear] , SUM(t1.amount) as Amount --, t4.Code as entitycode
 -- , ROW_NUMBER() OVER(ORDER BY t3.[CalendarYear] , t3.[CalendarMonth] ) AS RowNum
	FROM [Analytics].[DW].[FactExpense] t1
	INNER JOIN [Analytics].[DW].[DimFinancialCategory] t2
	ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
	JOIN [Analytics].DW.DimDate T3
	ON t1.DateID = t3.DateID
	INNER JOIN dw.DimEntity t4
	ON t1.EntityID = t4.EntityID
	AND t1.TenantID = t4.TenantID
	WHERE   t2.TenantID = 3
	AND t3.[CalendarYear] = @ReportYear
	AND
		(
			(t4.Code IN ('HCA', 'HBF') AND t2.fundcode = '025') 
			OR
			(t4.Code = 'HBC' AND t2.fundcode = '025' AND t2.GLCode NOT IN ('30010', '30058', '30075', '30046', '90139', '90145', '90260') AND t2.DepartmentCode <> '9120')
			OR
			(t4.Code  = 'WITW' 
				AND
					(fundcode = '025'  --for WITW only, department is loaded into "staff code"
					AND [StaffCode]  IN ( '5055', '5158', '5160', '5163', '6207' , '6217', '5162', '7217', '5178', '5180', '7219'
					, '4106', '4056', '4036', '5038', '4016', '5058', '4096', '5078', '5098', '5138' ))
				OR
				(fundcode = '086')
				OR
				(fundcode = '025' AND [StaffCode] = '5018' AND  GLCode = '49099')
			)
		--
		)
		GROUP BY  t3.[CalendarYear], t3.[CalendarMonth]
		)
	
--select * from expenses

-----------------------------------------------------
-- Actual HBF and WITW and HBC Additional Expenses
-----------------------------------------------------
, HBFXtaexpenses as (
	SELECT t3.[CalendarMonth], t3.[CalendarYear]
	  , SUM(t1.amount) as amount --, t2.entitycode
	FROM [DW].[FactFinancialOther] T1
	INNER JOIN [Analytics].[DW].[DimFinancialCategory] t2
	ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
	INNER JOIN [Analytics].DW.DimDate T3
	ON t1.DateID = t3.DateID
	WHERE  t3.[CalendarYear] = @ReportYear 
	AND t3.[CalendarMonth] <= @ReportMonth 
	AND (
		 (GLCode = '15141' and t2.entitycode = 'HBF')
		 OR
		 (GLCode IN ('15151', '15146' ) and t2.entitycode = 'WITW' AND fundcode = '086')
		 OR
		 (GLCode IN ('24225', '24230', '24233',  '24235', '24272', '15026','15146','15151') and t2.entitycode = 'HBC' AND fundcode = '025')
	 )
	GROUP BY t3.[CalendarYear], t3.[CalendarMonth]--, t2.entitycode
)


--select * from HBFXtaexpenses

	, HBCRev as (
		SELECT t3.[CalendarMonth] , t3.[CalendarYear] 
		  , -1 * SUM(t1.amount) as Amount
		FROM [DW].[FactRevenue] T1
		INNER JOIN [Analytics].[DW].[DimFinancialCategory] t2
		ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
		INNER JOIN [Analytics].DW.DimDate T3
		ON t1.DateID = t3.DateID

		WHERE  t3.[CalendarYear] = @ReportYear 
		AND t3.[CalendarMonth] <= @ReportMonth 
		and t2.entitycode = 'HBC'
		AND t2.fundcode = '025'  
		--AND t2.GLCode  IN ('30010', '30058', '30075', '30046')

		 AND t2.GLCode  IN ('30030','30042','31025','32010','32012','35115','35004', '37010','37020','37021','37025')
		--AND t2.DepartmentCode = '9120'
		AND t2.TenantID = 3
		GROUP BY  t3.[CalendarYear], t3.[CalendarMonth]
	)

--	select * from HBCRev

,  ExpensesAll AS
	 (
	select [CalendarMonth], [CalendarYear], Amount from Expenses
	UNION ALL
	select [CalendarMonth], [CalendarYear],  Amount from HBFXtaexpenses
	UNION ALL
	select [CalendarMonth], [CalendarYear],  Amount from HBCRev
	)

--Select * from ExpensesAll 

,  ExpensesAllSummary AS
	 (
	SELECT [CalendarMonth], [CalendarYear],  SUM(Amount) as Amount --, entitycode
	,  ROW_NUMBER() OVER(ORDER BY [CalendarYear] , [CalendarMonth]) AS RowNum
	FROM ExpensesAll
	GROUP BY  [CalendarYear], [CalendarMonth] --, entitycode
	 )

	--select * from  ExpensesAllSummary

	-- select [CalendarMonth], [CalendarYear],  Amount from ExpensesAllSummary order by [CalendarMonth], [CalendarYear]

	 select [CalendarMonth], [CalendarYear],  Amount
		,	(SELECT SUM(t2.Amount) from ExpensesAllSummary t2 WHERE t2.RowNum <= t1.RowNum ) AS CumulativeSum
	 FROM ExpensesAllSummary t1
	 ORDER BY  [CalendarYear], [CalendarMonth]
