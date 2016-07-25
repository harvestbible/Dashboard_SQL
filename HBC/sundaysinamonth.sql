
declare @d1 datetime
declare @d2 datetime
select @d1 = '1-1-2016', @d2 = '2-29-2016'
;with dates (date)
as
(
select @d1
union all
select dateadd(d,1,date)
from dates
where date < @d2
)

--select date from dates where datename(dw, date) = 'sunday'
select count(1) from dates where datename(dw, date) = 'sunday'
