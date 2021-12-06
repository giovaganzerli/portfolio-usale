
create or replace function fn_update_seconds()
  returns trigger as
$func$
begin
  if tg_op = 'UPDATE' or tg_op = 'DELETE' THEN
    update "user"
    set seconds = seconds - date_part('epoch'::text, (old.refreshed_at - old.started_at))
    where old.user_id = "user".id;

    update "team"
    set seconds = seconds - date_part('epoch'::text, (old.refreshed_at - old.started_at))
    where old.team_code = "team".code;

    update "area"
    set seconds = seconds - date_part('epoch'::text, (old.refreshed_at - old.started_at))
    where old.area_code = "area".code;
  END IF;

  if tg_op = 'UPDATE' or tg_op = 'INSERT' THEN
    update "user"
    set seconds = seconds + date_part('epoch'::text, (new.refreshed_at - new.started_at))
    where new.user_id = "user".id;

    update "team"
    set seconds = seconds + date_part('epoch'::text, (new.refreshed_at - new.started_at))
    where new.team_code = "team".code;

    update "area"
    set seconds = seconds + date_part('epoch'::text, (new.refreshed_at - new.started_at))
    where new.area_code = "area".code;
  END IF;

  return new;
end
$func$
language plpgsql;

drop trigger tr_seconds on game_session;

create trigger tr_seconds
AFTER insert or update or delete
  on game_session
for each row
EXECUTE PROCEDURE fn_update_seconds();