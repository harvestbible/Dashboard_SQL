/*
CASH table:
	General, Reserve, Mortgage Sinking Fund, Systems Project, Camp Reserve, HCA Endowment 
	(all except Chicago West as it is a manual form
*/

DECLARE @ReportYear INT = 2016
DECLARE @ReportMonth TINYINT = 2

; WITH CashBalance AS (
	SELECT 
	SUM(t1.amount) as TotalCashBalance,
	-- fundcode ,
	--, GLCode  --  'General' as FundName
	--t1.amount, t1.DateID, t3.[ActualDate] 
		
		(SELECT 
			SUM(t1.amount) as Total
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
			AND fc.FundCode = '025'
			AND GLCode IN (20010,20020,21055,22025,22027,22040)  --these are liability GLCodes from the Banance Sheet
			) as Liabilities

	FROM [Analytics].[DW].[FactFinancialOther] t1
	INNER JOIN [Analytics].[DW].[DimFinancialCategory] fc
	ON t1.[FinancialCategoryID] = fc.[FinancialCategoryID]
	JOIN [Analytics].DW.DimDate T3
	ON t1.DateID = t3.DateID
	
	WHERE t3.[ActualDate] < convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear))
	--AND t1.DateID >= 20150101
	AND fc.EntityCode  = 'WITW'
	--AND fc.FundCode IN ('025')
	AND fc.FundCode IN ('025',  '086')
	--AND 
	--(
	--	(fc.FundCode = '025' AND GLCode IN (10016,10017,10025, 10050,10052,10060, 12017))
	--	OR
	--	(fc.FundCode = '086' AND GLCode IN (10016,10017,10025, 10050,10052,10060, 12017) )	
	--)
	
	--GROUP BY 
	--fundcode --, GLCode
	)

	select TotalCashBalance,  Liabilities, '-1087580' as EightWeekReserve from CashBalance
