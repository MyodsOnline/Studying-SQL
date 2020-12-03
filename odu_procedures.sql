-- процедура возвращает объекты, персонал и оборудование, которое повреждено 

drop procedure if exists howdy;
delimiter //
create procedure howdy(cm_id int)
begin
	select
		eq_name,
		object_name,
		worker_name
	from odu.equipment
		join odu.object_list on object_id = eq_id
		join odu.worker_list on worker_id = object_id
	where eq_mode = cm_id
union	
	select
		line_name,
		object_name,
		worker_name	
	from odu.power_lines
		join odu.object_list on object_id = line_start
		join odu.worker_list on worker_id = object_id
	where line_mode = cm_id;
end //
delimiter ;

call howdy(4);


-- выбрать объекты и персонал по концам линии
drop procedure if exists howdy_ho;
delimiter //
create procedure howdy_ho(line_id bigint)
begin
	select
		pl.line_name,
	    ol_s.object_name as 'line start',
	    wl_s.worker_name,    
	    ol_e.object_name as 'line end',
	    wl_e.worker_name
	from power_lines as pl
		join object_list as ol_s on ol_s.object_id = pl.line_start
		join object_list as ol_e on ol_e.object_id = pl.line_end
		join worker_list as wl_s on wl_s.worker_id = ol_s.object_id
		join worker_list as wl_e on wl_e.worker_id = ol_e.object_id
	where pl.line_id = line_id;
end //
delimiter ;

call howdy_ho(4);

-- транзакция. уволили с работы персонажа и приняли другого
drop procedure if exists hare;
delimiter //
create procedure hare()
	begin
	start transaction;
		delete from worker_list where worker_workplace = 1;
		insert into worker_list (worker_name, worker_workplace) values
		('Кумыс Андрей Александрович', '1');
	commit;
end //
delimiter ;

call hare();

-- процедура перевода линии в работу 
drop procedure if exists to_work;
delimiter //
create procedure to_work(line_id_ch int)
	begin
	start transaction;
		update odu.power_lines set line_mode = 1
		where odu.line_id = line_id_ch;
	commit;
end //
delimiter ;

call to_work(2);