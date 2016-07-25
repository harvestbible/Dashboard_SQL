USE Analytics

DECLARE @ReportYear INT = 2016
DECLARE @ReportMonth TINYINT = 5

; WITH LastnSundays AS (
	SELECT  ActualDate, DateID
	 
	FROM DW.DimDate
	WHERE
		ActualDate >=  convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear -1)) 
		AND CalendarDayOfWeekLabel = 'Sunday'
	    AND ActualDate <= DATEADD(d,-1, (convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear)))))

, LastnWeekends AS (
	SELECT 'Current Week' AS SectionName, LastnSundays.ActualDate, DateID FROM LastnSundays
	UNION
	SELECT 'Previous Week' AS SectionName, LastnSundays.ActualDate,  CONVERT(VARCHAR(8), dateadd(d,-1,convert(date,convert(varchar(8),DateID))), 112)   FROM LastnSundays
)

--select * from LastnWeekends order by dateid

,  FullAttendance AS (
	SELECT distinct
		LastnWeekends.ActualDate AS WeekendDate
		, SUM(FactAttendance.AttendanceCount) AS AttendanceCount
	FROM DW.FactAttendance
	INNER JOIN LastnWeekends 
		ON FactAttendance.InstanceDateID IN ( LastnWeekends.DateID) 
	INNER JOIN DW.DimMinistry
		ON FactAttendance.MinistryID = DimMinistry.MinistryID
	LEFT JOIN DW.DimCampus
		ON FactAttendance.CampusID = DimCampus.CampusID
	LEFT JOIN DW.DimCampus campus2
		ON DimMinistry.CampusID = campus2.CampusID
	WHERE
		DimMinistry.Name IN (
			  'AU - Churchwide Services'
			, 'CC - Churchwide Services'
			, 'CL - Churchwide Services'
			, 'DR - Chuchwide Services'
			, 'EL - Churchwide Services'
			, 'NI - Churchwide Services'
			, 'RM - Churchwide Services'
			, 'Camp'
			, 'Other')
		OR DimMinistry.Name LIKE '%Harvest Kids'
	GROUP BY
		LastnWeekends.ActualDate 	
)

--SELECT * FROM FullAttendance

SELECT  --campus, 
AVG(attendancecount), Year(FullAttendance.WeekendDate),  Month(FullAttendance.WeekendDate)
FROM  FullAttendance
GROUP BY Year(FullAttendance.WeekendDate),  Month(FullAttendance.WeekendDate)
ORDER BY Year(FullAttendance.WeekendDate),  Month(FullAttendance.WeekendDate)

