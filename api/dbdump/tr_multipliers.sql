alter table "point_multiplier"
  add constraint check_positive check (multiplier > 0);

create or replace function fn_multiply_points()
  returns trigger as
$func$
begin
  if tg_op = 'UPDATE' or tg_op = 'DELETE' THEN
    update "team"
    set points = points / old.multiplier
    where old.team_code = "team".code;
  END IF;

  if tg_op = 'UPDATE' or tg_op = 'INSERT' THEN
    update "team"
    set points = points * new.multiplier
    where new.team_code = "team".code;
  END IF;

  return new;
end
$func$
language plpgsql;

drop trigger tr_multipliers on point_multiplier;

create trigger tr_multipliers
AFTER insert or update or delete
  on point_multiplier
for each row
EXECUTE PROCEDURE fn_multiply_points();