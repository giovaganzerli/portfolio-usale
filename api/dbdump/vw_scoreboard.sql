
-- User scoreboard
drop view vw_user_scoreboard;
create or replace VIEW vw_user_scoreboard
as
select
  u.id id,
  u.app_code,
  (u.name || ' ' || u.surname) as name,
  u.team_code,
  u.area_code,
  u.points,
  round(u.seconds)::integer seconds,
  ((u.curr_game_id-1)/2)::integer games,
  u.curr_special_game_id-1 special_games,
  case when u.seconds!=0 then round((u.points/u.seconds)::numeric, 2) else 0.0 end coins
from "vw_valid_user" u;

select * from vw_user_scoreboard;

-- Team scoreboard
drop view vw_team_scoreboard;
create or replace VIEW vw_team_scoreboard
as
  select
    t.id as id,
    '' as name,
    t.code team_code,
    t.area_code,
    t.points,
    round(t.seconds)::integer seconds,
    case when t.seconds!=0 then round((t.points/t.seconds)::numeric, 2) else 0 end coins
  from "vw_valid_team" t;

select * from vw_team_scoreboard;

-- Area scoreboard
drop view vw_area_scoreboard;
create or replace VIEW vw_area_scoreboard
as
  select
    a.id as id,
    '' as name,
    '' as team_code,
    a.code area_code,
    points,
    round(a.seconds)::integer seconds,
    case when a.seconds!=0 then round((a.points/a.seconds)::numeric, 2) else 0 end coins
  from "vw_valid_area" a;

select * from vw_area_scoreboard;

create or replace view vw_valid_user
AS
  select *
  from "user"
  where "name" != ''
  and surname != ''
  and "role" < 4
  and app_code not ilike 'lagroup%'
  and app_code not ilike 'test%'
  and app_code not ilike 'fake%';

select * from vw_valid_user;

drop view vw_valid_team;
create or replace view vw_valid_team
AS
  select *
  from "team"
  where id in (
    select distinct t.id
    from "team" t
      inner join vw_valid_user u
        on t.code = u.team_code
        and t.area_code = u.area_code
    where u.role < 3 -- User, TeamLeader
  )
  and code != ''
  and code not ilike 'lagroup%'
  and code not ilike 'test%';

drop view vw_valid_area;
create or replace view vw_valid_area
AS
  select *
  from "area"
  where id in (
    select distinct a.id
    from "area" a
    inner join vw_valid_user u
      on a.code = u.area_code
    where u.role < 4 -- User, TeamLeader, AreaManager
  )
  and code != ''
  and code not ilike 'lagroup%'
  and code not ilike 'test%';

drop view vw_team_leader;
create or replace view vw_team_leader
AS
  select u.*
  from vw_valid_team t
  left join "user" u
    on t.code = u.team_code
    and t.area_code = u.area_code
  where u.role = 2;

select
  u.name,
  u.surname,
  u.team_code,
  u.area_code
from "vw_valid_user" u
inner join "team"
  ON u.team_code = "team".code
  and team.code != ''
where u.role = 3;