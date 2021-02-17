USE [aoc2016]
GO

/*


*/
set nocount on



drop table if exists #raw
create table #raw (rown int identity(1,1), s varchar(max))


--test data
/*
insert into #raw (s)
values 
('')

-- */
-- real data
--/*
insert into #raw(s)
select * from openrowset( bulk 'C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2016\day22.txt', formatfile = 'C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2016\rawload.xml' ) as x

-- */

drop table if exists #drives
-- Filesystem              Size  Used  Avail  Use%
-- /dev/grid/node-x0-y0     93T   67T    26T   72%

select	max(case when id = 2 then cast(substring(item,2,100) as int) else null end) as x,
		max(case when id = 3 then cast(substring(item,2,100) as int) else null end) as y,
		max(case when id = 4 then cast(substring(item,1,len(item)-1) as int) else null end) as sz,
		max(case when id = 5 then cast(substring(item,1,len(item)-1) as int) else null end) as used,
		max(case when id = 6 then cast(substring(item,1,len(item)-1) as int) else null end) as avail,
		max(case when id = 7 then cast(substring(item,1,len(item)-1) as int) else null end) as usepc
into #drives
from (
	select	rown, s, ROW_NUMBER() over (partition by rown order by x.id, y.id ) id, y.item	
	from #raw r
	outer apply (select * from dbo.fn_split(r.s, ' ')) as x
	outer apply (select * from dbo.fn_split(x.Item, '-')) as y
	where rown >= 3 
) as z
group by rown
order by rown


select count(*) part1 
from #drives d0
cross join #drives d1
where d0.used > 0
and (d0.x <> d1.x or d0.y <> d1.y)
and d0.used <= d1.avail

-- review the data
-- as per test data, drives are eith empty (one), have enough space to move around (max(used) < min(sz)), or are large can cannot move

/*
select * from #drives
order by avail

select * from #drives
order by sz

select * from #drives
where y = 0
order by x desc
*/

-- ... the only possible moves available are to move *something* onto the empty drive
-- Thus the optimal path should ( we are moving the data from top right to top left)
-- 1. move the 'empty' drive (hole) to the node left of interesting data
-- 2. move interesting data onto the hole (1 step)
-- 3. reposition the hole to the left of interesting data (which will be 4 steps)
-- 4. repeat 2-3 until data is at 0,0

-- visualise the data,

declare @line varchar(100)
declare @y int = 0, @maxy int

select @maxy = max(y) from #drives

while @y <= @maxy
begin
	set @line = ''
	select @line = @line +
		case when used = 0 then '_'
		 when used > 450 then '#'
		else '.'
		end
	from #drives
	where y = @y
	order by x

	raiserror(@line,0,0) with nowait

	set @y += 1
end

-- location of hole
select * from #drives
where used = 0
-- (13,23)

-- left edge of 'wall'
select top 1 * from #drives
where used > 450 
order by x
-- (6, 19)

select top 1 * from #drives
where y = 0
order by x desc

-- without a wall ... hole would take 23 steps to reach top row (13,0)		steps
-- but detour takes 8 steps left first (13 - 6 + 1 ) to (5,23)				8
-- then 23 steps to top row (5,0)											31
-- and 32 steps to (37,0) (left of the data we want at 38,0)				63
-- move data into vacant (37,0)												64
-- move the hole to the left of data at  (36,0) ( 4 steps )					68
-- repeat last two steps 36 times (hole now at (0,0), data at (1,0))		248
-- and finally move the data into (0,0)										249

select 36*5 + 8 + 23 + 32 + 1 + 4 + 1 part2

