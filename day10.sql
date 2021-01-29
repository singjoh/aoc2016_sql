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
('ADVENT'), -- contains no markers and decompresses to itself with no changes, resulting in a decompressed length of 6.
('A(1x5)BC'), -- repeats only the B a total of 5 times, becoming ABBBBBC for a decompressed length of 7.
('(3x3)XYZ'), -- becomes XYZXYZXYZ for a decompressed length of 9.
('A(2x2)BCD(2x2)EFG'), -- doubles the BC and EF, becoming ABCBCDEFEFG for a decompressed length of 11.
('(6x1)(1x3)A'), -- simply becomes (1x3)A - the (1x3) looks like a marker, but because it's within a data section of another marker, it is not treated any differently from the A that comes after it. It has a decompressed length of 6.
('X(8x2)(3x3)ABCY'), 
('(27x12)(20x12)(13x14)(7x10)(1x12)A'), -- decompresses into a string of A repeated 241920 times.
('(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN') -- becomes 445 characters long.
--*/
-- real data
--/*
insert into #raw(s)
select * from openrowset( bulk 'C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2016\day9.txt', SINGLE_CLOB) as x

-- */

drop table if exists #rawdata
drop table if exists #data


select	rown, s, row_number() over (partition by rown order by x.id) sectionid,
	case 
		when x.id = 1 then x.item
		else substring(x.item,y.cb+1,4000)
			end chars,
	case 
		when x.id = 1 then cast(null as int)
		else cast(substring(x.item,1,y.x-1) as int)
			end lhs,
	case 
		when x.id = 1 then cast(null as int)
		else cast(substring(x.item,y.x+1,y.cb-y.x-1)as int)
			end rhs
into #rawdata
from #raw r
outer apply (select * from dbo.fn_split(r.s,'(')) as x 
outer apply (select CHARINDEX(')',x.item) cb, CHARINDEX('x',x.item) x) as y

select	rown, s, row_number() over (partition by rown order by sectionid, x.n) sectionid,
		case
			when lhs is null then chars 
			else case
				when x.n = 1 then '(' + cast(lhs as varchar) + 'x' + cast(rhs as varchar) + ')' 
				else chars
			end
		end as chars,
		case when x.n = 1 then lhs else null end lhs, case when x.n = 1 then rhs else null end rhs
into #data
from #rawdata d
cross join (select 1 n union select 2) as x
where (x.n = 1 or lhs is not null and len(chars) > 0)

declare @rown int, @sectionid int, @chars varchar(max), @lhs int, @rhs int
declare @maxrown int, @maxsectionid int, @string varchar(max), @repeatsection varchar(max)
declare @repeat int -- = 1 when grabbing chars to repear

set @rown = 1

if 1 = 0 
begin -- part1
	select @maxsectionid = max(sectionid), @sectionid = 0 from #data where rown = @rown

	set @string = ''
	set @repeat = 0

	while @sectionid < @maxsectionid
	begin
		set @sectionid += 1
		if @repeat = 0
		begin
			select @chars = chars, @lhs = lhs, @rhs = rhs from #data where rown = @rown and sectionid = @sectionid
			if @lhs is null
				set @string += @chars
			else
			begin
				set @repeat = 1
				set @repeatsection = ''
			end
		end
		else
		begin
			select @chars = chars from #data where rown = @rown and sectionid = @sectionid
			set @repeatsection += @chars
			if len(@repeatsection) > @lhs
			begin
				set @chars = SUBSTRING(@repeatsection,@lhs+1,4000)
				set @repeatsection = SUBSTRING(@repeatsection,1,@lhs)
			end
			else
				set @chars = ''

			if len(@repeatsection) = @lhs
			begin
				set @string += replicate(@repeatsection,@rhs)
				set @repeat = 0
				set @string += @chars
			end

		end

	end

	select len(@string) part1
end -- part 1

set @rown = 1

declare @l int, @cuml int, @copies bigint

if 1=1
begin -- part 2
	drop table if exists #data2

	select row_number() over (order by sectionid, charid) sectionid, lhs, rhs, l, sum(l) over (order by sectionid, charid) as cuml, cast(1 as bigint) as copies
	into #data2
	from (
		select sectionid, isnull(x.id,1) charid, lhs, rhs, case when lhs is null then 1 else len(chars) end l
		from #data d
		outer apply (select * from dbo.fn_split(case when lhs is null then chars else '' end,null)) as x
		where rown = @rown
		) as x

	select @maxsectionid = max(sectionid), @sectionid = 0 from #data2

	while @sectionid < @maxsectionid
	begin
		set @sectionid += 1

		select @lhs = lhs, @rhs = rhs, @l = l, @cuml = cuml, @copies = copies from #data2 where sectionid = @sectionid
		if @lhs is not null
			update x
			set copies = x.copies * @rhs
			from #data2 x
			where cuml between @cuml + 1 and @cuml + @lhs

		-- select @sectionid, @cuml + 1, @cuml + @lhs, * from #data2
	end

	-- select * from #data2
	select sum(copies) part2 from #data2 where lhs is null 
end
--241920