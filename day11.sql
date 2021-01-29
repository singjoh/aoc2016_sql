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
('The first floor contains a hydrogen-compatible microchip and a lithium-compatible microchip.'),
('The second floor contains a hydrogen generator.'),
('The third floor contains a lithium generator.'),
('The fourth floor contains nothing relevant.')
--*/
-- real data
--/*
insert into #raw (s)
values 
('The first floor contains a polonium generator, a thulium generator, a thulium-compatible microchip, a promethium generator, a ruthenium generator, a ruthenium-compatible microchip, a cobalt generator, and a cobalt-compatible microchip.'),
('The second floor contains a polonium-compatible microchip and a promethium-compatible microchip.'),
('The third floor contains nothing relevant.'),
('The fourth floor contains nothing relevant.')

--insert into #raw(s)
--select * from openrowset( bulk 'C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2016\day11.txt', FORMATFILE='C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2016\rawload.xml') as x

-- */

drop table if exists #state
;with cte as (
	select *
	from #raw r
	outer apply (select * from dbo.fn_split(r.s,' ')) as x
	)
select *, ROW_NUMBER() over (order by element, itemtype) id
	into #state
from (
	select	c1.rown fnum, 
			case when c1.item like '%-compatible' then SUBSTRING(c1.item,1,CHARINDEX('-',c1.item)-1) else c2.item end element,
			case when c1.item like '%-compatible' then 'chip' else 'rtg' end itemtype
	from cte c1
	join cte c2
		on c2.rown = c1.rown
		and c2.id = c1.id - 1
	where c1.item like '%-compatible'
	or c1.item like 'generator%'
) as x

-- Assuming there are two types of start state:
--   One such that this can be solved by emptying floor1, then floor2 ...
-- And one that requires some sort of other movements to enable that state 
-- We note that the example given in not optimal, it can be done in 9

-- Simple state will require 2*(n-1)-1 steps to move n items from one floor to the next (n>1)

declare @moves int = 0
declare @fnum int
declare @items int

declare @part1 int = 0

if @part1 = 1
begin
	while (select count(*) from #state where fnum = 4) < (select count(*) from #state)
	begin
		select @fnum = min (fnum) from #state
	
		select @moves = @moves + 2 * (count(*) - 1 ) - 1 
		from #state  where fnum = @fnum

		update #state set fnum = @fnum + 1 where fnum = @fnum
	end
	select @moves part1
end
else
begin
	insert into #state (fnum,element,itemtype,id)
	select 1,element,itemtype,mx.id + ROW_NUMBER() over (order by element, itemtype)
	from (select 'elerium' element union select 'dilithium') as e
	cross join (select 'chip' itemtype union select 'rtg') as t
	cross join (select max(id) id from #state) mx

	while (select count(*) from #state where fnum = 4) < (select count(*) from #state)
	begin
		select @fnum = min (fnum) from #state
	
		select @moves = @moves + 2 * (count(*) - 1 ) - 1 
		from #state  where fnum = @fnum

		update #state set fnum = @fnum + 1 where fnum = @fnum
	end
	select @moves part2
end




/* ABANDONED BRUTE FORCE METHOD
-- working out the possible moves available

insert into #state values (1, 'E','E',0) -- add elevator location

-- move one item up


select e.fnum + 1 fnum, s1.element, s1.itemtype, s1.id
from #state e
join #state s1
	on s1.fnum = e.fnum
	and s1.id <> 0
-- check moving a chip up to floor which will kill it
left join #state chipfried
	on chipfried.fnum = e.fnum + 1
	and chipfried.itemtype = 'rtg'
	and chipfried.element != s1.element
-- check moving an rtg up where it can kill something else
left join #state rtgkills
	on rtgkills.fnum = e.fnum + 1
	and rtgkills.itemtype = 'chip'
	and rtgkills.element != s1.element
-- check moving an rtg up where it leaves its chip to die
left join #state chipleft
	on chipleft.fnum = e.fnum
	and chipleft.element = s1.element
	and chipleft.itemtype = 'chip'
	and exists (select 1 from #state where fnum = e.fnum and itemtype = 'rtg' and element != s1.element)
where e.id = 0 
and (
		(s1.itemtype = 'chip' and chipfried.fnum is null)
		or
		(s1.itemtype = 'rtg' and rtgkills.fnum is null)
		or
		(s1.itemtype = 'rtg' and chipleft.fnum is null)
	)

-- */
