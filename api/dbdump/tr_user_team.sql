create or replace function fn_create_team()
  returns trigger as
$func$
begin
  if not exists (
      select id from "team"
      where code = new.team_code
      and area_code = new.area_code
  ) then
    insert into "team" (code, area_code) values (new.team_code, new.area_code);
  END if;

  return new;
end
$func$
language plpgsql;

drop trigger tr_user_team on "user";

create trigger tr_user_team
AFTER insert or update
  on "user"
for each row
EXECUTE PROCEDURE fn_create_team();