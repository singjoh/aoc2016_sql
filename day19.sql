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

drop table if exists #players
create table #players(id int, presents int)

drop table if exists #results
create table #results(elves int, winnerid int)


declare @playertotal int = 1
declare @pid int = 1
declare @nid int 

/*

while @playertotal < 100
begin

	set @playertotal += 1

	truncate table #players

  ;WITH E1(N)        AS ( SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                         UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                         UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1),
       E2(N)        AS (SELECT 1 FROM E1 a, E1 b),
       E21(N)        AS (SELECT 1 FROM E2 a, E1 b),
       cteTally(N)  AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E21)
	insert into #players
	select n, 1
	from cteTally
	where n <= @playertotal

	set @pid = 1
	while 1 = 1
	begin

		select @pid = p.id, @nid = n.id
		from (select min(id) id from #players where id >= @pid) p
		outer apply (select min(id) id from #players where id > p.id) n

		if @pid is null
		select @pid = p.id, @nid = n.id
		from (select min(id) id from #players) p
		outer apply (select min(id) id from #players where id > p.id) n

		if @nid is null
		select @nid = p.id
		from (select min(id) id from #players where id < @pid) p

		if @nid is null break

		update p
		set presents = p.presents + n.presents
		from #players p
		join #players n
			on n.id = @nid
		where p.id = @pid

		delete from #players where id = @nid

		set @pid += 1
	end

	insert into #results select @playertotal, id from #players

end

select * from #results
-- these show winner as
-- id = (elves - 2^x) * 2 - 1
-- where x is largest int such that 2^x <= elves

-- validate the equation
  ;WITH E1(N)        AS ( SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                         UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                         UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1),
       E2(N)        AS (SELECT 1 FROM E1 a, E1 b),
	   cteTally(N)  AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E2),
	   ctePowers(N) AS (SELECT power(2,n) from cteTally where n < 25) -- 65M much larger than we need
	   select r.*, (elves - n2) * 2 + 1 
	   from #results r
	   outer apply (select max(n) n2 from ctePowers where n <= r.elves) as x
	    
-- part 1
  ;WITH E1(N)        AS ( SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                         UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                         UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1),
       E2(N)        AS (SELECT 1 FROM E1 a, E1 b),
	   cteTally(N)  AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E2),
	   ctePowers(N) AS (SELECT power(2,n) from cteTally where n < 25) -- 65M much larger than we need
	   select (elves - n2) * 2 + 1 part1
	   from (select 3001330 as elves) r
	   outer apply (select max(n) n2 from ctePowers where n <= r.elves) as x
	    

--*/



set @playertotal = 1
set @pid = 1

while @playertotal < 100
begin
	set @playertotal += 1

	truncate table #players

  ;WITH E1(N)        AS ( SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                         UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                         UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1),
       E2(N)        AS (SELECT 1 FROM E1 a, E1 b),
       E21(N)        AS (SELECT 1 FROM E2 a, E1 b),
       cteTally(N)  AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E21)
	insert into #players
	select n, 1
	from cteTally
	where n <= @playertotal

	set @pid = 1
	while 1 = 1
	begin

		select @pid = p.id, @nid = y.victim
		from (select min(id) id from #players where id >= @pid) p
		outer apply (select FLOOR(count(*)/2) n from #players) as x 
		outer apply (select id, lead(id,x.n) over (order by id) victim from #players) y
		where y.id = p.id

		if @@ROWCOUNT = 0
		select @pid = p.id, @nid = y.victim
		from (select min(id) id from #players) p
		outer apply (select FLOOR(count(*)/2) n from #players) as x 
		outer apply (select id, lead(id,x.n) over (order by id) victim from #players) y
		where y.id = p.id

		if @nid is null
		select @nid = victim
		from (select count(*) n from #players where id > @pid) as x
		outer apply (select min(id) id from #players) mn
		outer apply (select FLOOR(count(*)/2) n from #players) as y
		outer apply (select id, lead(id,y.n-x.n-1) over (order by id) victim from #players) z
		where z.id = mn.id

		if @nid is null or @nid = @pid break

		if 1 = 2
		raiserror('Player %i steals from %i',0,0,@pid,@nid) with nowait

		update p
		set presents = p.presents + n.presents
		from #players p
		join #players n
			on n.id = @nid
		where p.id = @pid

		delete from #players where id = @nid

		set @pid += 1

	end

	insert into #results select @playertotal, id from #players

end

select * from #results

-- these show winner as
-- if elves = 3^x then 3^x
--   else if elves <= 3 * 3^x then elves - 3^x
--   else 2 * elves - 3^(x+1)
-- where x is largest int such that 3^x <= elves

-- validate the results
  ;WITH E1(N)        AS ( SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                         UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                         UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1),
       E2(N)        AS (SELECT 1 FROM E1 a, E1 b),
	   cteTally(N)  AS (SELECT 0 UNION SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E2),
	   ctePowers(N) AS (SELECT power(3,n) from cteTally where n < 15) 
	   select r.*, n3, 
		case	when n3 = elves then elves 
				when elves <= 2*n3 then elves - n3
				else 2*elves - 3*n3
			end
	   from #results r
	   outer apply (select max(n) n3 from ctePowers where n <= r.elves) as x
	   order by elves


-- part 2
  ;WITH E1(N)        AS ( SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                         UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
                         UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1),
       E2(N)        AS (SELECT 1 FROM E1 a, E1 b),
	   cteTally(N)  AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E2),
	   ctePowers(N) AS (SELECT power(3,n) from cteTally where n < 15) 
	   select  
		case	when n3 = elves then elves 
				when elves <= 2*n3 then elves - n3
				else 2*elves - 3*n3
			end part2
	   from (select 3001330 as elves) r
	   outer apply (select max(n) n3 from ctePowers where n <= r.elves) as x