

/*
Actual Revenue for HBF #1A Line Graph:  Actual Revenue vs. Budget
*/
	DECLARE @RevenueYear INT = 2016
	
	SELECT
	t3.[CalendarYear] , t3.[CalendarMonth], 
	SUM(t1.amount) as RevenueAmount

	FROM [Analytics].[DW].[FactRevenue] t1
	LEFT JOIN [Analytics].[DW].[DimFinancialCategory] t2
	ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
	JOIN [Analytics].DW.DimDate T3
	ON t1.DateID = t3.DateID
	INNER JOIN dw.DimEntity t4
	ON t1.EntityID = t4.EntityID
	AND t1.TenantID = t4.TenantID
	
	WHERE 
	t3.[CalendarYear] = @RevenueYear --year(getdate())
	AND t4.Code = 'HBF'
	AND fundcode = '025'  
	AND t2.[TenantID] = 3
	GROUP BY  t3.[CalendarYear] , t3.[CalendarMonth]
	order by t3.[CalendarYear] , t3.[CalendarMonth]

