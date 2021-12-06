create or replace function fn_update_points()
  returns trigger as
$func$
begin
  if tg_op = 'UPDATE' or tg_op = 'DELETE' THEN
    update "user"
    set points = points - old.points
    where old.user_id = "user".id;

    update "team"
    set points = points - old.points
    where old.team_code = "team".code;

    update "area"
    set points = points - old.points
    where old.area_code = "area".code;
  END IF;

  if tg_op = 'UPDATE' or tg_op = 'INSERT' THEN
    update "user"
    set points = points + new.points
    where new.user_id = "user".id;

    update "team"
    set points = points + new.points
    where new.team_code = "team".code;

    update "area"
    set points = points + new.points
    where new.area_code = "area".code;
  END IF;

  return new;
end
$func$
language plpgsql;

drop trigger tr_points on game_action;

create trigger tr_points
AFTER insert or update or delete
  on game_action
for each row
EXECUTE PROCEDURE fn_update_points();