delimiter //
CREATE DEFINER=`root`@`localhost` TRIGGER `repair_start_check` BEFORE INSERT ON `powerlines_repair_plan` FOR EACH ROW begin 
	if new.repair_start_at < current_date() then 
		signal sqlstate '45000' set message_text = 'Дата не должна быть в прошлом';
	end if;
end //
delimiter ;

delimiter //
CREATE DEFINER=`root`@`localhost` TRIGGER `check_repair_time` BEFORE INSERT ON `powerlines_repair_plan` FOR EACH ROW begin 
	if new.repair_end_at < new.repair_start_at then 
		signal sqlstate '45000' set message_text = 'Дата окончания ремонта не может быть меньше даты начала.';
	end if;
end
delimiter ;