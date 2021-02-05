USE [aoc2016]
GO

/*


*/
set nocount on

declare @input varchar(max)
declare @mxrow int

-- test data
set @input = '.^^.^.^^^^'
set @mxrow = 10

-- puzzle imput
set @input = '...^^^^^..^...^...^^^^^^...^.^^^.^.^.^^.^^^.....^.^^^...^^^^^^.....^.^^...^^^^^...^.^^^.^^......^^^^'
set @mxrow = 400000

declare @row int
declare @mxc int
declare @c int 

-- part1 commented out
/* 
drop table if exists #rows

select 1 y, id x, case item when '^' then 1 else 0 end isTrap 
into #rows
from dbo.fn_split(@input,null)

create index i_yx on #rows(y,x)

set @row = 1
while @row < @mxrow
begin
	set @row += 1 

	insert into #rows
	select @row, x,
		case when isnull(lag(istrap) over (partition by y order by x),0) + isnull(lead(istrap) over (partition by y order by x),0) = 1 
				then 1
				else 0
				end
	from #rows
	where y = @row -1

end

-- part 1, simple count
select count(*) part1 from #rows where istrap = 0

-- */

-- part 2, 
-- meh, this is too slow (100k in 11 minutes), and testing to see if the pattern repeats doesn't trigger in the first 100k rows, so assume it doesn't.

declare @output varchar(max)
declare @safe int = 0


set @row = 1
set @mxc = len(@input)

-- row 1 safe
set @c = 0
while @c < @mxc
begin
	set @c += 1
	if substring(@input,@c,1) = '.'
		set @safe += 1
end

while @row < @mxrow
begin
	set @c = 0
	set @row += 1
	set @output = ''
	while @c < @mxc
	begin
		set @c += 1
		if substring('.' + @input + '.',@c,3) in ('^..','^^.','.^^','..^')
			set @output += '^'
		else
		begin
			set @output += '.'
			set @safe += 1
		end
	end

	-- test visualisation
	-- raiserror(@output,0,0) with nowait
	set @input = @output

	if @row % 1000 = 0 
	raiserror('Working on %i',0,0,@row)
end

select @safe part2