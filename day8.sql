USE [aoc2016]
GO

/*


*/


set nocount on



drop table if exists #raw
create table #raw (rown int identity(1,1), s varchar(max))

declare @x int, @y int 
--test data
/*
set @x = 7
set @y = 3
insert into #raw (s)
values 
('rect 3x2'), 
('rotate column x=1 by 1'), 
('rotate row y=0 by 4'), 
('rotate column x=1 by 1')
--*/
-- real data
--/*
set @x = 50
set @y = 6
insert into #raw(s)
select * from openrowset( bulk 'C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2016\day8.txt', FORMATFILE='C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2016\rawload.xml') as x

-- */

drop table if exists #rules

select	rown, 
		max(case	when id = 1 and item = 'rect' then 'SET' 
					when id = 2 and item = 'column' then 'ROTC' 
					when id = 2  and item = 'row' then 'ROTR' 
						else null 
					end) as op,
		cast(max(case	when id = 2 and charindex('x',item) > 0 then substring(item,1,charindex('x',item)-1) 
					when id = 3 and charindex('=',item) > 0 then substring(item,charindex('=',item)+1,4000) 
						else null end) 
				as int) as p1,
		cast(max(case	when id = 2 and charindex('x',item) > 0 then substring(item,charindex('x',item)+1,4000) 
					when id = 5 then item  
						else null end) 
				as int) as p2
into #rules
from #raw r
outer apply (select * from dbo.fn_split(r.s,' ')) as x 
group by rown

drop table if exists #grid
create table #grid(x int,y int,isOn bit)

;WITH	E1(N)        AS ( SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                         UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                         UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1),
		E2(N)        AS (SELECT 1 FROM E1 a, E1 b),
		cteTally(N)  AS (SELECT 0 UNION ALL SELECt ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E2)
insert into #grid
select x.n, y.n, 0
from cteTally x
cross join cteTally y
where x.n < @x
and y.n < @y

declare @p1 int, @p2 int
declare @rown int = 0
declare @maxrown int
declare @op varchar(4) 
declare @displine varchar(max)

select @maxrown = max(rown) from #rules

while @rown < @maxrown
begin
	set @rown += 1 

	select @op = op, @p1 = p1, @p2 = p2
	from #rules
	where rown = @rown

	if @op = 'SET'
	update #grid
	set isOn = 1
	where x < @p1
	and y < @p2

	if @op = 'ROTC'
	update g2
	set isOn = g.isOn
	from #grid g
	join #grid g2
		on g2.x = g.x
		and g2.y = (g.y + @p2) % @y
	where g.x = @p1

	if @op = 'ROTR'
	update g2
	set isOn = g.isOn
	from #grid g
	join #grid g2
		on g2.y = g.y
		and g2.x = (g.x + @p2) % @x
	where g.y = @p1

end

select count(*) part1 from #grid where ison = 1

-- display the grid
set @p1 = -1
while @p1 < @y
begin
	set @p1 += 1
	set @displine = ''

	-- '+' and ' ' are roughly the same size in dispalys, so use '+' for on and ' ' for off

	select @displine = @displine + case when isOn = 1 then '+' else ' ' end
	from #grid
	where y = @p1
	order by x

	print @displine
end


