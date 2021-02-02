USE [aoc2016]
GO

/*


*/
set nocount on

declare @input varchar(max) = 'dmypynyp'

drop table if exists #dirs
select * into #dirs
from (
		select 0 dx, -1 dy, 1 cindex	-- Up 
		union select 0, 1, 2	-- Down
		union select -1, 0, 3	-- Left
		union select 1, 0, 4	-- Righ
	) as x

;with cte_path as (
	select 1 + dx x, 1 + dy y, cast(substring('UDLR',cindex,1) as varchar(max)) as path, 1 as pathlen
	from
		(select convert(varchar(32), HashBytes('MD5',  @input), 2) hashstr) as x
	cross join #dirs as d
	where 
		1 + dx between 1 and 4
	and 1 + dy between 1 and 4
	and SUBSTRING(hashstr,cindex,1) in ('B','C','D','E','F')
	union all
	select p.x + dx x, p.y + dy y, p.path + substring('UDLR',cindex,1), p.pathlen + 1
	from cte_path p
	outer apply (select convert(varchar(32), HashBytes('MD5',  @input + p.path), 2) hashstr) as x
	cross join #dirs as d
	where 
		p.x + dx between 1 and 4
	and p.y + dy between 1 and 4
	and SUBSTRING(hashstr,cindex,1) in ('B','C','D','E','F')
	and not (p.x = 4 and p.y = 4)
	) 
	select * from cte_path
	where x = 4 and y = 4
	order by pathlen
	option (maxrecursion 0)

	-- row 1 path = part 1
	-- last row pathlen = part 2