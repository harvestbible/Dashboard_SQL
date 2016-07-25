USE Analytics
/*
HBC Averages
*/

DECLARE @YearForReport INT = 2016
DECLARE @ReportYear INT = @YearForReport
DECLARE @ReportMonth TINYINT = 2

; WITH LastNSundaysCurrentRoll AS (
	SELECT ActualDate, DateID
	--into #LastNSundaysCurrentRoll
	FROM DW.DimDate
	WHERE
	--DateID <= 20150228 and DateID >= 20150101 
		actualdate  <=   DATEADD(d,-1, (convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear))))
		AND actualdate >=  convert(date, convert(varchar(10),@ReportMonth +1 ) + '/01/'+  convert(varchar(10),@ReportYear -1))
		AND CalendarDayOfWeekLabel = 'Sunday'
)

	----------Attendance data  current Rolling 12 months
, LastTwoWeekendsRollCurrent AS (
	SELECT 'Current Week'  AS SectionName, LastNSundaysCurrentRoll.ActualDate, DateID FROM LastNSundaysCurrentRoll
	UNION
	SELECT   'Previous Week'  AS SectionName, LastNSundaysCurrentRoll.ActualDate, CONVERT(VARCHAR(8), dateadd(d,-1,convert(date,convert(varchar(8),DateID))), 112)  FROM LastNSundaysCurrentRoll
	)

--select * from LastTwoWeekendsRollCurrent order by ActualDate

, FullAttendanceCurrent AS (
	SELECT DISTINCT
		  tr.SectionName
		, tr.ActualDate AS WeekendDate
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
		--into #FullAttendanceCurrent
	FROM DW.FactAttendance
	INNER JOIN LastTwoWeekendsRollCurrent tr 
		ON FactAttendance.InstanceDateID = tr.DateID
	INNER JOIN DW.DimMinistry
		ON FactAttendance.MinistryID = DimMinistry.MinistryID
	INNER JOIN [Analytics].[DW].[DimActivity] t2
		on DimMinistry.[MinistryID] = t2.[MinistryID]
	LEFT JOIN DW.DimCampus
		ON FactAttendance.CampusID = DimCampus.CampusID
	LEFT JOIN DW.DimCampus campus2
		ON DimMinistry.CampusID = campus2.CampusID
	WHERE
		(DimMinistry.Name IN (
			  'AU - Churchwide Services'
			, 'CC - Churchwide Services'
			, 'CL - Churchwide Services'
			, 'DR - Chuchwide Services'
			, 'EL - Churchwide Services'
			, 'NI - Churchwide Services'
			, 'RM - Churchwide Services'
			, 'Camp'
			, 'Other'))
		OR 
		--(
		DimMinistry.Name LIKE '%Harvest Kids'
		-- and  t2.Name LIKE '%Kids Weekend')
 )
	
	select year(fa.WeekendDate) as Year, month(fa.WeekendDate) as month --, sum(fa.AttendanceCount), count(distinct(fa.WeekendDate)) as numweeks
	, (sum(fa.AttendanceCount) / count(distinct(fa.WeekendDate))) as avgAttendance
	from FullAttendanceCurrent fa
	group by year(fa.WeekendDate), month(fa.WeekendDate)
	order by  year(fa.WeekendDate), month(fa.WeekendDate)


