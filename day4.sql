USE [aoc2016]
GO

/*


*/


set nocount on



drop table if exists #raw
create table #raw (s varchar(8000))

--test data
/*
insert into #raw 
values 
('aaaaa-bbb-z-y-x-123[abxyz]'), -- is a real room because the most common letters are a (5), b (3), and then a tie between x, y, and z, which are listed alphabetically.
('a-b-c-d-e-f-g-h-987[abcde]'), -- is a real room because although the letters are all tied (1 of each), the first five are listed alphabetically.
('not-a-real-room-404[oarel]'), -- is a real room.
('totally-real-room-200[decoy]') -- is not
--*/
-- real data
bulk insert #raw from 'C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2016\day4.txt'

drop table if exists #meta

;with cte_raw(rown,s) as
	(select row_number() over (order by (select null)) as rown, isnull(s,'')
	from #raw)
select rown, cast(left(item,charindex('[',item)-1) as int) sectorid, substring(item,charindex('[',item)+1,5) as checksm, chars
into #meta
from (
	select rown, id, item, lead(id) over (partition by rown order by id) as nid,substring(s,1,len(s) - len(item) -1) chars
	from cte_raw r
	outer apply (select * from dbo.fn_split(r.s,'-')) as x 
	) as y
where nid is null


drop table if exists #real

select row_number() over (order by m.rown) rown, m.sectorid, m.chars, cast(null as varchar(max)) as translated
into #real 
from (
	select	rown, sectorid, checksm, 
			lag(sectorid) over (partition by rown, sectorid order by c desc, item) as nid, 
			item
			+ lead(item,1) over (partition by rown, sectorid order by c desc, item)
			+ lead(item,2) over (partition by rown, sectorid order by c desc, item)
			+ lead(item,3) over (partition by rown, sectorid order by c desc, item)
			+ lead(item,4) over (partition by rown, sectorid order by c desc, item) as sm
	from (
		select rown, sectorid, checksm, item, count(*) c
		from #meta m
		outer apply (select * from dbo.fn_split(m.chars,null)) as x
		where item <> '-'
		group by rown, sectorid, checksm, item
		) as x
	) as y
join #meta m
	on m.rown = y.rown
where nid is null -- first item from a group  (c desc, char asc)
and y.checksm = y.sm

declare @sumsectorid int = 0

select @sumsectorid = @sumsectorid + sectorid
from #real r

select @sumsectorid part1

declare @alphabet varchar(26) = 'abcdefghijklmnopqrstuvwxyz'
declare @translated varchar(max)
declare @rown int, @maxrown int

select @rown = 0, @maxrown=max(rown) from #real
while @rown < @maxrown
begin
	set @rown += 1
	set @translated = ''

	select @translated = @translated + case when x.item = '-' then ' ' else y.c end 
	from #real m
	outer apply (select * from dbo.fn_split(m.chars,null)) as x
	outer apply (select substring(@alphabet,(charindex(x.item,@alphabet) + sectorid) % 26,1) c) as y
	where rown = @rown

	update #real
	set translated = @translated
	where rown = @rown
end

select * from #real 
where translated like '%north%'
order by translated

