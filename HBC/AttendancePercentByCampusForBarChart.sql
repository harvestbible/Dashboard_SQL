USE Analytics

DECLARE @ReportYear INT = 2016
DECLARE @ReportMonth TINYINT = 5

; WITH LastnSundays AS (
	SELECT  ActualDate, DateID
	 
	FROM DW.DimDate
	WHERE
		ActualDate >= (convert(date,  convert(varchar(10),@ReportMonth ) + '/01/'+  convert(varchar(10),@ReportYear)))
		AND CalendarDayOfWeekLabel = 'Sunday'
	    AND ActualDate <= DATEADD(d,-1, (convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear))))
	--ORDER BY ActualDate DESC
	)

	--select * from LastnSundays

, LastnWeekends AS (
	SELECT 'Current Week' AS SectionName, LastnSundays.ActualDate, DateID FROM LastnSundays
	UNION
	SELECT 'Previous Week' AS SectionName, LastnSundays.ActualDate,  CONVERT(VARCHAR(8), dateadd(d,-1,convert(date,convert(varchar(8),DateID))), 112)   FROM LastnSundays
)

--select * from LastnWeekends order by dateid


, FullAttendance AS (
	SELECT DISTINCT
		  LastnWeekends.SectionName
		, LastnWeekends.ActualDate AS WeekendDate
		--, DimCampus.Code
		, CASE WHEN DimCampus.Code = '--' AND DimMinistry.Name IN ('Camp','Other') THEN 'Camp / Other' ELSE 
			CASE WHEN DimCampus.Code  = '--' THEN Campus2.Code ELSE DimCampus.Code END END AS Campus
		, DimMinistry.Name AS MinistryName
		, CASE WHEN DimMinistry.Name IN (
			  'AU - Churchwide Services'
			, 'CC - Churchwide Services'
			, 'CL - Churchwide Services'
			, 'DR - Chuchwide Services'
			, 'EL - Churchwide Services'
			, 'NI - Churchwide Services'
			, 'RM - Churchwide Services'
			, 'Camp'
			, 'Other') THEN 'ADULTS' ELSE
			'KIDS' END AS AttendanceCategory
		, FactAttendance.AttendanceCount
	FROM DW.FactAttendance
	INNER JOIN LastnWeekends 
		ON FactAttendance.InstanceDateID = LastnWeekends.DateID
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
	
)

--select *  FROM FullAttendance

SELECT
	SectionName, WeekendDate
	, CASE Campus
		WHEN 'RM' THEN 2
		WHEN 'EL' THEN 3
		WHEN 'CL' THEN 4
		WHEN 'NI' THEN 5
		WHEN 'CC' THEN 6
		WHEN 'AU' THEN 7
		WHEN 'DR' THEN 8
		WHEN 'Camp / Other' THEN 9 END AS RowNumber
	, Campus, MinistryName, AttendanceCategory, SUM(AttendanceCount) AS AttendanceCount
	into #FullAttendance2
FROM FullAttendance
where campus <> 'Camp / Other'
GROUP BY 
	SectionName, WeekendDate
	, CASE Campus
		WHEN 'RM' THEN 2
		WHEN 'EL' THEN 3
		WHEN 'CL' THEN 4
		WHEN 'NI' THEN 5
		WHEN 'CC' THEN 6
		WHEN 'AU' THEN 7
		WHEN 'DR' THEN 8
		WHEN 'Camp / Other' THEN 9 END
	, Campus, MinistryName, AttendanceCategory
--

-- select *  FROM #FullAttendance2

	SELECT  campus, 
	sum(attendancecount), 
	--round((sum(attendancecount) * 100.0) / 
	--	(
	--	SELECT sum(attendancecount) FROM  #FullAttendance2 WHERE AttendanceCategory = 'ADULTS' and campus <> 'Camp / Other'
	--	),0)as rowPercent
	(sum(attendancecount) * 100.0) / 
	(
	SELECT sum(attendancecount) FROM  #FullAttendance2 WHERE AttendanceCategory = 'ADULTS' and campus <> 'Camp / Other'
	)as rowPercent

FROM  #FullAttendance2 
WHERE AttendanceCategory = 'ADULTS'
and campus <> 'Camp / Other'
group by  campus
ORDER by campus

drop table #FullAttendance2