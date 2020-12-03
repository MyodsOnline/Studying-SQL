-- выбрать линии отходящие от Киришской ГРЭС которыми управлет ОДУ и указать их состояние:
select 
	ol.object_name,
	pl.line_name,
	cm.cm_type as 'mode'
from power_lines as pl
join object_list as ol on line_start = object_id
join current_mode as cm on line_mode = cm_id
where line_start = 4 and line_dispatch = 8;


-- выбрать персонал на объектах классом напряжения 750 кВ
select 
	worker_name,
    object_name
from worker_list
join object_list on worker_workplace = object_id
where object_voltage = 7;


-- выбрать линию, которая начинается где-то на %ГАЭ%
select line_name from power_lines where line_start = 
(select object_id from object_list where object_name like '%ГАЭ%');


-- посчитать сколько линий в управлении каждого диспетчерского центра
select 
	count(*),
    (select center_name from disp_center where center_id = line_dispatch) as 'dispatcers'
from power_lines
group by line_dispatch
order by count(*) desc;


-- посчитать сколько линий каждого класса напряжения, но больше 2х
select 
count(*) as cnt,
(select voltage from voltage_list where vl_id = line_voltage) as voltage
from power_lines
group by line_voltage
having cnt > 2
order by voltage


-- выбрать всё (линии и оборудование), что в ремонте
select
	line_name
from power_lines
join current_mode on line_mode = cm_id
where line_mode = 2
union
select
	concat(eq_name, ' на ', object_name)
from equipment
join current_mode on eq_mode = cm_id
join object_list on eq_id = object_eq
where eq_mode = 2;


-- выбрать все иностранные линии, по которым есть планы на ремонт
select 
	center_name,
    line_name,
    repair_start_at,
    repair_end_at
from power_lines
join disp_center on line_dispatch = center_id
join powerlines_repair_plan on rp_powerlines = line_id
where disp_center.foregin = 1
order by repair_start_at;

