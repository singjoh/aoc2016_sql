USE [aoc2016]
GO

/*


*/


set nocount on



drop table if exists #raw
create table #raw (s varchar(8000))

--test data
declare @input varchar(max)

set nocount on

set @input = 
-- 'abc'
 'ugkcyxxp'



drop table if exists #hashes

-- part 1 needed 9973527 to find the last hash
-- so try 100,000,000 items and just collect the hashes that are 00000n (and hope that's enough)
; WITH E1(N)        AS ( SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                         UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                         UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1),
       E2(N)        AS (SELECT 1 FROM E1 a, E1 b),
       E4(N)        AS (SELECT 1 FROM E2 a, E2 b),
       E44(N)       AS (SELECT 1 FROM E4 a, E4 b), -- 100,000,000
       cteTally(N)  AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E44)
select * 
into #hashes
from (
	select n, convert(varchar(32), HashBytes('MD5',  @input + cast(n as varchar)), 2) hashstr
	from cteTally
	) as x
where left(hashstr,5) = '00000'
order by n

-- require lowercase hashes
update #hashes
set hashstr = lower(hashstr)

declare @part1 varchar(8) = ''

select top 8 @part1 = @part1 + substring(hashstr,6,1)
from #hashes
order by n

select @part1

declare @part2 varchar(8) = ''

select @part2 = @part2 + val
from (
	select idx, n, val, row_number() over (partition by idx order by n) rown
	from (
		select n, substring(hashstr,6,1) idx, substring(hashstr,7,1) val
		from #hashes
	) as x
	where charindex(idx,'01234567') > 0
) as y
where rown = 1

select @part2

