-- представление для выборки линий, сроки ремонтов для которых закончились, а они всё ещё в ремонте.
create or replace view offset_rp as
	select
		line_name, 
		cm_type,
		repair_end_at
	from power_lines
	join powerlines_repair_plan on rp_powerlines = line_id
	join current_mode on cm_id = line_mode
	where repair_end_at < current_date()
		and line_mode = 2
	order by repair_end_at;

select * from offset_rp;


-- представление для выборки линий и объектов, управляет которыми НовгРДУ
create or replace view admin_by_nrdu as
select line_name from power_lines
join disp_center on line_dispatch = center_id
where center_id = 11
union
select object_name from object_list
join disp_center on object_manage = center_id
where center_id = 11;

select * from admin_by_nrdu;