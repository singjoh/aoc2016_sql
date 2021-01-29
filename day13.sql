USE [aoc2016]
GO

/*

-- Int2binary, 3 byte integer
CREATE FUNCTION dbo.Int2Binary (@i INT) RETURNS NVARCHAR(24) AS BEGIN
    RETURN
        CASE WHEN CONVERT(VARCHAR(16), @i & 8388608 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(VARCHAR(16), @i & 4194304 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(VARCHAR(16), @i & 2097152 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(VARCHAR(16), @i & 1048576 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(VARCHAR(16), @i & 524288 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(VARCHAR(16), @i & 262144 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(VARCHAR(16), @i & 131072 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(VARCHAR(16), @i & 65536 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(VARCHAR(16), @i & 32768 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(VARCHAR(16), @i & 16384 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(VARCHAR(16), @i &  8192 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(VARCHAR(16), @i &  4096 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(VARCHAR(16), @i &  2048 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(VARCHAR(16), @i &  1024 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(VARCHAR(16), @i &   512 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(VARCHAR(16), @i &   256 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(VARCHAR(16), @i &   128 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(VARCHAR(16), @i &    64 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(VARCHAR(16), @i &    32 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(VARCHAR(16), @i &    16 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(VARCHAR(16), @i &     8 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(VARCHAR(16), @i &     4 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(VARCHAR(16), @i &     2 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(VARCHAR(16), @i &     1 ) > 0 THEN '1' ELSE '0'   END
END;

CREATE FUNCTION dbo.BinaryBitsSet (@i INT) RETURNS INT AS BEGIN
    RETURN
        CASE WHEN CONVERT(VARCHAR(16), @i & 8388608 ) > 0 THEN 1 ELSE 0   END +
        CASE WHEN CONVERT(VARCHAR(16), @i & 4194304 ) > 0 THEN 1 ELSE 0   END +
        CASE WHEN CONVERT(VARCHAR(16), @i & 2097152 ) > 0 THEN 1 ELSE 0   END +
        CASE WHEN CONVERT(VARCHAR(16), @i & 1048576 ) > 0 THEN 1 ELSE 0   END +
        CASE WHEN CONVERT(VARCHAR(16), @i & 524288 ) > 0 THEN 1 ELSE 0   END +
        CASE WHEN CONVERT(VARCHAR(16), @i & 262144 ) > 0 THEN 1 ELSE 0   END +
        CASE WHEN CONVERT(VARCHAR(16), @i & 131072 ) > 0 THEN 1 ELSE 0   END +
        CASE WHEN CONVERT(VARCHAR(16), @i & 65536 ) > 0 THEN 1 ELSE 0   END +
        CASE WHEN CONVERT(VARCHAR(16), @i & 32768 ) > 0 THEN 1 ELSE 0   END +
        CASE WHEN CONVERT(VARCHAR(16), @i & 16384 ) > 0 THEN 1 ELSE 0   END +
        CASE WHEN CONVERT(VARCHAR(16), @i &  8192 ) > 0 THEN 1 ELSE 0   END +
        CASE WHEN CONVERT(VARCHAR(16), @i &  4096 ) > 0 THEN 1 ELSE 0   END +
        CASE WHEN CONVERT(VARCHAR(16), @i &  2048 ) > 0 THEN 1 ELSE 0   END +
        CASE WHEN CONVERT(VARCHAR(16), @i &  1024 ) > 0 THEN 1 ELSE 0   END +
        CASE WHEN CONVERT(VARCHAR(16), @i &   512 ) > 0 THEN 1 ELSE 0   END +
        CASE WHEN CONVERT(VARCHAR(16), @i &   256 ) > 0 THEN 1 ELSE 0   END +
        CASE WHEN CONVERT(VARCHAR(16), @i &   128 ) > 0 THEN 1 ELSE 0   END +
        CASE WHEN CONVERT(VARCHAR(16), @i &    64 ) > 0 THEN 1 ELSE 0   END +
        CASE WHEN CONVERT(VARCHAR(16), @i &    32 ) > 0 THEN 1 ELSE 0   END +
        CASE WHEN CONVERT(VARCHAR(16), @i &    16 ) > 0 THEN 1 ELSE 0   END +
        CASE WHEN CONVERT(VARCHAR(16), @i &     8 ) > 0 THEN 1 ELSE 0   END +
        CASE WHEN CONVERT(VARCHAR(16), @i &     4 ) > 0 THEN 1 ELSE 0   END +
        CASE WHEN CONVERT(VARCHAR(16), @i &     2 ) > 0 THEN 1 ELSE 0   END +
        CASE WHEN CONVERT(VARCHAR(16), @i &     1 ) > 0 THEN 1 ELSE 0   END 

END;

CREATE FUNCTION dbo.day13_Wall(@x INT, @y INT, @seed INT) RETURNS INT AS BEGIN
	declare @work int
	declare @result int
	set @work = @x*@x + 3*@x + 2*@x*@y + @y + @y*@y + @seed
	set @work = dbo.BinaryBitsSet(@work)
	if @work % 2 = 1
		set @result = 1
	else
		set @result = 0

	return @result
END

*/
set nocount on

declare @seed int = 1352
declare @x int = 0
declare @y int = 0
declare @p int = 0

-- testing the 'IsWall function'
/*
drop table if exists #grid
create table #grid(x int,y int,isOn bit)

while @x < 10
begin
	set @y = 0
	while @y < 10
	begin
		if dbo.day13_Wall(@x,@y,@seed) = 1
			insert into #grid
			values (@x,@y,1)
		else
			insert into #grid
			values (@x,@y,0)

		set @y += 1
	end
	set @x += 1
end


declare @displine varchar(max)
set @y = 0
while @y < 10
begin
	set @displine = ''

	-- '+' and ' ' are roughly the same size in dispalys, so use '+' for on and ' ' for off

	select @displine = @displine + case when isOn = 1 then '+' else ' ' end
	from #grid
	where y = @y
	order by x

	print @displine
	set @y += 1
end

*/


drop table if exists #seen
create table #seen(x int,y int,pathlen int)

-- init
set @x = 1
set @y = 1
set @p = 0
insert into #seen values(@x,@y,@p)

while 1 = 1
begin

	insert into #seen
	select distinct n.x, n.y, @p+1
	from #seen s
	cross join (select -1 x, 0 y union select 0,-1 union select 1,0 union select 0,1) as d
	outer apply (select s.x + d.x x, s.y + d.y y) as n
	outer apply (select dbo.day13_Wall(n.x,n.y,@seed) IsWall) as w
	left join #seen s1
		on s1.x = n.x
		and s1.y = n.y
	where s.pathlen = @p
	and s1.x is null
	and n.x >= 0
	and n.y >= 0
	and w.IsWall = 0

	if exists (select 1 from #seen where x=31 and y=39) break

	set @p += 1
end

select pathlen part1 from #seen where x=31 and y=39

select count(*) part2 from #seen where pathlen <= 50
