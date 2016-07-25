
DECLARE @ReportYear INT = 2016
DECLARE @ReportMonth TINYINT = 2


SELECT
 
	--SUM(t1.amount) as CashReserve
	t1.amount, t3.[CalendarYear], t3.[CalendarMonth]
	FROM [Analytics].[DW].[FactFinancialOther] t1
	INNER JOIN [Analytics].[DW].[DimFinancialCategory] t2
	ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
	JOIN [Analytics].DW.DimDate T3
	ON t1.DateID = t3.DateID

	WHERE --t3.[CalendarYear] = @ReportYear 
	--AND t3.[CalendarMonth] = @ReportMonth 
	 fundcode = '053'
	AND t2.GLCode IN 

	   ( 
			10015,10016,10025,10034,10035,10041,10042,10045,10060,10061,10063,10067,10069,10072,10075,10076,
			10077,10091,10093,20010,20016,20018,20020,22025,23018,10017,10050,10052
		)

