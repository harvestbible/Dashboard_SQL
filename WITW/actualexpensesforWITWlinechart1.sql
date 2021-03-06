USE [Analytics]

/*
Actual expense for WITW #1A Line Graph: Broadcase Ministry FY16 YTD REVENUE VS. EXPENSE ($000's)
*/
	DECLARE @FiscalYear INT = 2016,
	@CalendarMonth varchar(2) = 5, 
	@CalendarYear varchar(4) = 2016
	
	--select   dateadd(month, +1, convert(date, @CalendarMonth + '/01/'+  @CalendarYear ))

	;WITH witwExpense AS
	(
	SELECT
	  t3.[FiscalYear]
	, t3.[FiscalMonth] 
	, t3.[CalendarYear] 
	, t3.[CalendarMonth] 
	, SUM(t1.amount) as Amount
	--, [StaffCode]
	--, ROW_NUMBER() OVER(ORDER BY t3.[FiscalYear] , t3.[FiscalMonth]) AS RowNum

	FROM [Analytics].[DW].[FactExpense] t1
	LEFT JOIN [Analytics].[DW].[DimFinancialCategory] t2
	ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
	JOIN [Analytics].DW.DimDate T3
	ON t1.DateID = t3.DateID
	INNER JOIN dw.DimEntity t4
	ON t1.EntityID = t4.EntityID
	AND t1.TenantID = t4.TenantID
	
	WHERE 
	t3.[FiscalYear] = @FiscalYear --year(getdate())
	AND t2.EntityCode  = 'WITW'
	
	AND
	(
		(fundcode = '025'  --for WITW only, department is loaded into "staff code"
		AND [StaffCode]  IN ( '5055', '5158', '5160', '5163', '6207' , '6217', '5162', '7217', '5178', '5180', '7219'
		, '4106', '4056', '4036', '5038', '4016', '5058', '4096', '5078', '5098', '5138' ))
		OR
		(fundcode = '086')
	)
	

	GROUP BY  t3.[FiscalYear] , t3.[FiscalMonth] 
	 , t3.[CalendarYear], t3.[CalendarMonth] --, [StaffCode] --, [DepartmentCode]
	 --t3.[MinistryYear], t3.[MinistryMonth]
	)

--select * from witwexpense


	, WITWexpensesother as (
		SELECT     t3.[FiscalYear]
	, t3.[FiscalMonth] 
	, t3.[CalendarYear] 
	, t3.[CalendarMonth] 
		, SUM(t1.amount) as Amount
		FROM [DW].[FactFinancialOther] T1
		INNER JOIN [Analytics].[DW].[DimFinancialCategory] t2
		ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
		INNER JOIN [Analytics].DW.DimDate T3
		ON t1.DateID = t3.DateID
		WHERE  t3.[FiscalYear] = @FiscalYear 
		AND fundcode = '086'
		AND GLCode in ('15151', '15146' )
		and t2.entitycode = 'WITW'
		
	GROUP BY  t3.[FiscalYear] , t3.[FiscalMonth] 
	 , t3.[CalendarYear], t3.[CalendarMonth] 
		)

	--select * from WITWexpensesother

	,  ExpensesAll AS
	 (
	select  [FiscalYear], [FiscalMonth], [CalendarYear], [CalendarMonth], Amount from witwexpense
	UNION ALL
	select [FiscalYear], [FiscalMonth], [CalendarYear], [CalendarMonth], Amount from WITWexpensesother
	)

--Select * from ExpensesAll

,  ExpensesAllSummary AS
	 (
	SELECT  [FiscalYear], [FiscalMonth], [CalendarYear], [CalendarMonth], SUM(Amount) as Amount
	,  ROW_NUMBER() OVER(ORDER BY [FiscalYear], [FiscalMonth], [CalendarYear], [CalendarMonth]) AS RowNum
	FROM ExpensesAll
	GROUP BY   [FiscalYear], [FiscalMonth], [CalendarYear], [CalendarMonth]
	 )
	
	--Select * from ExpensesAllSummary

	-------------------original
	SELECT FiscalYear, FiscalMonth, [CalendarYear] 
	, [CalendarMonth],  Amount --, [StaffCode]
	,	(SELECT SUM(tc.Amount) from ExpensesAllSummary tc WHERE tc.RowNum <= tr.RowNum ) AS CumulativeSum
	FROM ExpensesAllSummary tr
	ORDER BY tr.[FiscalYear] , tr.[FiscalMonth]

