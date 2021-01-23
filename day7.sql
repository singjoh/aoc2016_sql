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
('abba[mnop]qrst'), -- supports TLS (abba outside square brackets).
('abcd[bddb]xyyx'), -- does not support TLS (bddb is within square brackets, even though xyyx is outside square brackets).
('aaaa[qwer]tyui'), -- does not support TLS (aaaa is invalid; the interior characters must be different).
('ioxxoj[asdfgh]zxcvbn'), -- supports TLS (oxxo is outside square brackets, even though it's within a larger string). 
('rnqfzoisbqxbdlkgfh[lwlybvcsiupwnsyiljz]kmbgyaptjcsvwcltrdx[ntrpwgkrfeljpye]jxjdlgtntpljxaojufe') -- more [] sections
--*/
-- real data
insert into #raw(s)
select * from openrowset( bulk 'C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2016\day7.txt', FORMATFILE='C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2016\rawload.xml') as x

-- splitting strings into rows of table then searching for abba using lead
drop table if exists #data

select rown, row_number() over (partition by rown order by x.id, y.id) sid, y.item, case when x.id = 1 or y.id = 2 then 0 else 1 end IsHypernetSequence
into #data
from #raw r
outer apply (select * from dbo.fn_split(r.s,'[')) as x 
outer apply (select * from dbo.fn_split(x.item,']')) as y
order by rown, x.id, y.id

drop table if exists #matches

select rown, item, IsHypernetSequence, c1+c2+c3+c4 abba
into #matchesAbba
from (
	select	rown, d.item, IsHypernetSequence, x.item c1, 
			lead(x.item) over (partition by rown, sid order by x.id) c2,
			lead(x.item,2) over (partition by rown, sid order by x.id) c3,
			lead(x.item,3) over (partition by rown, sid order by x.id) c4
	from #data d
	outer apply (select * from dbo.fn_split(d.item,null)) as x
) as y
where c1 = c4 and c2 = c3 and c1 <> c2

select count (distinct a.rown) part1 
from #matchesAbba a
left join #matchesAbba hyp
	on hyp.rown = a.rown
	and hyp.IsHypernetSequence = 1
where a.IsHypernetSequence = 0
and hyp.rown is null

drop table if exists #matchesAba

select rown, item, IsHypernetSequence, c1+c2+c3 aba, c2+c1+c2 bab
into #matchesAba
from (
	select	rown, d.item, IsHypernetSequence, x.item c1, 
			lead(x.item) over (partition by rown, sid order by x.id) c2,
			lead(x.item,2) over (partition by rown, sid order by x.id) c3
	from #data d
	outer apply (select * from dbo.fn_split(d.item,null)) as x
) as y
where c1 = c3 and c1 <> c2

select count ( distinct a.rown ) part2
from #matchesAba a
join #matchesAba hyp
	on hyp.rown = a.rown
	and hyp.IsHypernetSequence = 1
	and hyp.aba = a.bab
where a.IsHypernetSequence = 0

