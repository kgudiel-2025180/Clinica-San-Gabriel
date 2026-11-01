-- Esquema de la agenda de Clínica Médica San Gabriel
-- Ejecutar completo en Supabase → SQL Editor.

-- 1. Tabla de citas
create table if not exists public.appointments (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  dpi text not null,
  phone text not null,
  specialty text not null,
  date date not null,
  slot text not null,
  created_at timestamptz not null default now(),
  constraint appointments_unique_slot unique (date, slot)
);

-- 2. Seguridad a nivel de fila
alter table public.appointments enable row level security;

drop policy if exists "admin_read_appointments" on public.appointments;
create policy "admin_read_appointments"
  on public.appointments for select
  to authenticated using (true);

drop policy if exists "admin_delete_appointments" on public.appointments;
create policy "admin_delete_appointments"
  on public.appointments for delete
  to authenticated using (true);

-- 3. Horarios ocupados: solo devuelve la hora, nunca datos personales
create or replace function public.get_booked_slots(p_date date)
returns table(slot text)
language sql
security definer
set search_path = public
as $$
  select a.slot from public.appointments a where a.date = p_date;
$$;

revoke all on function public.get_booked_slots(date) from public;
grant execute on function public.get_booked_slots(date) to anon, authenticated;

-- 4. Crear cita con validación y bloqueo de duplicados
create or replace function public.create_appointment(
  p_name text,
  p_dpi text,
  p_phone text,
  p_specialty text,
  p_date date,
  p_slot text
) returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_code text;
  v_id uuid;
begin
  if extract(isodow from p_date) not between 1 and 5 then
    return jsonb_build_object('ok', false, 'error', 'weekday');
  end if;

  if p_slot not in ('08:00','10:00','12:00','14:00','16:00','18:00') then
    return jsonb_build_object('ok', false, 'error', 'slot');
  end if;

  if length(regexp_replace(p_dpi, '\D', '', 'g')) <> 13 then
    return jsonb_build_object('ok', false, 'error', 'dpi');
  end if;

  v_code := 'CSG-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 6));

  insert into public.appointments (code, name, dpi, phone, specialty, date, slot)
  values (
    v_code,
    trim(p_name),
    regexp_replace(p_dpi, '\D', '', 'g'),
    trim(p_phone),
    p_specialty,
    p_date,
    p_slot
  )
  returning id into v_id;

  return jsonb_build_object('ok', true, 'id', v_id, 'code', v_code);

exception
  when unique_violation then
    return jsonb_build_object('ok', false, 'error', 'taken');
end;
$$;

revoke all on function public.create_appointment(text,text,text,text,date,text) from public;
grant execute on function public.create_appointment(text,text,text,text,date,text) to anon, authenticated;
