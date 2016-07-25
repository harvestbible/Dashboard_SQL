
DECLARE @NumSun TINYINT,
@WeeklyBudgetAmount money = 460000,
 @BeginningDate DATETIME, @EndingDate DATETIME

SELECT @BeginningDate = '1-1-2016', @EndingDate = '12-31-2016'

;WITH dates (date)
AS
(
SELECT @BeginningDate
UNION all
SELECT dateadd(d,1,date)
FROM dates
WHERE date < @EndingDate
)



SELECT  month(date) as BudgetMonth
, year(date) as BudgetYear
, count(1) as NumSundaysInMonth
,  count(1) * @WeeklyBudgetAmount as WeeklyBudgetAmount
into #t1
from dates d1 where datename(dw, date) = 'sunday'

group by year(date), month(date)
option (maxrecursion 1000)

select * from #t1



select BudgetMonth, NumSundaysInMonth, WeeklyBudgetAmount
	, (select sum(d2.WeeklyBudgetAmount) from #t1 d2  where d2.BudgetMonth <= d1.BudgetMonth)  'CumulativeSum'

from #t1 d1

drop table #t1

