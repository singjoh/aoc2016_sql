USE [aoc2016]
GO

/*


*/


set nocount on


declare @a int = 0, @b int = 0, @c int = 0, @d int = 0, @delta int
declare @rown int, @maxrown int, @p1 varchar(3), @p2 varchar(3), @op varchar(3)

drop table if exists #raw
create table #raw (rown int identity(1,1), s varchar(max))

--test data
/*
insert into #raw (s)
values 
('cpy 2 a'),
('tgl a'),
('tgl a'),
('tgl a'),
('cpy 1 a'),
('dec a'),
('dec a')

/* test data for part 2
('cpy 4 a'),
('cpy 5 d'),
('cpy 2 b'),
('cpy b c'),
('inc a'),
('dec c'),
('jnz c -2'),
('dec d'),
('jnz d -5')
--*/

--*/
-- real data
--/*

insert into #raw(s)
select * from openrowset( bulk 'C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2016\day23.txt', FORMATFILE='C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2016\rawload.xml') as x

--part 1
set @a = 7
-- part 2
set @a = 12

-- */

-- part 2 optimisation
/*
cpy b c
inc a
dec c
jnz c -2
dec d
jnz d -5
-- is really
a += b * d
( and c and d both then set to 0 )

so we'll rewrite the instructions to
x_a b d
cpy 0 d
cpy 0 c - placeholder
cpy 0 c - placeholder
cpy 0 c - placeholder
cpy 0 c
( and introduce a new op x_a, which is a simplified form of mul b d a )
*/

select @rown = min(r.rown)
from #raw r
join #raw r1
	on r1.rown = r.rown + 1 and r1.s = 'inc a'
join #raw r2
	on r2.rown = r.rown + 2 and r2.s = 'dec c'
join #raw r3
	on r3.rown = r.rown + 3 and r3.s = 'jnz c -2'
join #raw r4
	on r4.rown = r.rown + 4 and r4.s = 'dec d'
join #raw r5
	on r5.rown = r.rown + 5 and r5.s = 'jnz d -5'
where r.s = 'cpy b c'

update r
set s = case rown
			when @rown then 'x_a b d'
			when @rown + 1 then 'cpy 0 d'
			else 'cpy 0 c'
		end
from #raw r
where rown between @rown and @rown + 5


drop table if exists #prog
select	rown, substring(s,1,3) as op, 
		case when substring(s,1,3) in ('jnz','cpy','x_a') then substring(s,5,charindex(' ',s,5)-5) 
			else substring(s,5,100)
			end p1,
		case when substring(s,1,3) in ('jnz','cpy','x_a') then substring(s,charindex(' ',s,5)+1,100)
			else null
			end p2
into #prog
from #raw r

select @rown = 0, @maxrown = max(rown) from #prog

declare @step int = 0 
while @rown < @maxrown
begin
	set @rown += 1
	set @step += 1

	select @op = op, @p1 = p1, @p2 = isnull(p2,'') 
	from #prog p
	where @rown = rown

	raiserror('Instruction: %i - running %s (%s, %s) on a=%i, b=%i, c=%i, d=%i', 0,0,@rown,@op,@p1,@p2, @a,@b,@c,@d) with nowait

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
		else if @p1 = 'd'
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
		else if @p2 = 'd'
			set @d = @delta
	end
	else if @op = 'tgl'
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

		update p
		set op = case op 
				when 'jnz' then 'cpy'
				when 'cpy' then 'jnz'
				when 'inc' then 'dec'
				else 'inc'
				end
		from #prog p
		where rown = @rown + @delta

	end
	else if @op = 'x_a'
	begin
		-- x_a only uses parameter register form, and only b..d are available (since a is always the target)
		if @p1 = 'b'
			set @delta = @b
		else if @p1 = 'c'
			set @delta = @c
		else if @p1 = 'd'
			set @delta = @d

		if @p2 = 'b'
			set @delta *= @b
		else if @p2 = 'c'
			set @delta *= @c
		else if @p2 = 'd'
			set @delta *= @d

		set @a += @delta

	end
	else 
	begin -- jnz

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
		begin
			if @p2 = 'a'
				set @delta = @a
			else if @p2 = 'b'
				set @delta = @b
			else if @p2 = 'c'
				set @delta = @c
			else if @p2 = 'd'
				set @delta = @d
			else
				set @delta = cast(@p2 as int)

			set @rown += @delta - 1 -- extra minus one since we move forward one step each time 


		end
	end

	if @step % 10000 = 0 raiserror('Working on step %d',0,0,@step) with nowait

end

select @a answer 
