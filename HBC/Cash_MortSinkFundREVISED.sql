/*
Mortgag Sinking fund - total ALL data in the current reporting month and prior
*/


DECLARE @ReportYear INT = 2016
DECLARE @ReportMonth TINYINT = 2

--SELECT convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear))

SELECT
 
	SUM(t1.amount) as MtgSinkFundTotal
	--t1.amount, t1.DateID, t3.[ActualDate] 
	FROM [Analytics].[DW].[FactFinancialOther] t1
	INNER JOIN [Analytics].[DW].[DimFinancialCategory] t2
	ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
	JOIN [Analytics].DW.DimDate T3
	ON t1.DateID = t3.DateID
	
	WHERE t3.[ActualDate] < convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear))
	
	AND 
	--t3.[CalendarMonth] = @ReportMonth 
	--AND 
	fundcode = '053'
	AND t2.GLCode IN 

	   ( 
			10015,10016,10025,10034,10035,10041,10042,10045,10060,10061,10063,10067,10069,10072,10075,10076,
			10077,10091,10093,20010,20016,20018,20020,22025,23018,10017,10050,10052
		)

		--order by t1.dateid