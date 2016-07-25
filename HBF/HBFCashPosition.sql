/*
CASH table:
	General, Reserve, Mortgage Sinking Fund, Systems Project, Camp Reserve, HCA Endowment 
	(all except Chicago West as it is a manual form
*/

DECLARE @ReportYear INT = 2016
DECLARE @ReportMonth TINYINT = 2


	SELECT 
	SUM(t1.amount) as TotalCashBalance , fundcode, FundName
	--, GLCode  --  'General' as FundName
	
	FROM [Analytics].[DW].[FactFinancialOther] t1
	INNER JOIN [Analytics].[DW].[DimFinancialCategory] fc
	ON t1.[FinancialCategoryID] = fc.[FinancialCategoryID]
	JOIN [Analytics].DW.DimDate T3
	ON t1.DateID = t3.DateID
	
	WHERE t3.[ActualDate] < convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear))
	--AND t1.DateID >= 20150101
	AND fc.EntityCode  = 'HBF'
	--AND fc.FundCode IN ('025')
	--AND fc.FundCode IN ('025',  '086')

	AND (
			(fc.FundCode = '067' AND GLCode IN ('10025', '10041')  AND t1.DateID >= 20140801)
			OR
			(fc.FundCode = '088' AND t1.DateID >= 20140801)

		)

	GROUP BY fundcode , FundName
	
	UNION
	SELECT 
	SUM(t1.amount) as TotalCashBalance , 'general' fundcode, 'General' FundName
	
	FROM [Analytics].[DW].[FactFinancialOther] t1
	INNER JOIN [Analytics].[DW].[DimFinancialCategory] fc
	ON t1.[FinancialCategoryID] = fc.[FinancialCategoryID]
	JOIN [Analytics].DW.DimDate T3
	ON t1.DateID = t3.DateID
	
	WHERE t3.[ActualDate] < convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear))
	--AND t1.DateID >= 20150101
	and fc.EntityCode  = 'HBF'
	--AND fc.FundCode IN ('025')
	--AND fc.FundCode IN ('025',  '086')

	AND (
			(fc.FundCode IN ('025','085' ) AND GLCode IN ('10025','10041','12010','12015','12090','13072','13076','13078','13079','13121' ) AND t1.DateID >= 20140801)
			

		)

	--GROUP BY fundcode , FundName