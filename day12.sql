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
('cpy 41 a'),
('inc a'),
('inc a'),
('dec a'),
('jnz a 2'),
('dec a')
--*/
-- real data
--/*

insert into #raw(s)
select * from openrowset( bulk 'C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2016\day12.txt', FORMATFILE='C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2016\rawload.xml') as x

-- */

drop table if exists #prog
select	rown, substring(s,1,3) as op, 
		case when substring(s,1,3) in ('jnz','cpy') then substring(s,5,charindex(' ',s,5)-5) 
			else substring(s,5,100)
			end p1,
		case when substring(s,1,3) in ('jnz','cpy') then substring(s,charindex(' ',s,5)+1,100)
			else null
			end p2
into #prog
from #raw r

drop table if exists #reg
create table #reg(reg varchar(1), value int)
insert into #reg 
select item, 0 from dbo.fn_split('abcd',null)

declare @rown int, @maxrown int, @p1 varchar(2), @p2 varchar(2), @op varchar(3)
declare @a int = 0, @b int = 0, @c int = 0, @d int = 0, @delta int

select @rown = 0, @maxrown = max(rown) from #prog

-- part 2
set @c = 1

declare @step int = 0 
while @rown < @maxrown
begin
	set @rown += 1
	set @step += 1

	select @op = op, @p1 = p1, @p2 = p2 
	from #prog p
	where @rown = rown

	if @op in ('inc','dec')
	begin
		if @op = 'inc'
			set @delta = 1
		else
			set @delta = -1

		if @p1 = 'a'
			set @a += @delta
		else if @p1 = 'b'
			set @b += @delta
		else if @p1 = 'c'
			set @c += @delta
		else 
			set @d += @delta
	end
	else if @op = 'cpy'
	begin
		if @p1 = 'a'
			set @delta = @a
		else if @p1 = 'b'
			set @delta = @b
		else if @p1 = 'c'
			set @delta = @c
		else if @p1 = 'd'
			set @delta = @d
		else
			set @delta = cast(@p1 as int)

		if @p2 = 'a'
			set @a = @delta
		else if @p2 = 'b'
			set @b = @delta
		else if @p2 = 'c'
			set @c = @delta
		else 
			set @d = @delta
	end
	else 
	begin

		if @p1 = 'a'
			set @delta = @a
		else if @p1 = 'b'
			set @delta = @b
		else if @p1 = 'c'
			set @delta = @c
		else if @p1 = 'd'
			set @delta = @d
		else
			set @delta = cast(@p1 as int)

		if @delta <> 0 
			set @rown += cast(@p2 as int) - 1 -- extra minus one since we move forward one step each time 

	end

	if @step % 10000 = 0 raiserror('Working on step %d',0,0,@step) with nowait

end
-- 25 minutes, 12,268,000


select @a answer 
