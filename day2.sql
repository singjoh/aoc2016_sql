USE [aoc2016]
GO

/*
create database aoc2016


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_split]
(
   @List NVARCHAR(MAX),
   @Delimiter NVARCHAR(255)
)
RETURNS TABLE
WITH SCHEMABINDING AS
RETURN
  WITH E1(N)        AS ( SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                         UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                         UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1),
       E2(N)        AS (SELECT 1 FROM E1 a, E1 b),
       E4(N)        AS (SELECT 1 FROM E2 a, E2 b),
       E42(N)       AS (SELECT 1 FROM E4 a, E2 b),
       cteTally(N)  AS (SELECT 0 UNION ALL SELECT TOP (LEN(ISNULL(@List,1))) 
                         ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E42),
       cteStart(N1) AS (SELECT t.N+1 FROM cteTally t
                         WHERE (SUBSTRING(@List,t.N,1) = @Delimiter OR t.N = 0 OR @Delimiter IS NULL))
  SELECT ID, Item
  FROM
	(
  SELECT	Id = ROW_NUMBER() OVER (ORDER BY ((SELECT NULL))), 
			Item = SUBSTRING(@List, s.N1, CASE WHEN @Delimiter IS NULL THEN 1 ELSE ISNULL(NULLIF(CHARINDEX(@Delimiter,@List,s.N1),0)-s.N1,8000) END)
    FROM cteStart s
	) as x
	WHERE len(Item) > 0
GO


*/

declare @input varchar(max)

set nocount on

set @input = 
--	'R5, L5, R5, R3'
-- 'R8, R4, R4, R8'
 'L5, R1, L5, L1, R5, R1, R1, L4, L1, L3, R2, R4, L4, L1, L1, R2, R4, R3, L1, R4, L4, L5, L4, R4, L5, R1, R5, L2, R1, R3, L2, L4, L4, R1, L192, R5, R1, R4, L5, L4, R5, L1, L1, R48, R5, R5, L2, R4, R4, R1, R3, L1, L4, L5, R1, L4, L2, L5, R5, L2, R74, R4, L1, R188, R5, L4, L2, R5, R2, L4, R4, R3, R3, R2, R1, L3, L2, L5, L5, L2, L1, R1, R5, R4, L3, R5, L1, L3, R4, L1, L3, L2, R1, R3, R2, R5, L3, L1, L1, R5, L4, L5, R5, R2, L5, R2, L1, L5, L3, L5, L5, L1, R1, L4, L3, L1, R2, R5, L1, L3, R4, R5, L4, L1, R5, L1, R5, R5, R5, R2, R1, R2, L5, L5, L5, R4, L5, L4, L4, R5, L2, R1, R5, L1, L5, R4, L3, R4, L2, R3, R3, R3, L2, L2, L2, L1, L4, R3, L4, L2, R2, R5, L1, R2'


drop table if exists #data
create table #data (rown int, turn varchar(1), dist int)

insert into #data
select id, left(trim(item),1) turn, cast(substring(trim(item),2,100) as int)  
from dbo.fn_split(@input,',') 

declare @rown int = 0, @maxrown int, @turn varchar(1), @dist int, @dir varchar(1) = 'N', @x int = 0, @y int = 0

declare @turns varchar(6) = 'NESWNE'

select @maxrown = max(rown) from #data

while @rown < @maxrown
begin
	set @rown += 1
	select @turn = turn, @dist = dist from #data where rown = @rown

	if @turn = 'L'
		set @dir = substring(@turns,CHARINDEX(@dir,@turns,2)-1,1)
	else
		set @dir = substring(@turns,CHARINDEX(@dir,@turns,2)+1,1)

	select	@x = @x + case @dir when 'E' then @dist when 'W' then -@dist else 0 end,
			@y = @y + case @dir when 'N' then @dist when 'S' then -@dist else 0 end

	raiserror('Turned %s, now facing %s, walked %d.  Now at (%d,%d)',0,0,@turn,@dir,@dist,@x,@y) with nowait

end

select abs(@x) + abs(@y) part1

--reset vars for part2
set @x = 0
set @y = 0
set @rown = 0
set @dir = 'N'
declare @step int 
declare @found int = 0
select @maxrown = max(rown) from #data

drop table if exists #locs
create table #locs(x int, y int)

while @rown < @maxrown
begin
	set @rown += 1
	select @turn = turn, @dist = dist from #data where rown = @rown

	if @turn = 'L'
		set @dir = substring(@turns,CHARINDEX(@dir,@turns,2)-1,1)
	else
		set @dir = substring(@turns,CHARINDEX(@dir,@turns,2)+1,1)

	raiserror('Turned %s, now facing %s, walking %d steps.',0,0,@turn,@dir,@dist) with nowait


	set @step = 0
	while @step < @dist
	begin
		set @step += 1 

		select	@x = @x + case @dir when 'E' then 1 when 'W' then -1 else 0 end,
				@y = @y + case @dir when 'N' then 1 when 'S' then -1 else 0 end

		raiserror(' .. walked %d.  Now at (%d,%d)',0,0,@step,@x,@y) with nowait

		if exists (select 1 from #locs where x = @x and y = @y) 
		begin 
			raiserror('This place is strangely familiar, argh bunny!!',0,0,@step,@x,@y) with nowait
			set @found = 1
			break
		end
		insert into #locs values(@x,@y)

	end
	if @found = 1 break
end

select abs(@x) + abs(@y) part2
