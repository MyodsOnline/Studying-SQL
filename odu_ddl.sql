/***************************************** description *****************************************/
/* Здравствуйте, Кирилл! Как и было заявлено на первом уроке, я старался перевести полученные  */
/* знания на рельсы своей профессии, поэтому база данных посвящена отрасли энергетика.         */
/* БД содержит перечень энергетического оборудования части энергосистемы — линий электропередач*/
/* постанций и электростанций, а также список персонала объектов. Осуществлена привязка        */
/* оборудования к классам напряжения и эксплуатационной ответственности. Состояние оборудования*/
/* принимает одно из допустимых значений. Отдельная таблица с планами ремонтов.                */
/***********************************************************************************************/

-------------------------------------------------------------------------------------------------
-- очевидно, ddl базы имеет множество недостатков, которые стали ясны даже мне в процессе её   --
-- наполнения, и вызвали множество вопросов. Но, первый блин - комом. Кирилл, если у вас будет --
-- свободная минута, скажите пожалуйста, как правильно организовать тип связей, где:           --
-- имеем некоторое число оборудования, имеем некоторое число центров, которые управляют (=1),  --
-- контролируют (>1) или ведают (>1) этим оборудованием?                                       --
--                                                                                             --
-- Например:          управляет            контролирует                ведает                  --
--                     ЦЕНТР-1           ЦЕНТР-2, ЦЕНТР-5          ЦЕНТР-3, ЦЕНТР-4            --
--      линия (А)_________________________________________________________________________(В)  --
--                                                                                             --
-- И такие комбинации разные для разного оборудования.                                         --
-------------------------------------------------------------------------------------------------

drop database if exists odu; 
create database odu;
use odu;

/* Voltage list */
drop table if exists voltage_list;
create table voltage_list (
    vl_id serial primary key,
    voltage varchar(50),
    index voltage_idx(voltage)
) comment 'Класс напряжения';

/* Dispatch centers list */
drop table if exists disp_center;
create table disp_center (
    center_id serial primary key,
    foregin bit default 0,
    center_name varchar(50)
) comment 'Перечень диспетчерских центров';

/* Types of dispatch managing */
drop table if exists managing_role;
create table managing_role(
    role_id int unsigned not null auto_increment primary key,
    managing_type varchar(50) 
) comment 'Виды диспетчерского управления';

/* Mode list */
drop table if exists current_mode;
create table current_mode (
    cm_id int unsigned not null auto_increment primary key,
    cm_type varchar(20)
) comment 'Состояние оборудования';

/* Object type list */
drop table if exists object_type;
create table object_type (
    ot_id int unsigned not null auto_increment primary key,
    ot_type varchar(20)
) comment 'Типы объектов';

/* Other equipment */
drop table if exists equipment;
create table equipment (
	eq_id serial primary key,
    eq_name varchar(50),
    eq_voltage bigint unsigned,
    eq_mode int unsigned,
    eq_mode_last_update datetime default current_timestamp on update current_timestamp,
    foreign key (eq_voltage) references voltage_list(vl_id),
    foreign key (eq_mode) references current_mode(cm_id)
) comment 'Прочее оборудование';

/* Object list */
drop table if exists object_list;
create table object_list (
	object_id serial primary key,
	object_name varchar(50),
	index object_name_idx(object_name),
	object_type int unsigned,
	object_manage bigint unsigned, 
    object_voltage bigint unsigned,
    object_eq bigint unsigned,
    foreign key (object_eq) references equipment(eq_id),
    foreign key (object_type) references object_type(ot_id),
    foreign key (object_voltage) references voltage_list(vl_id),
	foreign key (object_manage) references disp_center(center_id)
) comment 'Перечень объектов';;

/* Powerlines list */
drop table if exists power_lines;
create table power_lines (
	line_id serial primary key,
    line_name varchar(100),
    index line_name_idx (line_name),
    line_voltage bigint unsigned,
    line_managing int unsigned,
    line_dispatch bigint unsigned,
    line_mode int unsigned,
    line_start bigint unsigned,
    line_end bigint unsigned,
    line_mode_last_update datetime default current_timestamp on update current_timestamp,
    foreign key (line_voltage) references voltage_list(vl_id),
    foreign key (line_mode) references current_mode(cm_id),
    foreign key (line_managing) references managing_role(role_id),
    foreign key (line_dispatch) references disp_center(center_id),    
    foreign key (line_start) references object_list(object_id),
	foreign key (line_end) references object_list(object_id)
) comment 'Перечень линий электропередач';

/* Workers list */
drop table if exists workers_list;
create table worker_list (
	worker_id serial primary key,
    worker_name varchar(100),
    worker_last_update timestamp default now(),
    worker_workplace bigint unsigned,
    foreign key (worker_workplace) references object_list(object_id)
) comment 'Список персонала';

/* Repair plan */
drop table if exists powerlines_repair_plan;
create table powerlines_repair_plan (
	rp_id serial primary key,
    rp_powerlines bigint unsigned,
    repair_start_at datetime,
    repair_end_at datetime,
    foreign key (rp_powerlines) references power_lines(line_id)
) comment 'План ремонтов ЛЭП';












