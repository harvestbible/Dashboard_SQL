/*
CASH table:
	General, Reserve, Mortgage Sinking Fund, Systems Project, Camp Reserve, HCA Endowment 
	(all except Chicago West as it is a manual form
*/

DECLARE @ReportYear INT = 2016
DECLARE @ReportMonth TINYINT = 2

--SELECT convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear))
SELECT
 
	SUM(t1.amount) as Total

	--t1.amount, t1.DateID, t3.[ActualDate] 
	FROM [Analytics].[DW].[FactFinancialOther] t1
	INNER JOIN [Analytics].[DW].[DimFinancialCategory] fc
	ON t1.[FinancialCategoryID] = fc.[FinancialCategoryID]
	JOIN [Analytics].DW.DimDate T3
	ON t1.DateID = t3.DateID
	
	WHERE t3.[ActualDate] < convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear))
	AND t1.DateID >= 20150101
	AND 
	(
		(fc.FundCode = '035' AND GLCode = '10016') --reserve
		OR
		(fc.FundCode = '053' AND GLCode = '10016') --mtge sinking fund
		OR
		(fc.FundCode = '064' AND GLCode IN ('10016','20010','20020'))
		OR
		(fc.FundCode = '067' AND GLCode IN ('10016','10042','10045'))				
		OR
		(fc.FundCode = '275' AND GLCode IN ('10016','10025','20010','20020'))
		OR
		(fc.FundCode = '095' AND GLCode = '10016') --this is exact
		OR
		(fc.FundCode = '025' AND GLCode IN ('10016','10025','10042','10045','10060','20010','20020','22025')) --this is slightly off
		OR
		(fc.FundCode IN ('066', '055', '058', '063', '069', '089', '098')
				AND GLCode IN (10015,10016,10025,10034,10035,10041,10042,10045,10060,10061,10063,10067,10069,10072,10075,10076,
								10077,10091,10093,20010,20016,20018,20020,22025,23018,10017,10050,10052)
		)
					 		

	)


