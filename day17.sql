USE [aoc2016]
GO

/*


*/
set nocount on

declare @input varchar(max) = '00101000101111010'
declare @disksize int = 272

-- Part 2 35651584
-- Well, it *would* work on my machine, time and memory permitting, but went for python for part

/* -- test data
set @input = '10000'
set @disksize = 20
*/ 


drop table if exists #data
select id, cast(item as int) c
into #data
from dbo.fn_split(@input,null) as x

create index i_d on #data (id)

declare @checksum varchar(max) = ''
declare @mxid int

-- expand data
while 1=1
begin

	insert into #data
		select 2 * (mxid + 1) - id, 1 - c 
		from #data d
		cross join (select max(id) mxid from #data) x
	union 
		select max(id) + 1, 0 from #data

	set @checksum = ''

	select @mxid = max(id) from #data

	select @checksum = @checksum + cast(c as varchar) from #data order by id
	raiserror('Filled Disk: (%i) %s',0,0,@mxid, @checksum) with nowait

	if @mxid >= @disksize break

end

-- trim to disk szie
delete from #data where id > @disksize

while 1 = 1
begin

	-- odd count, break
	if (select max(id) from #data) % 2 = 1 break

	-- update odd items
	update d
	set c = y.c
	from #data d
	join (
		select id, case when c = leadc then 1 else 0 end c
		from (
			select id, c, LEAD(c) over (order by id) leadc
			from #data ) as x
		where id % 2 = 1
		) as y
		on y.id = d.id

	-- delete even items
	delete #data where id % 2 = 0

	-- squash the id
	update #data set id = (id + 1) / 2

	set @checksum = ''
	select @checksum = @checksum + cast(c as varchar) from #data order by id
	raiserror('Generating Checksum: %s',0,0,@checksum)


end

set @checksum = ''
select @checksum = @checksum + cast(c as varchar) from #data order by id
select @checksum part1	