USE [aoc2016]
GO

/*


*/
set nocount on


declare @input varchar(max)

set @input = 
-- 'abc'
 'zpqevtbw'



drop table if exists #hashes
drop table if exists #matches
drop table if exists #seq

select x.item x, replicate(x.item,5) x5, replicate(x.item,3) x3
into #seq
from dbo.fn_split('abcdefghijklmnopqrstuvwxyz0123456789',null) as x

-- storing the hashes with 5 items ..
-- 10,000 produces 51 (using abc seed), probably not enough for 64 keys
-- 100,000 produces 437 items, still not enough for 6 keys



/* Part 1 
	; WITH E1(N)        AS ( SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
							 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
							 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1),
		   E2(N)        AS (SELECT 1 FROM E1 a, E1 b),
		   E4(N)        AS (SELECT 1 FROM E2 a, E2 b),
		   En(N)       AS (SELECT 1 FROM E4 a, E1 b), 
		   cteTally(N)  AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM En)
	select n, x, hashstr, case when incx5 > 0 then 1 else 0 end match5
	into #hashes
	from (
		select n, lower(convert(varchar(32), HashBytes('MD5',  @input + cast(n as varchar)), 2)) hashstr
		from cteTally
		) as x
	cross join #seq
	outer apply (select charindex(x5,hashstr) incx5, charindex(x3,hashstr) incx3) as y
	where incx3 > 0 
-- */
; WITH E1(N)        AS ( SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
							UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
							UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1),
		E2(N)        AS (SELECT 1 FROM E1 a, E1 b),
		E4(N)        AS (SELECT 1 FROM E2 a, E2 b),
		En(N)       AS (SELECT 1 FROM E4 a, E1 b), 
		cteTally(N)  AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM En),
		cteHashes as
			(	select n-1 n, 1 hashes, lower(convert(varchar(32), HashBytes('MD5',  @input + cast(n-1 as varchar)), 2)) hashstr from cteTally
				union all
				select n, hashes+1, lower(convert(varchar(32), HashBytes('MD5',  hashstr), 2)) from cteHashes
					where hashes < 2017
					) 
select n, x, hashstr, case when incx5 > 0 then 1 else 0 end match5
into #hashes
from cteHashes h
cross join #seq
outer apply (select charindex(x5,hashstr) incx5, charindex(x3,hashstr) incx3) as y
where h.hashes = 2017 
and incx3 > 0 
option (maxrecursion 0)


select h5.n x5n, h3.n x3n, h5.x, ROW_NUMBER() over (order by h3.n) n, h3.hashstr hash3, incx3 x3_match_charindex
into #matches
from #hashes h5
join #hashes h3
	on h3.n between h5.n - 1000 and h5.n - 1
outer apply (select charindex(REPLICATE(h5.x,3),h3.hashstr) incx3) as y
where h5.match5 = 1
and incx3 > 0 

-- get rid of items where the matched triplet is not the first available triplet in the string
delete m
from #matches m
outer apply (
	select min(c) mnc
	from #seq s
	outer apply (select charindex(s.x3,hash3) c) as x
	where c > 0
	) as y
where x3_match_charindex <> mnc

-- get rid of duplicates (a triplet matches two 5 in the next 1000)
delete foo
from #matches foo
join #matches bar
	on bar.x3n = foo.x3n
	and bar.n < foo.n

-- update the index
update foo
set n = bar.n
from #matches foo
join (select x3n, ROW_NUMBER() over (order by x3n) n from #matches) bar
	on bar.x3n = foo.x3n

select x3n part1 from #matches where n = 64



/*

; WITH E1(N)        AS ( SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                         UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                         UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1),
       E2(N)        AS (SELECT 1 FROM E1 a, E1 b),
       E4(N)        AS (SELECT 1 FROM E2 a, E2 b),
       En(N)       AS (SELECT 1 FROM E4 a, E1 b), 
       cteTally(N)  AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM En),
	   cteHashes as
		(	select n-1 n, 1 hashes, lower(convert(varchar(32), HashBytes('MD5',  'abc' + cast(n-1 as varchar)), 2)) hashstr from cteTally
				where n < 10
			union all
			select n, hashes+1, lower(convert(varchar(32), HashBytes('MD5',  hashstr), 2)) from cteHashes
				where hashes < 2017
				) 
select * from cteHashes h
where h.hashes = 2017
order by n, hashes
option (maxrecursion 0)
*/