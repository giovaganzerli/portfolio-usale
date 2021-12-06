-- UserGeneration
delete from "user";
delete from "team";
delete from "area";
alter sequence user_id_seq restart with 1;
alter sequence team_id_seq restart with 1;
alter sequence area_id_seq restart with 1;

insert into "user" (name, surname, app_code, team_code, area_code, role)
  select 'User' || i::varchar, '', ('user' || i::varchar), ('Team' || ((i-1)/20 + 1)::varchar), ('Area' || ((i-1)/40 + 1)::varchar), 1
  from generate_series(1, 120) i;

insert into "user" (name, surname, app_code, team_code, area_code, role)
  select 'TeamLeader' || i::varchar, '', ('teamleader' || i::varchar), ('Team' || i::varchar), ('Area' || ((i-1)/2 + 1)::varchar), 2
  from generate_series(1, 6) i;

insert into "user" (name, surname, app_code, team_code, area_code, role)
  select 'AreaManager' || i::varchar, '', ('areamanager' || i::varchar), ('Area' || i::varchar), ('Area' || i::varchar), 3
  from generate_series(1, 3) i;

insert into "user" (name, surname, app_code, team_code, area_code, role)
  select 'SuperUser' || i::varchar, '', ('superuser' || i::varchar), 'SuperUsers', 'SuperUsers', 4
  from generate_series(1, 2) i;

insert into "user" (name, surname, app_code, team_code, area_code, role)
    values ('Tester1', '', 'tester1', 'Team1', 'Area1', 5);
-- /UserGeneration


-- SessionGeneration
delete from game_session;
alter SEQUENCE game_session_id_seq RESTART with 1;

insert into game_session(user_id, game_id, started_at, refreshed_at, team_code, area_code)
  select
    u.id, random()*5+1,
    (timestamp '2017-01-01 00:00' + random()*(timestamp '2017-04-01 00:00' - timestamp '2017-01-01 00:00')),
    (timestamp '2017-01-01 00:00' + random()*(timestamp '2017-04-01 00:00' - timestamp '2017-01-01 00:00')),
    u.team_code, u.area_code
  from "user" u
    inner join generate_series(1, 240) i
      on trunc(random()*i+1)::int = u.id
  order by u.id;

update game_session
set refreshed_at = started_at + (random()*20+5) * interval '1 second';
-- /SessionGeneration

-- ActionGeneration
delete from game_action;
alter SEQUENCE game_action_id_seq RESTART with 1;

insert into game_action(game_id, item_id, user_id, occurred_at, points, team_code, area_code)
  select
    game_id,
    item_id,
    u.id,
    (timestamp '2017-01-01 00:00' + random()*(timestamp '2017-04-01 00:00' - timestamp '2017-01-01 00:00')),
    trunc(random()*8 -4)::int,
    u.team_code, u.area_code
  from "user" u
    cross join generate_series(1, 5) game_id
    cross join generate_series(1, 3) item_id
  order by u.id;
-- /ActionGeneration