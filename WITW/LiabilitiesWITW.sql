/*
CASH table:
	General, Reserve, Mortgage Sinking Fund, Systems Project, Camp Reserve, HCA Endowment 
	(all except Chicago West as it is a manual form
*/

DECLARE @ReportYear INT = 2016
DECLARE @ReportMonth TINYINT = 2

--SELECT convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear))
		
SELECT 
	SUM(t1.amount) as Total  --, '-1087580' as EightWeekReserve, '-528572' as Liabilities
	--, fundcode 
	--, GLCode  --  'General' as FundName
	--t1.amount, t1.DateID, t3.[ActualDate] 
	FROM [Analytics].[DW].[FactFinancialOther] t1
	INNER JOIN [Analytics].[DW].[DimFinancialCategory] fc
	ON t1.[FinancialCategoryID] = fc.[FinancialCategoryID]
	JOIN [Analytics].DW.DimDate T3
	ON t1.DateID = t3.DateID
	
	WHERE t3.[ActualDate] < convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear))
	--AND t1.DateID >= 20150101
	AND fc.EntityCode  = 'WITW'
	--AND fc.FundCode in ('084', '088')
	AND fc.FundCode  ='025'
	--AND GLCode IN (20010,20020,21055,22025,22027,22040)  --these are liability GLCodes from the Banance Sheet

	--GROUP BY 
	--fundcode, GLCode
