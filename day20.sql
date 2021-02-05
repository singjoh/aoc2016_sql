USE [aoc2016]
GO

/*


*/
set nocount on
set nocount on



drop table if exists #raw
create table #raw (rown int identity(1,1), s varchar(max))

--test data
/*
insert into #raw (s)
values 
('5-8'),
('0-2'),
('4-7') -- becomes 445 characters long.
--*/
-- real data
--/*
insert into #raw(s)
select * from openrowset( bulk 'C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2016\day20.txt', formatfile = 'C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2016\rawload.xml' ) as x

-- */

drop table if exists #data

select rown, cast(substring(s,1,charindex('-',s)-1) as bigint) l, cast(substring(s,charindex('-',s)+1,100) as bigint) h
into #data
from #raw

-- is 0 free ?
select *
from #data where l <= 0 and h >= 0

-- no, check for first unbracketed 'high' terms, the lowest of these is before the smallest item
select min(foo.h) + 1 part1
from #data foo
left join #data bar
	on bar.l <= foo.h + 1 -- add one to the high, groups are A-B,C-D, not A-B,B-C
	and bar.h >= foo.h
	and bar.rown <> foo.rown
where bar.rown is null

select min(l) + (4294967295 - max(h)) from #data  -- any ip before smallest and largest
-- no so we can ignore the edges and just look for gaps

select sum(x.nxl - foo.h - 1) --   e.g. 1-3, 5-7, will have h=3, nxl = 5, so we need nxl - h -1 to get the one free address
from #data foo
left join #data bar
	on bar.l <= foo.h + 1 -- add one to the high, groups are A-B,C-D, not A-B,B-C
	and bar.h >= foo.h
	and bar.rown <> foo.rown
outer apply (select min(l) nxl from #data where l >= foo.h) as x -- find the next group
where bar.rown is null -- no term brackets the end of this group
and nxl is not null  -- and there is a later group
