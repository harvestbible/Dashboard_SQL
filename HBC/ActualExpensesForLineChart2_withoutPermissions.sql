

--Budget Expense
WITH Attendance AS(
	SELECT FactAttendance.CampusID, DimCampus.Code, SUM(AttendanceCount) AttendanceCount
	FROM dw.FactAttendance
	INNER JOIN DW.DimAttendanceType
		ON FactAttendance.AttendanceTypeID = DimAttendanceType.AttendanceTypeID
	INNER JOIN dw.DimDate
		ON FactAttendance.InstanceDateID = DimDate.DateID
	INNER JOIN DW.DimCampus
		ON FactAttendance.CampusID = DimCampus.CampusID
	WHERE
		DimCampus.Code NOT IN ('--','WW','SP')
		AND DimAttendanceType.Category = 'Attendee'
		AND FactAttendance.Age >= 18
		AND CalendarYear = 2016
	GROUP BY
		FactAttendance.CampusID, DimCampus.Code
	UNION
	SELECT CampusID, Code, 0 AS AttendanceCount 
	FROM dw.DimCampus
	WHERE DimCampus.Code NOT IN ('--','WW','SP')
	UNION
	SELECT -1, 'Initiatives/BB',0

), AttendanceTotal AS (
	SELECT SUM(AttendanceCount) AS AttendanceCount
	FROM Attendance
) , CampusAllocationCalculation AS (
	SELECT 
		CampusID, Code
		, (Attendance.AttendanceCount * 1.0) / (SELECT AttendanceCount FROM AttendanceTotal) AS CampusPercent
	FROM Attendance
), CampusAllocation AS (
	SELECT
		CampusID, Code, MAX(CampusPercent) AS CampusPercent
	FROM  CampusAllocationCalculation
	GROUP BY 
		CampusID, Code
), Expenses AS (
	SELECT
		  ISNULL(CampusXLTReportGroup_CampusTab.CampusXLTReportGroupID, 61) AS CampusXLTReportGroupID
		, ISNULL(CampusXLTReportGroup_CampusTab.CampusHeading, 'Ministries') AS Heading
		, ISNULL(CampusXLTReportGroup_CampusTab.CampusDetail, 'Other') AS Detail
		, ISNULL(CampusXLTReportGroup_CampusTab.CampusDetailSortOrder, 54) AS CampusDetailSortOrder 
		, ISNULL( CampusAllocation.Code, CampusXLTReportGroup_CampusTab.CampusCode) AS CampusCode
		, CASE ISNULL( CampusAllocation.Code, CampusXLTReportGroup_CampusTab.CampusCode)
			WHEN 'Initiatives/BB' THEN 1
			WHEN 'EL' THEN 2
			WHEN 'RM' THEN 3
			WHEN 'NI' THEN 4
			WHEN 'CL' THEN 5
			WHEN 'CC' THEN 6
			WHEN 'AU' THEN 7
			WHEN 'DR' THEN 8 END AS CampusCodeSortOrder
		, SUM(CASE WHEN CampusXLTReportGroup_CampusTab.AllocateByAttendancePercentage = 0 THEN 
				CASE WHEN ISNULL( CampusAllocation.Code, CampusXLTReportGroup_CampusTab.CampusCode) = CampusXLTReportGroup_CampusTab.CampusCode THEN Amount ELSE 0 END
			  ELSE Amount * CampusAllocation.CampusPercent END) AS Amount 
	FROM dw.FactBudgetExpense
	INNER JOIN dw.DimEntity
		ON FactBudgetExpense.EntityID = DimEntity.EntityID
		AND FactBudgetExpense.TenantID = DimEntity.TenantID
	INNER JOIN dw.DimFinancialCategory
		ON FactBudgetExpense.FinancialCategoryID = DimFinancialCategory.FinancialCategoryID
		AND FactBudgetExpense.TenantID = DimFinancialCategory.TenantID
	LEFT JOIN CampusXLTReportGroup_CampusTabMap 
		ON CampusXLTReportGroup_CampusTabMap.FinancialCategoryID = FactBudgetExpense.FinancialCategoryID
	LEFT JOIN CampusXLTReportGroup_CampusTab
		ON  CampusXLTReportGroup_CampusTabMap.CampusXLTReportGroupID = CampusXLTReportGroup_CampusTab.CampusXLTReportGroupID
	INNER JOIN CampusAllocation
		ON 1=1
	WHERE
		DimEntity.Code = 'HBC'
		AND DimFinancialCategory.FundCode = '025'
		AND FactBudgetExpense.BudgetYear = 2016 AND FactBudgetExpense.BudgetMonth = 2
	GROUP BY
		  ISNULL(CampusXLTReportGroup_CampusTab.CampusXLTReportGroupID, 61) 
		, ISNULL(CampusXLTReportGroup_CampusTab.CampusHeading, 'Ministries')
		, ISNULL(CampusXLTReportGroup_CampusTab.CampusDetail, 'Other')
		, ISNULL(CampusXLTReportGroup_CampusTab.CampusDetailSortOrder, 54)
		, ISNULL( CampusAllocation.Code, CampusXLTReportGroup_CampusTab.CampusCode)
		, CASE ISNULL( CampusAllocation.Code, CampusXLTReportGroup_CampusTab.CampusCode)
			WHEN 'Initiatives/BB' THEN 1
			WHEN 'EL' THEN 2
			WHEN 'RM' THEN 3
			WHEN 'NI' THEN 4
			WHEN 'CL' THEN 5
			WHEN 'CC' THEN 6
			WHEN 'AU' THEN 7
			WHEN 'DR' THEN 8 END
		--don't forget APO/FAO expenses
		--no budgeted apo/FAO records
		UNION 
		SELECT
		  ISNULL(CampusXLTReportGroup_CampusTab.CampusXLTReportGroupID, 61) AS CampusXLTReportGroupID
		, ISNULL(CampusXLTReportGroup_CampusTab.CampusHeading, 'Ministries') AS Heading
		, ISNULL(CampusXLTReportGroup_CampusTab.CampusDetail, 'Other') AS Detail
		, ISNULL(CampusXLTReportGroup_CampusTab.CampusDetailSortOrder, 54) AS CampusDetailSortOrder 
		, ISNULL( CampusAllocation.Code, CampusXLTReportGroup_CampusTab.CampusCode) AS CampusCode
		, CASE ISNULL( CampusAllocation.Code, CampusXLTReportGroup_CampusTab.CampusCode)
			WHEN 'Initiatives/BB' THEN 1
			WHEN 'EL' THEN 2
			WHEN 'RM' THEN 3
			WHEN 'NI' THEN 4
			WHEN 'CL' THEN 5
			WHEN 'CC' THEN 6
			WHEN 'AU' THEN 7
			WHEN 'DR' THEN 8 END AS CampusCodeSortOrder
		, 0 AS Amount 
	FROM CampusXLTReportGroup_CampusTab, CampusAllocation
	GROUP BY
		  ISNULL(CampusXLTReportGroup_CampusTab.CampusXLTReportGroupID, 61) 
		, ISNULL(CampusXLTReportGroup_CampusTab.CampusHeading, 'Ministries')
		, ISNULL(CampusXLTReportGroup_CampusTab.CampusDetail, 'Other')
		, ISNULL(CampusXLTReportGroup_CampusTab.CampusDetailSortOrder, 54)
		, ISNULL( CampusAllocation.Code, CampusXLTReportGroup_CampusTab.CampusCode)
		, CASE ISNULL( CampusAllocation.Code, CampusXLTReportGroup_CampusTab.CampusCode)
			WHEN 'Initiatives/BB' THEN 1
			WHEN 'EL' THEN 2
			WHEN 'RM' THEN 3
			WHEN 'NI' THEN 4
			WHEN 'CL' THEN 5
			WHEN 'CC' THEN 6
			WHEN 'AU' THEN 7
			WHEN 'DR' THEN 8 END
), MinistryRevenues AS (
	SELECT
		  ISNULL(CampusXLTReportGroup_CampusTab.CampusXLTReportGroupID, 61) AS CampusXLTReportGroupID
		, ISNULL(CampusXLTReportGroup_CampusTab.CampusHeading, 'Ministries') AS Heading
		, ISNULL(CampusXLTReportGroup_CampusTab.CampusDetail, 'Other') AS Detail
		, ISNULL(CampusXLTReportGroup_CampusTab.CampusDetailSortOrder, 54) AS CampusDetailSortOrder 
		, ISNULL( CampusAllocation.Code, CampusXLTReportGroup_CampusTab.CampusCode) AS CampusCode
		, CASE ISNULL( CampusAllocation.Code, CampusXLTReportGroup_CampusTab.CampusCode)
			WHEN 'Initiatives/BB' THEN 1
			WHEN 'EL' THEN 2
			WHEN 'RM' THEN 3
			WHEN 'NI' THEN 4
			WHEN 'CL' THEN 5
			WHEN 'CC' THEN 6
			WHEN 'AU' THEN 7
			WHEN 'DR' THEN 8 END AS CampusCodeSortOrder
		, SUM(CASE WHEN CampusXLTReportGroup_CampusTab.AllocateByAttendancePercentage = 0 THEN 
				CASE WHEN ISNULL( CampusAllocation.Code, CampusXLTReportGroup_CampusTab.CampusCode) = CampusXLTReportGroup_CampusTab.CampusCode THEN Amount ELSE 0 END
			  ELSE Amount * CampusAllocation.CampusPercent END) AS Amount 
	FROM dw.FactBudgetRevenue
	INNER JOIN dw.DimEntity
		ON FactBudgetRevenue.EntityID = DimEntity.EntityID
		AND FactBudgetRevenue.TenantID = DimEntity.TenantID
	INNER JOIN dw.DimFinancialCategory
		ON FactBudgetRevenue.FinancialCategoryID = DimFinancialCategory.FinancialCategoryID
		AND FactBudgetRevenue.TenantID = DimFinancialCategory.TenantID
	LEFT JOIN CampusXLTReportGroup_CampusTabMap 
		ON CampusXLTReportGroup_CampusTabMap.FinancialCategoryID = FactBudgetRevenue.FinancialCategoryID
	LEFT JOIN CampusXLTReportGroup_CampusTab
		ON  CampusXLTReportGroup_CampusTabMap.CampusXLTReportGroupID = CampusXLTReportGroup_CampusTab.CampusXLTReportGroupID
	INNER JOIN CampusAllocation
		ON 1=1
	WHERE
		DimEntity.Code = 'HBC'
		AND DimFinancialCategory.FundCode = '025'
		AND FactBudgetRevenue.BudgetYear = 2016 AND FactBudgetRevenue.BudgetMonth = 2
		AND ISNULL(CampusDetail,'Other') <> 'Other' -- Net expenses consider all but "other"
	GROUP BY
		  ISNULL(CampusXLTReportGroup_CampusTab.CampusXLTReportGroupID, 61)
	, ISNULL(CampusXLTReportGroup_CampusTab.CampusHeading, 'Ministries') 
	, ISNULL(CampusXLTReportGroup_CampusTab.CampusDetail, 'Other') 
	, ISNULL(CampusXLTReportGroup_CampusTab.CampusDetailSortOrder, 54)
	, ISNULL( CampusAllocation.Code, CampusXLTReportGroup_CampusTab.CampusCode)
		, CASE ISNULL( CampusAllocation.Code, CampusXLTReportGroup_CampusTab.CampusCode)
			WHEN 'Initiatives/BB' THEN 1
			WHEN 'EL' THEN 2
			WHEN 'RM' THEN 3
			WHEN 'NI' THEN 4
			WHEN 'CL' THEN 5
			WHEN 'CC' THEN 6
			WHEN 'AU' THEN 7
			WHEN 'DR' THEN 8 END
)
SELECT 
	  Expenses.CampusXLTReportGroupID
	, Expenses.Heading
	, Expenses.Detail
	, Expenses.CampusDetailSortOrder
	, Expenses.CampusCode
	, Expenses.CampusCodeSortOrder
	, SUM(Expenses.Amount) AS Expenses
	, SUM(ISNULL(MinistryRevenues.Amount, 0)) AS MinistryRevenues
	, SUM(Expenses.Amount - ISNULL(MinistryRevenues.Amount,0)) AS Amount
FROM Expenses
LEFT JOIN MinistryRevenues
	ON expenses.CampusXLTReportGroupID = MinistryRevenues.CampusXLTReportGroupID	
GROUP BY
	Expenses.CampusXLTReportGroupID
	, Expenses.Heading
	, Expenses.Detail
	, Expenses.CampusDetailSortOrder
	, Expenses.CampusCode
	, Expenses.CampusCodeSortOrder
ORDER BY 
	1, 4, 6