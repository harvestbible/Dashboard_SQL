USE Analytics

DECLARE @ReportYear INT = 2016
DECLARE @ReportMonth TINYINT = 5

	SELECT 
		 case t5.name
			WHEN 'UNKNOWN' THEN 'Deerfield Rd'
			ELSE t5.name 
			end  as Campus, 
		  SUM(t1.amount) as RevenueAmount,
		  (SUM(t1.amount) * 100) / 
					(select SUM(t1.amount)
					  FROM [Analytics].[DW].[FactRevenue] t1

						LEFT JOIN [Analytics].[DW].[DimFinancialCategory] t2
						ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
						JOIN [Analytics].DW.DimDate T3
						ON t1.DateID = t3.DateID
						INNER JOIN DW.DimEntity t4
						ON t1.EntityID = t4.EntityID
						AND t1.TenantID = t4.TenantID
						LEFT JOIN [Analytics].[DW].[DimCampus] t5
						ON t1.[CampusID] = t5.[CampusID]
						
						WHERE
						t3.[CalendarYear] = @ReportYear 
						AND t3.[CalendarMonth] <=  @ReportMonth  
						AND t4.Code = 'HBC'
						AND t2.[GLCode] = '30010'
						AND t2.[DepartmentCode] = '3015'
						AND t2.fundcode = '025'  
						AND t2.TenantID = 3) as rowPercent
		  
		   
	FROM [Analytics].[DW].[FactRevenue] t1
	
	LEFT JOIN [Analytics].[DW].[DimFinancialCategory] t2
		ON t1.[FinancialCategoryID] = t2.[FinancialCategoryID]
	INNER JOIN [Analytics].DW.DimDate T3
		ON t1.DateID = t3.DateID
	INNER JOIN DW.DimEntity t4
		ON t1.EntityID = t4.EntityID
		AND t1.TenantID = t4.TenantID
	LEFT JOIN [Analytics].[DW].[DimCampus] t5
		ON t1.[CampusID] = t5.[CampusID]
	
	WHERE
	t3.[CalendarYear] = @ReportYear 
	AND t3.[CalendarMonth] <=  @ReportMonth 
	AND t4.Code = 'HBC'
	AND t2.[GLCode] = '30010'
	AND t2.[DepartmentCode] = '3015'
	AND t2.fundcode = '025'  
	AND t2.TenantID = 3
	GROUP BY  t5.name 

