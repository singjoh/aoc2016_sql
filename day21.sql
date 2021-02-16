USE [aoc2016]
GO

/*


*/
set nocount on
set nocount on



drop table if exists #raw
create table #raw (rown int identity(1,1), s varchar(max))

declare @string varchar(max)


--test data
/*
insert into #raw (s)
values 
('swap position 4 with position 0'), -- swaps the first and last letters, producing the input for the next step, ebcda.
('swap letter d with letter b'), --  swaps the positions of d and b: edcba.
('reverse positions 0 through 4'), --  causes the entire string to be reversed, producing abcde.
('rotate left 1 step'), --  shifts all letters left one position, causing the first letter to wrap to the end of the string: bcdea.
('move position 1 to position 4'), --  removes the letter at position 1 (c), then inserts it at position 4 (the end of the string): bdeac.
('move position 3 to position 0'), --  removes the letter at position 3 (a), then inserts it at position 0 (the front of the string): abdec.
('rotate based on position of letter b'), --  finds the index of letter b (1), then rotates the string right once plus a number of times equal to that index (2): ecabd.
('rotate based on position of letter d') --  finds the index of letter d (4), then rotates the string right once, plus a number of times equal to that index, plus an additional time because the index was at least 4, for a total of 6 right rotations: decab.
-- and also rotate right n step

set @string = 'abcde' 

-- */
-- real data
--/*
insert into #raw(s)
select * from openrowset( bulk 'C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2016\day21.txt', formatfile = 'C:\Users\john_\OneDrive\Documents\SQL Server Management Studio\Aoc2016\rawload.xml' ) as x


declare @part1 int = 0
if @part1 = 1
	set @string = 'abcdefgh' 
else
	set @string = 'fbgdceah' 

-- */

drop table if exists #rules

select	rown, 
		case SUBSTRING(s,1,8) -- op can be derived from 8 chars
		when 'swap pos' then 'SWP'
		when 'swap let' then 'SWL'
		when 'reverse ' then 'REV'
		when 'rotate l' then 'ROL'
		when 'rotate r' then 'ROR'
		when 'rotate b' then 'ROB'
		when 'move pos' then 'MVP'
		else null end op,

		case SUBSTRING(s,1,8) 
		when 'swap pos' then SUBSTRING(s,15,1)
		when 'swap let' then SUBSTRING(s,13,1)
		when 'reverse ' then SUBSTRING(s,19,1)
		when 'rotate l' then SUBSTRING(s,13,1)
		when 'rotate r' then SUBSTRING(s,14,1)
		when 'rotate b' then SUBSTRING(s,36,1)
		when 'move pos' then SUBSTRING(s,15,1)
		else null end p1,

		case SUBSTRING(s,1,8) 
		when 'swap pos' then SUBSTRING(s,31,1)
		when 'swap let' then SUBSTRING(s,27,1)
		when 'reverse ' then SUBSTRING(s,29,1)
		when 'rotate l' then ''
		when 'rotate r' then ''
		when 'rotate b' then ''
		when 'move pos' then SUBSTRING(s,29,1)
		else null end p2
into #rules
from #raw

drop table if exists #chars
select id-1 id, item c into #chars from dbo.fn_split(@string,null)

declare @rown int = 0
declare @maxrown int
declare @op varchar(3)
declare @p1 varchar(1)
declare @p2 varchar(1)
declare @pn1 int
declare @pn2 int

declare @work varchar(1)
declare @len int = len(@string)


select @maxrown = max(rown) from #rules

if @part1 = 1
while @rown < @maxrown
begin

	set @rown += 1

	select	@op = op, @p1 = p1, @p2 = p2,
			@pn1 = case when op in ('SWL','ROB') then null else cast (p1 as int) end,
			@pn2 = case when op in ('SWP','REV','MVP') then cast (p2 as int) else null end
	from #rules where rown = @rown

	if @op = 'SWP'
		update foo
		set id = case when id = @pn1 then @pn2 else @pn1 end
		from #chars foo
		where foo.id in (@pn1,@pn2)
	else if @op = 'SWL'
		update foo
		set c = case when c = @p1 then @p2 else @p1 end
		from #chars foo
		where foo.c in (@p1,@p2)
	else if @op = 'REV'
		update foo
		set id = @pn2 + @pn1 - id 
		from #chars foo
		where foo.id between @pn1 and @pn2
	else if @op = 'ROL'
		update foo
		set id = (@len + (id - @pn1)) % @len
		from #chars foo
	else if @op = 'ROR'
		update foo
		set id = (id + @pn1) % @len
		from #chars foo
	else if @op = 'MVP'
		if @pn2 > @pn1
			update foo
			set id = case when id = @pn1 then @pn2
						else id - 1 end
			from #chars foo
			where id between @pn1 and @pn2
		else
			update foo
			set id = case when id = @pn1 then @pn2
						else id + 1 end
			from #chars foo
			where id between @pn2 and @pn1
	else if @op = 'ROB'
		update foo
		set id = (foo.id + 1 + bar.id + case when bar.id >= 4 then 1 else 0 end ) % @len
		from #chars foo
		join #chars bar 
			on bar.c = @p1


	set @string = ''
	select @string = @string + c from #chars order by id
	raiserror('Step %i, %s (%s, %s): %s',0,0,@rown, @op, @p1, @p2, @string) with nowait


end


set @rown = @maxrown + 1

if @part1 = 0
while @rown > 1
begin

	set @rown -= 1

	select	@op = op, @p1 = p1, @p2 = p2,
			@pn1 = case when op in ('SWL','ROB') then null else cast (p1 as int) end,
			@pn2 = case when op in ('SWP','REV','MVP') then cast (p2 as int) else null end
	from #rules where rown = @rown

	-- part 2 needs 'inverse rules'
	-- SWP/SWL unchanged
	-- REV unchanged
	-- ROL/ROR swap direction
	-- MVP swap params
	-- ROB (see details below)

	if @op = 'SWP'
		update foo
		set id = case when id = @pn1 then @pn2 else @pn1 end
		from #chars foo
		where foo.id in (@pn1,@pn2)
	else if @op = 'SWL'
		update foo
		set c = case when c = @p1 then @p2 else @p1 end
		from #chars foo
		where foo.c in (@p1,@p2)
	else if @op = 'REV'
		update foo
		set id = @pn2 + @pn1 - id 
		from #chars foo
		where foo.id between @pn1 and @pn2
	else if @op = 'ROR'
		update foo
		set id = (@len + (id - @pn1)) % @len
		from #chars foo
	else if @op = 'ROL'
		update foo
		set id = (id + @pn1) % @len
		from #chars foo
	else if @op = 'MVP'


		if @pn2 > @pn1
			update foo
			set id = case when id = @pn2 then @pn1
						else id + 1 end
			from #chars foo
			where id between @pn1 and @pn2
		else
			update foo
			set id = case when id = @pn2 then @pn1
						else id - 1 end
			from #chars foo
			where id between @pn2 and @pn1
	else if @op = 'ROB'
	begin
	/*
	ROB action on string of length 8 is invertible (on 5 chars is not, so that was a lot of wasted time :) )    
	    # pos shift newpos
        #   0     1      1
        #   1     2      3
        #   2     3      5
        #   3     4      7
        #   4     6      2
        #   5     7      4
        #   6     8      6
        #   7     9      0

        # all odds have a clear pattern, all evens have a clear pattern...
        # except 0, which we'll just special-case.

	
		*/
		-- Thus .. find shift from current
		select @pn1 = 
			case	when id = 0 then 9
					when id % 2 = 0 then 5 + (id / 2) 
					else 1 + (id - 1) / 2
			end
		from #chars
		where c = @p1

		-- And a rotate left by that amount
		update foo
		set id = (@len + (id - @pn1)) % @len
		from #chars foo

	end

	set @string = ''
	select @string = @string + c from #chars order by id
	raiserror('Step %i, %s (%s, %s): %s',0,0,@rown, @op, @p1, @p2, @string) with nowait


end

select @string part1_2

