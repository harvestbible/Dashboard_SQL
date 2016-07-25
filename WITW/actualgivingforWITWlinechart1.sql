

/*
Actual Revenue for WITW #1A Line Graph: Broadcase Ministry FY16 YTD REVENUE VS. EXPENSE ($000's)
*/
	DECLARE @FiscalYear INT = 2015,
	@CalendarMonth varchar(2) = 2, 
	@CalendarYear varchar(4) = 2016
	
	;WITH witwRevenue AS
	(
	SELECT
	  t3.[FiscalYear]
	, t3.[FiscalMonth] 
	, t3.[CalendarYear] 
	, t3.[CalendarMonth] 
	, SUM(t1.amount) as Amount
	, ROW_NUMBER() OVER(ORDER BY t3.[FiscalYear] , t3.[FiscalMonth]) AS RowNum
	
	FROM [Analytics].[DW].[FactRevenue] t1
	LEFT JOIN [Analytics].[DW].[DimFinancialCategory] t2
	ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
	JOIN [Analytics].DW.DimDate T3
	ON t1.DateID = t3.DateID
	INNER JOIN dw.DimEntity t4
	ON t1.EntityID = t4.EntityID
	AND t1.TenantID = t4.TenantID
	
	WHERE 
	t3.[FiscalYear] = @FiscalYear --year(getdate())
	--AND t4.Code = 'witw'
	AND t2.EntityCode  = 'WITW'
	AND fundcode = '025'  
	and actualdate <  dateadd(month, +1, convert(date, @CalendarMonth + '/01/'+  @CalendarYear ))
	--AND t2.FundCode  IN ('084','088') 
	AND t2.[TenantID] = 3
	
	GROUP BY  t3.[FiscalYear] , t3.[FiscalMonth] 
	 , t3.[CalendarYear], t3.[CalendarMonth]
	 --t3.[MinistryYear], t3.[MinistryMonth]
	)
	

	SELECT FiscalYear, FiscalMonth, [CalendarYear] 
	, [CalendarMonth],  Amount
	,	(SELECT SUM(tc.Amount) from witwRevenue tc WHERE tc.RowNum <= tr.RowNum ) AS CumulativeSum
	FROM witwRevenue tr
	ORDER BY tr.[FiscalYear] , tr.[FiscalMonth]

