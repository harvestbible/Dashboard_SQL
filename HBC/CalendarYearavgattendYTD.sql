
DECLARE @ReportYear INT = 2016
DECLARE @ReportMonth TINYINT = 2


SELECT 
 td.[CalendarYear] 

, SUM([AttendanceCount]) / 
(select  count (distinct(MinistryWeekEndLabel))  FROM [Analytics].[DW].[DimDate] t2 
		where td.CalendarMonth = t2.CalendarMonth and td.CalendarYear = t2.CalendarYear and month(MinistryWeekEndLabel) = td.CalendarMonth )  as AveAtt

FROM [Analytics].[DW].[FactAttendance] tf
INNER JOIN [Analytics].[DW].[DimMinistry] tm
	ON tf.[MinistryID] = tm.[MinistryID]
INNER JOIN [Analytics].DW.DimDate td
	ON tf.[InstanceDateID] = td.DateID 
INNER JOIN [Analytics]. DW.DimActivity tv
        ON tf.ActivityID = tv.ActivityID
        AND tf.TenantID = tv.TenantID
INNER JOIN [Analytics].DW.DimAttendanceType at
	ON tf.AttendanceTypeID = at.AttendanceTypeID
	AND tf.TenantID = at.TenantID
WHERE

td.[CalendarYear] in (@ReportYear, (@ReportYear-1), (@ReportYear-2))
AND td.[CalendarMonth] <= @ReportMonth

AND 
	(
    tm.Name LIKE '%Chuchwide Service%'
    OR tm.Name LIKE '%Churchwide Service%'
    OR tm.Name LIKE '%Harvest Kid%'
	)
	
AND at.Category = 'Attendee'
group by td.[CalendarYear]

--order by td.[CalendarYear], td.[CalendarMonth] 
