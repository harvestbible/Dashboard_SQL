

/*
Actual Revenue for HBF #1A Line Graph:  Actual Giving vs. Projection
*/

	SELECT --top 100 *
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
	t3.[CalendarYear] = year(getdate())
	AND t4.Code = 'witw'
	--AND t2.[GLCode] = '30010'
	--AND t2.[DepartmentCode] = '3015'
	AND fundcode = '025'  --I added, this was not in the spec
	AND t2.[TenantID] = 3
	GROUP BY  t3.[CalendarYear] , t3.[CalendarMonth]
	order by t3.[CalendarYear] , t3.[CalendarMonth]

