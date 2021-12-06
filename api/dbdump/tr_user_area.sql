create or replace function fn_create_area()
  returns trigger as
$func$
begin
  if not exists (select id from "area" where code = new.area_code) then
    insert into "area" (code) values (new.area_code);
  END if;

  return new;
end
$func$
language plpgsql;

drop trigger tr_user_area on "user";

create trigger tr_user_area
AFTER insert or update
  on "user"
for each row
EXECUTE PROCEDURE fn_create_area();