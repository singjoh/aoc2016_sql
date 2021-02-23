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
('###########'),
('#0.1.....2#'),
('#.#######.#'),
('#4.......3#'),
('###########')

--*/
-- real data
--/*

insert into #raw(s)
select * from openrowset( bulk 'C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2016\day24.txt', FORMATFILE='C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2016\rawload.xml') as x

-- */
drop table if exists #grid
drop table if exists #paths
drop table if exists #bfs
drop table if exists #loc

select id x, rown y, item  
into #grid
from #raw r
outer apply (select * from dbo.fn_split(r.s,null)) as x
where item <> '#'

select item, ROW_NUMBER() over (order by cast (item as int)) rown
into #loc
from #grid
where item <> '.'

create table #bfs (x int, y int, pathlen int)
create table #paths (pathstart varchar(1), pathend varchar(1), pathlen int)

declare @pathlen int
declare @rown int, @maxrown int, @pathstart varchar(1)

select @rown = 0, @maxrown = max(rown) from #loc
while @rown < @maxrown
begin
	set @rown += 1

	select @pathstart = item from #loc where rown = @rown

	raiserror('Working on paths starting at %s',0,0,@pathstart) with nowait

	truncate table #bfs
	set @pathlen = 0

	insert into #bfs 
	select x, y, @pathlen from #grid where item = @pathstart

	while 1=1
	begin

		insert into #bfs 
		select distinct n.x, n.y, @pathlen + 1
		from #bfs p 
		cross join (select -1 dx, 0 dy union select 1, 0 union select 0, -1 union select 0, 1) as d 
		outer apply (select p.x + d.dx x, p.y + d.dy y) as n
		join #grid g
			on g.x = n.x
			and g.y = n.y
		left join #bfs p0
			on p0.x = n.x 
			and p0.y = n.y 
		where p.pathlen = @pathlen
		and p0.x is null -- don't return to somewhere we've already visited

		if @@ROWCOUNT = 0 break -- scanned the entire grid, though could optimise further

		set @pathlen += 1
	end

	insert into #paths
	select @pathstart, item, pathlen
	from #grid g
	join #bfs p
		on p.x = g.x
		and p.y = g.y
	where g.Item not in (@pathstart,'.')

end

-- how many points to visit
select @pathlen = max(rown) from #loc

;with ctepath as (
	select pathend, cast('0' + pathend as varchar(max)) as visited, pathlen from #paths where pathstart = '0'
	union all
	select p.pathend, c.visited + p.pathend, c.pathlen + p.pathlen
	from ctepath c
	join #paths p
		on p.pathstart = c.pathend
		and CHARINDEX(p.pathend,c.visited) = 0
	)
	select top 1 visited, pathlen part1 from ctepath
	where len(visited) = @pathlen
	order by pathlen

;with ctepath as (
	select pathend, cast('0' + pathend as varchar(max)) as visited, pathlen from #paths where pathstart = '0'
	union all
	select p.pathend, c.visited + p.pathend, c.pathlen + p.pathlen
	from ctepath c
	join #paths p
		on p.pathstart = c.pathend
		and CHARINDEX(p.pathend,c.visited) = 0
	)
	select top 1 visited + '0', c.pathlen + p.pathlen part2 
	from ctepath c
	join #paths p
		on p.pathstart = c.pathend
		and p.pathend = '0'
	where len(visited) = @pathlen
	order by 2