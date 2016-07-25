
USE Analytics
/*
actual revenue for HBCG line chart 1
*/

DECLARE @ReportYear INT = 2016
DECLARE @ReportMonth TINYINT = 12

;WITH Revenue AS (
	SELECT 
	SUM(t1.amount) as Amount,  t3.[CalendarYear] , t3.[CalendarMonth] --, t4.Code 
	 , ROW_NUMBER() OVER(ORDER BY t3.[CalendarYear] , t3.[CalendarMonth] ) AS RowNum
	
	FROM [Analytics].[DW].[FactRevenue] t1
	INNER JOIN [Analytics].[DW].[DimFinancialCategory] t2
	ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]

	JOIN [Analytics].DW.DimDate T3
	ON t1.DateID = t3.DateID

	INNER JOIN dw.DimEntity t4
	ON t1.EntityID = t4.EntityID
	AND t1.TenantID = t4.TenantID

	WHERE   t2.TenantID = 3
	AND t3.[CalendarYear] = @ReportYear
	AND t3.[CalendarMonth] <= @ReportMonth
	AND
		(
		(t4.Code IN ('HCA', 'HBF') AND t2.fundcode = '025') 
		OR
		(t4.Code = 'WITW' AND t2.fundcode IN  ('025', '086')) 
		OR
		(t4.Code = 'HBC' AND t2.fundcode = '025' AND t2.[GLCode] = '30010' AND t2.[DepartmentCode] = '3015')
		)

	GROUP BY  t3.[CalendarYear] , t3.[CalendarMonth] --, t4.Code 
	--order by t3.[CalendarYear] , t3.[CalendarMonth]
	)


	 SELECT Amount,   tr.[CalendarYear] , tr.[CalendarMonth] -- , tr.Code
	 , (SELECT SUM(tc.Amount) FROM Revenue tc WHERE tc.RowNum <= tr.RowNum ) AS CumulativeSum
	 FROM Revenue tr 
	 ORDER BY   tr.[CalendarYear] , tr.[CalendarMonth]  