CREATE DEFINER=`root`@`localhost` PROCEDURE `WJK_LEFT_P_remain_ticket`(oi_train_days_in TINYINT UNSIGNED ,
  os_purposes_in   VARCHAR(40) ,
  assign_station_in	VARCHAR(255) ,
  flag_in INT ,
  plan_train_no_in CHAR(12) ,
  plan_train_date_in CHAR(8),
  out_flag TINYINT UNSIGNED,
  INOUT SWP_Ret_Value INT)
SWL_return:
BEGIN
  DECLARE share_flag CHAR(1);
  DECLARE range2 INT;



  DECLARE Version CHAR(20);
  DECLARE To_Range TINYINT UNSIGNED;
  DECLARE transform_no CHAR(2);
  DECLARE tmp_range TINYINT UNSIGNED;
  DECLARE tmp_start_coach_no CHAR(2);
  DECLARE tmp_end_coach_no CHAR(2);
  DECLARE transform_bureau_code CHAR(1);
  DECLARE transform_subbureau_code CHAR(2);
  DECLARE sale_bureau CHAR(1);
  DECLARE sale_subbureau CHAR(2);
  DECLARE old_sale_station CHAR(3);
  DECLARE transform_station_telecode CHAR(3);
  DECLARE old_range TINYINT UNSIGNED;

  DECLARE transform_date CHAR(8);
  DECLARE original_station_telecode CHAR(3);
  DECLARE share_string VARCHAR(1300);
  DECLARE ni_day TINYINT UNSIGNED;
  DECLARE error INT;
  DECLARE rowcount INT;

  DECLARE ns_train_no CHAR(12);
  DECLARE ns_station_train_code CHAR(8);
  DECLARE ns_station_no CHAR(2);
  DECLARE ns_train_date CHAR(8);

  DECLARE ns_train_code VARCHAR(8);
  DECLARE ns_limit_station_no CHAR(2);
  DECLARE ns_limit_station_name CHAR(10);

  DECLARE ns_start_station_name CHAR(10);
  DECLARE ns_end_station_name CHAR(10);
  DECLARE ns_direction_code CHAR(1);
  DECLARE ns_direction_name CHAR(10);

  DECLARE ns_arrive_time CHAR(4);
  DECLARE ns_start_time CHAR(4);
  DECLARE ns_station_telecode CHAR(3);

  DECLARE be_types CHAR(1);
  DECLARE yz_types VARCHAR(20);
  DECLARE yw_types VARCHAR(20);
  DECLARE rz_types VARCHAR(20);
  DECLARE rw_types VARCHAR(20);
  DECLARE wz_types VARCHAR(5);
  DECLARE pTypes VARCHAR(3);

  DECLARE yz_yn CHAR(1);
  DECLARE yw_yn CHAR(1);
  DECLARE rz_yn CHAR(1);
  DECLARE rw_yn CHAR(1);
  DECLARE wz_yn CHAR(1);

  DECLARE yz_count SMALLINT;
  DECLARE yw_count SMALLINT;
  DECLARE rz_count SMALLINT;
  DECLARE rw_count SMALLINT;
  DECLARE wz_count SMALLINT;

  DECLARE c_date1 CHAR(2);
  DECLARE c_date2 CHAR(2);
  DECLARE c_date CHAR(5);
  DECLARE c_current_date CHAR(4);
  DECLARE c_today CHAR(8);
  DECLARE c_train_no CHAR(12);
  DECLARE c_station_name CHAR(12);
  DECLARE c1_station_name CHAR(10);
  DECLARE c_tmp_date CHAR(8);
  DECLARE tmp_no INT;
  DECLARE single_assign_station CHAR(3);
  DECLARE c_count INT;
  DECLARE tmp_train_code CHAR(8);
  DECLARE temp_date CHAR(8);
  DECLARE assign_station_name CHAR(20);
  DECLARE my_center_code CHAR(2);
  DECLARE my_bureau_code CHAR(1);
  DECLARE ns_location_code CHAR(2);

  DECLARE j INT;
  DECLARE seat_type_count INT;
  DECLARE i INT;
  DECLARE seat_name VARCHAR(255);
  DECLARE seat_type_belong CHAR(1);
  DECLARE seat_type CHAR(1);
  DECLARE seat_types INT;

  DECLARE ret_code INT;
  DECLARE nc_operate_time DATETIME;
  DECLARE nc_start_date CHAR(8);
  DECLARE nc_stop_date CHAR(8);
  DECLARE nc_train_no CHAR(12);
  DECLARE nc_station_no CHAR(2);
  DECLARE nc_station_telecode CHAR(3);
  DECLARE nc_station_name CHAR(10);
  DECLARE nc_board_train_code CHAR(8);
  DECLARE nc_command_code CHAR(1);
  DECLARE nc_day_difference TINYINT UNSIGNED;
  DECLARE nc_arrive_time CHAR(4);
  DECLARE nc_start_time CHAR(4);
  DECLARE nc_time_interval TINYINT UNSIGNED;
  DECLARE nc_running_style TINYINT UNSIGNED;
  DECLARE nc_running_rule INT;
  DECLARE tmp_limit_station_no CHAR(2);

  DECLARE sta_in_str VARCHAR(512);
  DECLARE sql_str VARCHAR(1024);
  DECLARE bureau_code CHAR(10);
  DECLARE control_day INT;
  DECLARE date_range_n_begin CHAR(8);
  DECLARE date_range_n_end CHAR(8);
  DECLARE date_range_f_begin CHAR(8);
  DECLARE date_range_f_end CHAR(8);
  DECLARE depart_date CHAR(8);
  DECLARE from_day_diff INT;
  DECLARE return_code INT;
  DECLARE train_no CHAR(12);
  DECLARE ll_max_station_no CHAR(2);
  DECLARE ll_end_station_telecode CHAR(3);
  DECLARE end_station_telecode CHAR(3);

  DECLARE NO_DATA INT DEFAULT 0;
  DECLARE SWV_ns_train_code_Str VARCHAR(8);
  DECLARE seat_type_string VARCHAR(50);
  declare return_out int;


  DECLARE assign_station_in_len int;


  --- modify the logic 
  /* DECLARE read_seattypes CURSOR FOR */
  /* SELECT wjk_tt_tmp_seat_type_tmp.seat_type_code */
  /* FROM wjk_tt_tmp_seat_type_tmp */
  /* WHERE LOCATE(wjk_tt_tmp_seat_type_tmp.belong_seat_type_code,pTypes) > 0; */

  DECLARE read_seattypes CURSOR FOR
  SELECT wjk_tt_tmp_seat_type_tmp.seat_type_code, belong_seat_type_code
  FROM wjk_tt_tmp_seat_type_tmp;


  DECLARE cur_notice CURSOR FOR
  SELECT 	wjk_tt_tmp_center_notice.operate_time,
  wjk_tt_tmp_center_notice.start_date,
  wjk_tt_tmp_center_notice.stop_date,
  wjk_tt_tmp_center_notice.train_no,
  wjk_tt_tmp_center_notice.station_no,
  wjk_tt_tmp_center_notice.station_telecode,
  wjk_tt_tmp_center_notice.station_name,
  wjk_tt_tmp_center_notice.board_train_code,
  wjk_tt_tmp_center_notice.command_code,
  wjk_tt_tmp_center_notice.day_difference,
  wjk_tt_tmp_center_notice.arrive_time,
  wjk_tt_tmp_center_notice.start_time,
  wjk_tt_tmp_center_notice.time_interval,
  wjk_tt_tmp_center_notice.running_style,
  wjk_tt_tmp_center_notice.running_rule
  FROM  wjk_tt_tmp_center_notice
  where wjk_tt_tmp_center_notice.train_no = ns_train_no
  and wjk_tt_tmp_center_notice.station_telecode = single_assign_station
  and wjk_tt_tmp_center_notice.stop_date >= ns_train_date
  and wjk_tt_tmp_center_notice.start_date <= ns_train_date
  order by wjk_tt_tmp_center_notice.operate_time;


  DECLARE cur_train CURSOR FOR
  SELECT wjk_tt_tmp_stop_time.tmp_train_no,
  wjk_tt_tmp_stop_time.tmp_start_station_name,
  wjk_tt_tmp_stop_time.tmp_end_station_name
  FROM  wjk_tt_tmp_stop_time;



  DECLARE cur_dele CURSOR FOR
  SELECT wjk_tt_tmp.train_code
  FROM wjk_tt_tmp;


  DECLARE CONTINUE HANDLER FOR NOT FOUND SET NO_DATA = 2;
  IF oi_train_days_in is null then
    set oi_train_days_in = 3;
  END IF;
  IF os_purposes_in is null then
    set os_purposes_in = '00';
  END IF;
  IF assign_station_in is null then
    set assign_station_in = "LZJ";
  END IF;
  IF flag_in is null then
    set flag_in = 0;
  END IF;
  IF plan_train_no_in is null then
    set plan_train_no_in = '%';
  END IF;
  IF plan_train_date_in is null then
    set plan_train_date_in = '';
  END IF;
  SET Version = "Ver20101109";

  select   station_dictionary.bureau_code
  INTO bureau_code
  from basic.station_dictionary
  where station_dictionary.station_telecode = SUBSTRING(assign_station_in,1,3);

  ---add index (inner_code, train_code, ticket_type, stop_date)
  select   max(DJ50_train_sale_define.control_day)
  INTO control_day
  from basic.DJ50_train_sale_define
  where DJ50_train_sale_define.stop_date >= DATE_FORMAT(CURRENT_TIMESTAMP,'%Y%m%d')
  and DJ50_train_sale_define.start_date <= DATE_FORMAT(CURRENT_TIMESTAMP,'%Y%m%d')
  and DJ50_train_sale_define.inner_code = bureau_code
  and DJ50_train_sale_define.ticket_type = 0
  and (DJ50_train_sale_define.purpose_code	 = SUBSTRING(os_purposes_in,1,2) OR DJ50_train_sale_define.purpose_code = "*")
  and (DJ50_train_sale_define.flag1 = 'A' OR DJ50_train_sale_define.flag1 = '*')
  and DJ50_train_sale_define.train_code = '*';
  if out_flag=2 THEN
    select '2===== is here';
  end if;
  --- modify to one if
  if plan_train_date_in = '' then
    if flag_in in(2,3) then
      if bureau_code <> 'P' and (oi_train_days_in >= 5 or oi_train_days_in < 1) then
        SET oi_train_days_in = 5;
      elseif bureau_code = 'P' and (oi_train_days_in >= 6 or oi_train_days_in < 1) then
        SET oi_train_days_in = 6;
      end if;

      SET date_range_n_begin = DATE_FORMAT(CURRENT_TIMESTAMP,'%Y%m%d');
      SET date_range_n_end = DATE_FORMAT(TIMESTAMPADD(DAY,oi_train_days_in -1,CURRENT_TIMESTAMP),'%Y%m%d');
      SET date_range_f_begin = DATE_FORMAT(TIMESTAMPADD(DAY,control_day -oi_train_days_in+1,CURRENT_TIMESTAMP),
        '%Y%m%d');
      SET date_range_f_end = DATE_FORMAT(TIMESTAMPADD(DAY,control_day,CURRENT_TIMESTAMP),'%Y%m%d');
    else
      SET date_range_n_begin = DATE_FORMAT(CURRENT_TIMESTAMP,'%Y%m%d');
      SET date_range_n_end = DATE_FORMAT(TIMESTAMPADD(DAY,oi_train_days_in -1,CURRENT_TIMESTAMP),'%Y%m%d');
      SET date_range_f_begin = '20991231';
      SET date_range_f_end = '20991231';
    end if;
  else
    SET date_range_n_begin = plan_train_date_in;
    SET date_range_n_end = plan_train_date_in;
    SET date_range_f_begin = '20991231';
    SET date_range_f_end = '20991231';
  end if;


  if out_flag=2 THEN
    select ('3=== is here');
  end if;


  CREATE TEMPORARY TABLE IF not EXISTS wjk_tt_train_info
  (
    train_date CHAR(8) NOT NULL,
    train_no CHAR(12) NOT NULL,
    train_code CHAR(8) NOT NULL,
    from_station CHAR(3) NOT NULL,
    to_station CHAR(3) NOT NULL
  );
  truncate table wjk_tt_train_info;
  if out_flag=2 THEN
    select ('4=== is here');
  end if;


  CREATE TEMPORARY TABLE   IF not EXISTS wjk_tt_tmp_left_base_center
  (

    assign_station CHAR(3) NOT NULL,
    train_no CHAR(12) NOT NULL,
    train_date CHAR(8) NOT NULL,
    station_no CHAR(2) NOT NULL,
    far_from_station_no CHAR(2) NOT NULL,
    limit_station CHAR(2) NOT NULL,
    coach_no CHAR(2) NOT NULL,
    seat_type_code CHAR(1) NOT NULL,
    purpose_code CHAR(2) NOT NULL,
    ticket_quantity INT NOT NULL,
    up_quantity INT NOT NULL,
    mid_quantity INT NOT NULL,
    down_quantity INT NOT NULL,
    ticket_source CHAR(1) NOT NULL,
    `range` TINYINT UNSIGNED NOT NULL,
    inner_code CHAR(7) NOT NULL,
    wseat_type_code CHAR(1),
    seat_feature CHAR(1),
    INDEX tmp_left_base_center_idx(train_no,
      train_date,
      limit_station)
  );
  truncate table wjk_tt_tmp_left_base_center;




  CREATE TEMPORARY TABLE IF not EXISTS  tt_WJK_LEFT_remain_ticket
  (
    station_telecode CHAR(3) NOT NULL,
    train_no CHAR(12) NOT NULL,
    train_code CHAR(8) NOT NULL,
    train_date CHAR(8) NOT NULL,
    start_station_name CHAR(10) NOT NULL,
    end_station_name CHAR(10) NOT NULL,
    limit_station_no CHAR(2),
    limit_station_name CHAR(10),
    direction_name CHAR(10),
    arrive_time CHAR(4) NOT NULL,
    start_time CHAR(4) NOT NULL,
    yz_count SMALLINT,
    yw_count SMALLINT,
    rz_count SMALLINT,
    rw_count SMALLINT,
    wz_count SMALLINT,
    --- IMPORTANT 
    index(station_telecode,train_date,train_no,direction_name,limit_station_name) USING BTREE,
    index(train_code) USING BTREE
  ) ENGINE=MEMORY;
  truncate table tt_WJK_LEFT_remain_ticket;






  SET assign_station_in = ltrim(rtrim(assign_station_in));

  --- right? the DG30_my_center just have one row?
  select   DG30_my_center.my_center_code
  INTO my_center_code
  from center.DG30_my_center;

  --- into one if
  IF oi_train_days_in IS NULL or (oi_train_days_in <= 0) then
    SET oi_train_days_in = 3;
  end if;
  IF os_purposes_in IS NULL or (os_purposes_in = '') then
    SET os_purposes_in = '00';
  end if;

  CREATE TEMPORARY TABLE IF not EXISTS  wjk_tt_tmp_seat_type_tmp
  AS
  select seat_type.seat_type_code,
  seat_type.seat_type_name,
  seat_type.belong_seat_type_code,
  seat_type.belong_seat_type_name,
  seat_type.print_seat_type_name,
  seat_type.display_seat_type_name
  from basic.seat_type;

  update wjk_tt_tmp_seat_type_tmp
  set wjk_tt_tmp_seat_type_tmp.belong_seat_type_code = '1',
  wjk_tt_tmp_seat_type_tmp.belong_seat_type_name = 'Ó²×ù'
  where wjk_tt_tmp_seat_type_tmp.seat_type_code = 'O'
  and wjk_tt_tmp_seat_type_tmp.belong_seat_type_name = 'Èí×ù';

  /* try with view or table with memory engine */
  /* create view wjk_tt_tmp_seat_type_tmp */
  /* AS */
  /* select seat_type.seat_type_code, */
  /* seat_type.seat_type_name, */
  /* IF(seat_type_code = 'O' and belong_seat_type_name = 'Èí×ù', 1, belong_seat_type_code), */
  /* IF(seat_type_code = 'O' and belong_seat_type_name = 'Ó²×ù', 1, belong_seat_type_name) as belong_seat_type_name , */
  /* seat_type.print_seat_type_name, */
  /* seat_type.display_seat_type_name */
  /* from basic.seat_type; */

  /* default_tmp_storage_engine=Memory; */


/*
  SET yz_types = '';
  SET pTypes = '1';
  SET @SWV_Error = 0;
  OPEN read_seattypes;
  IF @SWV_Error != 0 then
    LEAVE SWL_return;
  end if;
  SET NO_DATA = 0;

  FETCH read_seattypes INTO wz_types;

  WHILE NO_DATA != 2 DO
    IF NO_DATA = 1 then

      SET @SWV_Error = 30101;
      SET SWP_Ret_Value = -1;
      LEAVE SWL_return;
    end if;

    if out_flag=2 THEN
      select '5==loop cursor read_seattypes',yz_types,wz_types;
    end if;
    IF wz_types IS NOT NULL then
      SET yz_types = CONCAT(yz_types,wz_types);
    end if;
    SET NO_DATA = 0;
    FETCH read_seattypes INTO wz_types;
  END WHILE;
  CLOSE read_seattypes;

  SET yw_types = '';
  SET pTypes = '35';
  SET @SWV_Error = 0;
  OPEN read_seattypes;

  IF @SWV_Error != 0 then
    LEAVE SWL_return;
  end if;
  SET NO_DATA = 0;
  FETCH read_seattypes INTO wz_types;
  WHILE NO_DATA != 2 DO
    IF NO_DATA = 1 then

      SET @SWV_Error = 30102;
      SET SWP_Ret_Value = -1;
      LEAVE SWL_return;
    end if;
    if out_flag=2 THEN
      select '6==loop cursor read_seattypes',yw_types,wz_types;
    end if;
    IF wz_types IS NOT NULL then
      SET yw_types = CONCAT(yw_types,wz_types);
    end if;
    SET NO_DATA = 0;
    FETCH read_seattypes INTO wz_types;
  END WHILE;
  CLOSE read_seattypes;

  SET rz_types = '';
  SET pTypes = '2';
  SET @SWV_Error = 0;
  OPEN read_seattypes;
  IF @SWV_Error != 0 then
    LEAVE SWL_return;
  end if;
  SET NO_DATA = 0;
  FETCH read_seattypes INTO wz_types;
  WHILE NO_DATA != 2 DO
    IF NO_DATA = 1 then

      SET @SWV_Error = 30103;
      SET SWP_Ret_Value = -1;
      LEAVE SWL_return;
    end if;
    if out_flag=2 THEN
      select '7==loop cursor read_seattypes',rz_types,wz_types;
    end if;
    IF wz_types IS NOT NULL then
      SET rz_types = CONCAT(rz_types,wz_types);
    end if;
    SET NO_DATA = 0;
    FETCH read_seattypes INTO wz_types;
  END WHILE;
  CLOSE read_seattypes;

  SET rw_types = '';
  SET pTypes = '46';
  SET @SWV_Error = 0;
  OPEN read_seattypes;
  IF @SWV_Error != 0 then
    LEAVE SWL_return;
  end if;
  SET NO_DATA = 0;
  FETCH read_seattypes INTO wz_types;
  WHILE NO_DATA != 2 DO
    IF NO_DATA = 1 then

      SET @SWV_Error = 30104;
      SET SWP_Ret_Value = -1;
      LEAVE SWL_return;
    end if;
    if out_flag=2 THEN
      select '8==loop cursor read_seattypes',rw_types,wz_types;
    end if;
    IF wz_types IS NOT NULL then
      SET rw_types = CONCAT(rw_types,wz_types);
    end if;
    SET NO_DATA = 0;
    FETCH read_seattypes INTO wz_types;
  END WHILE;
  CLOSE read_seattypes;
*/

  SET be_types = '';
  SET yz_types = '';
  SET yw_types = '';
  SET rz_types = '';
  SET rw_types = '';
  SET pTypes = '46';
  OPEN read_seattypes;
  SET NO_DATA = 0;
  FETCH read_seattypes INTO wz_types, be_types;
  WHILE NO_DATA != 2 DO
    CASE
      WHEN be_types = '1' THEN SET yz_types = CONCAT_WS(yz_types,wz_types);
      WHEN be_types = '2' THEN SET rz_types = CONCAT_WS(rz_types,wz_types);
      WHEN be_types in ('3', '5') THEN SET yw_types = CONCAT_WS(yw_types,wz_types);
      WHEN be_types in ('4', '6') THEN SET rw_types = CONCAT_WS(rw_types,wz_types);
    END CASE;
    SET NO_DATA = 0;
    FETCH read_seattypes INTO wz_types;
  END WHILE;
  CLOSE read_seattypes;

  SET wz_types = 'W';



  CREATE TEMPORARY TABLE IF not EXISTS wjk_tt_tmp_stop_time
  (
    tmp_train_no CHAR(12) NOT NULL,
    tmp_station_no CHAR(2) NOT NULL,
    tmp_start_date CHAR(12) NOT NULL,
    tmp_stop_date CHAR(12) NOT NULL,
    tmp_arrive_time CHAR(4) NOT NULL,
    tmp_start_time CHAR(4) NOT NULL,
    tmp_station_telecode CHAR(3) NOT NULL,
    tmp_station_train_code CHAR(8) NOT NULL,
    tmp_day_difference SMALLINT,
    tmp_start_station_name CHAR(10),
    tmp_end_station_name CHAR(10),
    tmp_count SMALLINT,
    unique index tt_tmp_stop_time_idx (tmp_train_no)
  );
  truncate table wjk_tt_tmp_stop_time;




  CREATE TEMPORARY TABLE IF not EXISTS wjk_tt_tmp_stoptime
  (
    tmp_train_no CHAR(12) NOT NULL,
    tmp_station_no CHAR(2) NOT NULL,
    tmp_start_date CHAR(12) NOT NULL,
    tmp_stop_date CHAR(12) NOT NULL,
    tmp_arrive_time CHAR(4) NOT NULL,
    tmp_start_time CHAR(4) NOT NULL,
    tmp_station_telecode CHAR(3) NOT NULL,
    tmp_station_train_code CHAR(8) NOT NULL,
    tmp_day_difference SMALLINT,
    tmp_start_station_name CHAR(10),
    tmp_end_station_name CHAR(10),
    tmp_count SMALLINT,
    unique index tt_tmp_stop_time_idx1 (tmp_train_no)
  );
  truncate table wjk_tt_tmp_stoptime;




  CREATE TEMPORARY TABLE IF not EXISTS wjk_tt_tmp_center_notice
  AS
  SELECT 	CJ30_center_notice.operate_time,
  CJ30_center_notice.start_date,
  CJ30_center_notice.stop_date,
  CJ30_center_notice.train_no,
  CJ30_center_notice.station_no,
  CJ30_center_notice.station_telecode,
  CJ30_center_notice.station_name,
  CJ30_center_notice.board_train_code,
  CJ30_center_notice.command_code,
  CJ30_center_notice.day_difference,
  CJ30_center_notice.arrive_time,
  CJ30_center_notice.start_time,
  CJ30_center_notice.time_interval,
  CJ30_center_notice.running_style,
  CJ30_center_notice.running_rule
  FROM basic.CJ30_center_notice  WHERE 1 = 2;

  truncate table wjk_tt_tmp_center_notice;


  SET c_today = DATE_FORMAT(CURRENT_TIMESTAMP,'%Y%m%d');
  SET c_date = DATE_FORMAT(now(),'%H%i');
  SET c_date1 = left(c_date,2);
  SET c_date2 = right(c_date,2);
  SET c_current_date = CONCAT(c_date1,c_date2);
  SET c_tmp_date = DATE_FORMAT(TIMESTAMPADD(day,(oi_train_days_in -1),c_today),'%Y%m%d');
  SET temp_date = DATE_FORMAT(CURRENT_TIMESTAMP,'%Y%m%d');

--- this insert will be slow. REMOVE LOCATE? remove the temporary table ?
  insert into wjk_tt_tmp_center_notice
  select CJ30_center_notice.operate_time,
  CJ30_center_notice.start_date,
  CJ30_center_notice.stop_date,
  CJ30_center_notice.train_no,
  CJ30_center_notice.station_no,
  CJ30_center_notice.station_telecode,
  CJ30_center_notice.station_name,
  CJ30_center_notice.board_train_code,
  CJ30_center_notice.command_code,
  CJ30_center_notice.day_difference,
  CJ30_center_notice.arrive_time,
  CJ30_center_notice.start_time,
  CJ30_center_notice.time_interval,
  CJ30_center_notice.running_style,
  CJ30_center_notice.running_rule
  from basic.CJ30_center_notice
  where LOCATE(CJ30_center_notice.station_telecode,assign_station_in) > 0
  and CJ30_center_notice.stop_date >= c_today
  and CJ30_center_notice.start_date <= c_tmp_date
  and CJ30_center_notice.command_enable = 0
  and LOCATE(CJ30_center_notice.command_code,'P') > 0;


  if out_flag=2 then
    select '9=== is here';
  end if;

  SET tmp_no = 1;

  SET assign_station_in_len = LENGTH(assign_station_in)/3;
  WHILE tmp_no <= assign_station_in_len DO
    SET single_assign_station = SUBSTRING(assign_station_in,3*tmp_no -2,3);
    select   station_dictionary.station_name,
    station_dictionary.bureau_code
    INTO assign_station_name,
    my_bureau_code
    from basic.station_dictionary
    where station_dictionary.station_telecode = single_assign_station;

    --- IMPORTANT: try to remove wjk_tt_tmp_stop_time
    truncate table wjk_tt_tmp_stop_time;
    if plan_train_no_in = '%' then

      insert into wjk_tt_tmp_stop_time
      select distinct stop_time.train_no,
      stop_time.station_no,
      stop_time.start_date,
      stop_time.stop_date,
      stop_time.arrive_time,
      stop_time.start_time,
      stop_time.station_telecode,
      stop_time.station_train_code,
      stop_time.day_difference,
      '',
      '',
      0
      from basic.stop_time
      where stop_time.station_telecode = single_assign_station
      and stop_time.station_name NOT REGEXP '[\\_|\\*|-].*'

      AND stop_time.stop_date >= DATE_FORMAT(TIMESTAMPADD(DAY,0 -cast(day_difference as signed),c_today),'%Y%m%d')
      AND	stop_time.train_no not in(select CONCAT(train_dir.subbureau_code,right(CONCAT("00000000",rtrim(train_dir.train_code)),8),train_dir.double_id,train_dir.schema_id)
        from basic.train_dir
        where train_dir.end_station_name = assign_station_name

      );
      if out_flag=2 then
        select '22_1====select * from wjk_tt_tmp_stop_time limit 10';
        select * from wjk_tt_tmp_stop_time ;
      end if;
    else
      insert into wjk_tt_tmp_stop_time
      select distinct stop_time.train_no,
      stop_time.station_no,
      stop_time.start_date,
      stop_time.stop_date,
      stop_time.arrive_time,
      stop_time.start_time,
      stop_time.station_telecode,
      stop_time.station_train_code,
      stop_time.day_difference,
      '',
      '',
      0
      from basic.stop_time
      where stop_time.train_no = plan_train_no_in
      and stop_time.station_telecode = single_assign_station
      and stop_time.station_name NOT REGEXP '[\\_|\\*|-].*'

      AND stop_time.stop_date >= DATE_FORMAT(TIMESTAMPADD(DAY,0 -cast(day_difference as signed),c_today),'%Y%m%d')
      AND	stop_time.train_no not in(select CONCAT(train_dir.subbureau_code,right(CONCAT("00000000",rtrim(train_dir.train_code)),8),train_dir.double_id,train_dir.schema_id)
        from basic.train_dir where train_dir.end_station_name = assign_station_name

      );
      if out_flag=2 then
        select '22_2====select * from wjk_tt_tmp_stop_time limit 10';

      end if;
    end if;
    --- Error? ns_train_no not inited
    SET ns_train_code = SUBSTRING(ns_train_no,3,8);

    --- IMPORTANT use trim instead of WHILE
    SET ns_train_code = TRIM(LEADING '0' FROM ns_train_code);
    /* WHILE LEFT(ns_train_code,1) = '0' DO */
    /*   SET SWV_ns_train_code_Str = SUBSTRING(ns_train_code,2,8); */
    /*   SET ns_train_code = SWV_ns_train_code_Str; */
    /* END WHILE; */
    select   station_dictionary.bureau_code
    INTO bureau_code
    FROM basic.station_dictionary
    WHERE station_dictionary.station_telecode = single_assign_station;

    open cur_train;

    SET NO_DATA = 0;
    fetch cur_train into ns_train_no,ns_start_station_name,ns_end_station_name;
    while NO_DATA != 2 DO
      if NO_DATA = 1 then

        SET @SWV_Error = 30111;
        SET SWP_Ret_Value = -1;
        LEAVE SWL_return;
      end if;
      if out_flag=3 then
        select '10=== open cursor cur_train ',ns_train_no,ns_start_station_name,ns_end_station_name;
      end if;
      SET ns_train_code = SUBSTRING(ns_train_no,3,8);

      --- IMPORTANT use TRIM instead of WHILE
      SET ns_train_code = TRIM(LEADING '0' FROM ns_train_code);
      /* WHILE LOCATE('0',ns_train_code) = 1 DO */
      /*   SET SWV_ns_train_code_Str = SUBSTRING(ns_train_code,2,8); */
      /*   SET ns_train_code = SWV_ns_train_code_Str; */
      /* END WHILE; */
      select   train_dir.start_station_name,
      train_dir.end_station_name
      INTO ns_start_station_name,
      ns_end_station_name
      FROM basic.train_dir
      WHERE train_dir.train_code = ns_train_code
      and train_dir.subbureau_code = SUBSTRING(ns_train_no,1,2)
      and train_dir.double_id = SUBSTRING(ns_train_no,11,1)
      and train_dir.schema_id = SUBSTRING(ns_train_no,12,1);
      IF @SWV_Error != 0 then
        LEAVE SWL_return;
      end if;
      if out_flag=3 then
        select '11=== is here ',ns_train_no,ns_start_station_name,ns_end_station_name,my_bureau_code,c_tmp_date,c_today;
      end if;
      if not exists(select 1 from basic.DG50_train_location_auth
        where DG50_train_location_auth.train_code = ns_train_code
        and DG50_train_location_auth.start_station_telecode in(select station_dictionary.station_telecode
          from basic.station_dictionary
          where station_dictionary.station_name = ns_start_station_name)

        and DG50_train_location_auth.end_station_telecode in(select station_dictionary.station_telecode
          from basic.station_dictionary
          where station_dictionary.station_name = ns_end_station_name)

        and DG50_train_location_auth.bureau_code = my_bureau_code
        AND DG50_train_location_auth.start_date <= c_tmp_date
        AND DG50_train_location_auth.stop_date >= c_today limit 1) then

        SET ns_location_code = '00';
        if not exists(select 1 from basic.DG50_train_location_auth
          where DG50_train_location_auth.train_code = ns_train_code
          and DG50_train_location_auth.start_station_telecode in(select station_dictionary.station_telecode
            from basic.station_dictionary
            where station_dictionary.station_name = ns_start_station_name)

          and DG50_train_location_auth.end_station_telecode in(select station_dictionary.station_telecode
            from basic.station_dictionary
            where station_dictionary.station_name = ns_end_station_name)

          AND DG50_train_location_auth.start_date <= c_tmp_date
          AND DG50_train_location_auth.stop_date >= c_today   ) then
          select   on_net_station.area_center_code
          INTO ns_location_code
          from basic.on_net_station
          where on_net_station.station_telecode = single_assign_station;
        end if;





        update wjk_tt_tmp_stop_time
        set tmp_start_station_name = ns_start_station_name,
        tmp_end_station_name = ns_end_station_name
        WHERE wjk_tt_tmp_stop_time.tmp_train_no = ns_train_no;
      else
        update wjk_tt_tmp_stop_time
        set tmp_start_station_name = ns_start_station_name,
        tmp_end_station_name = ns_end_station_name
        WHERE wjk_tt_tmp_stop_time.tmp_train_no = ns_train_no;
      end if;
      SET NO_DATA = 0;
      fetch cur_train into ns_train_no,ns_start_station_name,ns_end_station_name;
    END WHILE;
    close cur_train;

    if plan_train_date_in <> '' then
      SET oi_train_days_in = 1;
    end if;

    truncate table wjk_tt_train_info;
    truncate table wjk_tt_tmp_left_base_center;
    SET ni_day = 0;


    if plan_train_date_in <> '' then
      SET control_day = 0;
    end if;

    while (ni_day < control_day+1) DO
      SET ns_train_date = DATE_FORMAT(TIMESTAMPADD(day,ni_day,CURRENT_TIMESTAMP),'%Y%m%d');
      if out_flag=2 and ni_day<5 then
        select '21_1===',ns_train_date;
      end if;
      if plan_train_date_in <> '' then
        SET ns_train_date = plan_train_date_in;
      end if;
      truncate table wjk_tt_train_info;

      if ns_train_date between date_range_n_begin  and date_range_n_end
        or 	ns_train_date between date_range_f_begin and date_range_f_end then

        insert into wjk_tt_train_info
        select distinct ns_train_date,
        wjk_tt_tmp_stop_time.tmp_train_no,
        '',
        single_assign_station,
        '%'
        from wjk_tt_tmp_stop_time
        where wjk_tt_tmp_stop_time.tmp_station_telecode = single_assign_station
        AND wjk_tt_tmp_stop_time.tmp_start_date <= DATE_FORMAT(TIMESTAMPADD(DAY,0 -cast(wjk_tt_tmp_stop_time.tmp_day_difference as signed),ns_train_date),'%Y%m%d')
        AND wjk_tt_tmp_stop_time.tmp_stop_date >= DATE_FORMAT(TIMESTAMPADD(DAY,0 -cast(wjk_tt_tmp_stop_time.tmp_day_difference as signed),ns_train_date),'%Y%m%d');
      end if;
      if out_flag=2 and  ni_day<5 then

        select '21====,select * from wjk_tt_train_info limit 10;';

      end if;
      UPDATE wjk_tt_train_info
      SET wjk_tt_train_info.train_code =(CASE WHEN SUBSTRING(wjk_tt_train_info.train_no,3,6) = '000000' THEN SUBSTRING(wjk_tt_train_info.train_no,9,2)
      WHEN SUBSTRING(wjk_tt_train_info.train_no,3,5) = '00000'  THEN SUBSTRING(wjk_tt_train_info.train_no,8,3)
      WHEN SUBSTRING(wjk_tt_train_info.train_no,3,4) = '0000' 	THEN SUBSTRING(wjk_tt_train_info.train_no,7,4)
      WHEN SUBSTRING(wjk_tt_train_info.train_no,3,3) = '000' 	THEN SUBSTRING(wjk_tt_train_info.train_no,6,5)
      WHEN SUBSTRING(wjk_tt_train_info.train_no,3,2) = '00' 	THEN SUBSTRING(wjk_tt_train_info.train_no,5,6)
      WHEN SUBSTRING(wjk_tt_train_info.train_no,3,1) = '0' 		THEN SUBSTRING(wjk_tt_train_info.train_no,4,7)
      ELSE wjk_tt_train_info.train_no
                    END);

                  begin
                    declare cp_start_time datetime;
                    declare cp_end_time datetime;
                    if out_flag=2  then



                      select concat('1====call arith.DS60_ticket_left(wjk_tt_train_info,\'',os_purposes_in,'\',\'',single_assign_station,'\',4,\'A\',\'wjk_tt_tmp_left_base_center\',0,1,1,@return_out);');
                      select * from wjk_tt_train_info;

                      set cp_start_time=now();
                    end if;
                    CALL arith.DS60_ticket_left('wjk_tt_train_info',
                      os_purposes_in,
                      single_assign_station,
                      4,
                      'A',
                      'wjk_tt_tmp_left_base_center',
                      0,
                      1,
                      1,
                      return_out);
                    if out_flag=2 and  ni_day<5 then


                      select '1===end call arith.DS60_ticket_left finish,execute time:',TIMESTAMPDIFF(second,cp_start_time,cp_end_time);

                  end if;
              end ;
              SET ni_day = ni_day+1;
    END WHILE;

    truncate table wjk_tt_tmp_stoptime;

    insert into wjk_tt_tmp_stoptime
    select wjk_tt_tmp_stop_time.tmp_train_no,
    wjk_tt_tmp_stop_time.tmp_station_no,
    wjk_tt_tmp_stop_time.tmp_start_date,
    wjk_tt_tmp_stop_time.tmp_stop_date,
    wjk_tt_tmp_stop_time.tmp_arrive_time,
    wjk_tt_tmp_stop_time.tmp_start_time,
    wjk_tt_tmp_stop_time.tmp_station_telecode,
    wjk_tt_tmp_stop_time.tmp_station_train_code,
    wjk_tt_tmp_stop_time.tmp_day_difference,
    wjk_tt_tmp_stop_time.tmp_start_station_name,
    wjk_tt_tmp_stop_time.tmp_end_station_name,
    wjk_tt_tmp_stop_time.tmp_count
    from wjk_tt_tmp_stop_time;
    if out_flag=2 then
      select '11=== select * from wjk_tt_tmp_left_base_center;';
      select * from wjk_tt_tmp_left_base_center order by wjk_tt_tmp_left_base_center.train_no,wjk_tt_tmp_left_base_center.train_date,wjk_tt_tmp_left_base_center.station_no,wjk_tt_tmp_left_base_center.far_from_station_no,wjk_tt_tmp_left_base_center.limit_station,wjk_tt_tmp_left_base_center.coach_no,wjk_tt_tmp_left_base_center.seat_type_code,wjk_tt_tmp_left_base_center.purpose_code,wjk_tt_tmp_left_base_center.ticket_quantity;
      select * from wjk_tt_tmp_stoptime order by tmp_train_no;
    end if;
    while exists(select 1 from wjk_tt_tmp_stoptime limit 1) DO
      begin
        select   tmp_train_no,
        tmp_station_no,
        tmp_arrive_time,
        tmp_start_time,
        tmp_station_telecode,
        tmp_station_train_code,
        tmp_start_station_name,
        tmp_end_station_name
        INTO ns_train_no,
        ns_station_no,
        ns_arrive_time,
        ns_start_time,
        ns_station_telecode,
        ns_station_train_code,
        ns_start_station_name,
        ns_end_station_name
        from wjk_tt_tmp_stoptime
        LIMIT 1;
        delete from wjk_tt_tmp_stoptime LIMIT 1;

        SET ni_day = 0;




        while (ni_day < control_day+1) DO
          begin

            step_two:loop
            BEGIN
              step_one:loop
              BEGIN
                SET ns_train_date = DATE_FORMAT(TIMESTAMPADD(day,ni_day,CURRENT_TIMESTAMP),'%Y%m%d');
                if plan_train_date_in <> '' then
                  SET ns_train_date = plan_train_date_in;
                end if;

                if not exists(select 1 from wjk_tt_tmp_left_base_center
                  where wjk_tt_tmp_left_base_center.train_no = ns_train_no
                  and wjk_tt_tmp_left_base_center.train_date = ns_train_date limit 1)
                  then

                  SET yz_count = -1;
                  SET rz_count = -1;
                  SET yw_count = -1;
                  SET rw_count = -1;
                  SET wz_count = -1;
                  LEAVE step_two;
                end if;
                SET ns_train_code = SUBSTRING(ns_train_no,3,8);
                --- IMPORTANT use trim instead of LOCATE
                SET ns_train_code = TRIM(LEADING '0' FROM ns_train_code);
                /* WHILE LOCATE('0',ns_train_code) = 1 DO */
                /*   SET SWV_ns_train_code_Str = SUBSTRING(ns_train_code,2,8); */
                /*   SET ns_train_code = SWV_ns_train_code_Str; */
                /* END WHILE; */
                SET i = -1;
                SET j = 1;
                select   count(*)
                INTO seat_type_count
                from wjk_tt_tmp_seat_type_tmp;

                select   train_dir.seat_types
                INTO seat_types
                from basic.train_dir
                where train_dir.subbureau_code = SUBSTRING(ns_train_no,1,2)
                and train_dir.train_code = ns_train_code
                and train_dir.double_id = SUBSTRING(ns_train_no,11,1)
                and train_dir.schema_id = SUBSTRING(ns_train_no,12,1);
                SET yz_yn = 'n';
                SET rz_yn = 'n';
                SET yw_yn = 'n';
                SET rw_yn = 'n';
                SET wz_yn = 'n';

                SET seat_type_string = '';
                SET seat_type = '';

                SWL_Label13:
                while i < seat_type_count DO

                  SET i = i+1;
                  SET j = j*2;
                  if i = 0 then
                    SET j = 1;
                  end if;
                  if(seat_types & j) = 0 then
                    ITERATE SWL_Label13;
                  end if;
                  if i = 23 then
                    SET i = 24;
                  end if;
                  if i < 10 then
                    SET seat_type = CAST(i AS char(1));
                  else
                    SET seat_type = char(i+55);
                  end if;
                  SET seat_type_string = CONCAT(seat_type_string,seat_type);

                  select   wjk_tt_tmp_seat_type_tmp.belong_seat_type_code,
                  wjk_tt_tmp_seat_type_tmp.seat_type_name
                  INTO seat_type_belong,
                  seat_name
                  from wjk_tt_tmp_seat_type_tmp
                  where wjk_tt_tmp_seat_type_tmp.seat_type_code = seat_type;

                  if (seat_type_belong in('1')) then
                    SET yz_yn = 'y';
                  end if;
                  if (seat_type_belong in('2')) then
                    SET rz_yn = 'y';
                  end if;
                  if (seat_type_belong in('3','5')) then
                    SET yw_yn = 'y';
                  end if;
                  if (seat_type_belong in('4','6')) then
                    SET rw_yn = 'y';
                  end if;
                  if (wz_types = 'W') then
                    SET wz_yn = 'y';
                  end if;
                END WHILE SWL_Label13;


                select   station_dictionary.station_name
                INTO c_station_name
                from basic.station_dictionary
                where station_dictionary.station_telecode = ns_station_telecode;

                SET c1_station_name = c_station_name;
                SET c_station_name = CONCAT(ltrim(rtrim(c_station_name)),"Õ¾");

                select distinct  CG40_station_group_train.direction_code
                INTO ns_direction_code
                from basic.CG40_station_group_train
                where CG40_station_group_train.train_code = ns_train_code
                and ( (CG40_station_group_train.station_name = c_station_name) or (CG40_station_group_train.station_name = c1_station_name));

                IF @SWV_Error != 0 then
                  LEAVE SWL_return;
                end if;
                if ns_direction_code IS NULL then
                  SET ns_direction_name = " ";
                else

                  select   direction.direction_name
                  INTO ns_direction_name
                  from center.direction
                  where direction.inner_code = ns_station_telecode
                  and direction.direction_code = ns_direction_code;

                  if @SWV_Error != 0 then
                    LEAVE SWL_return;
                  end if;
                  if ns_direction_name IS NULL then
                    SET ns_direction_name = " ";
                  end if;
                end if;
                if exists(select 1 from wjk_tt_tmp_center_notice
                  where wjk_tt_tmp_center_notice.start_date <= ns_train_date
                  and wjk_tt_tmp_center_notice.stop_date >= ns_train_date
                  and wjk_tt_tmp_center_notice.station_telecode = single_assign_station
                  and wjk_tt_tmp_center_notice.train_no = ns_train_no limit 1)
                  then

                  open cur_notice;
                  SET NO_DATA = 0;
                  fetch cur_notice into nc_operate_time,nc_start_date,nc_stop_date,nc_train_no,nc_station_no,nc_station_telecode,
                  nc_station_name,nc_board_train_code,nc_command_code,
                  nc_day_difference,nc_arrive_time,nc_start_time,nc_time_interval,nc_running_style,
                  nc_running_rule;
                  while NO_DATA != 2 DO
                    if NO_DATA = 1 then

                      SET @SWV_Error = 30111;
                      SET SWP_Ret_Value = -1;
                      LEAVE SWL_return;
                    end if;
                    if out_flag=2 then
                      select '16====open cursor ',nc_operate_time,nc_start_date,nc_stop_date,nc_train_no,nc_station_no,nc_station_telecode,
                      nc_station_name,nc_board_train_code,nc_command_code,
                      nc_day_difference,nc_arrive_time,nc_start_time,nc_time_interval,nc_running_style,
                      nc_running_rule;
                    end if;
                    call arith.CJ30_check_running(ns_train_date,'0',0,single_assign_station,ns_train_date,ns_train_date,
                      nc_running_style,nc_running_rule,0,0,return_out);
                    SET ret_code = return_out;
                    IF ret_code > 0 then
                      SET ns_start_time = nc_start_time;
                    end if;
                    SET NO_DATA = 0;
                    fetch cur_notice into nc_operate_time,nc_start_date,nc_stop_date,nc_train_no,nc_station_no,nc_station_telecode,
                    nc_station_name,nc_board_train_code,nc_command_code,
                    nc_day_difference,nc_arrive_time,nc_start_time,nc_time_interval,nc_running_style,
                    nc_running_rule;
                  END WHILE;
                  close cur_notice;
                end if;
                SET ns_limit_station_no = '00';
                SET ns_limit_station_name = ns_end_station_name;



                select   stop_time.day_difference
                INTO from_day_diff
                from basic.stop_time
                where stop_time.train_no = ns_train_no
                and stop_time.station_telecode = single_assign_station;
                SET depart_date = DATE_FORMAT(TIMESTAMPADD(DAY,0 -from_day_diff,ns_train_date),'%Y%m%d');
                if out_flag=2 then
                  select '15_4====',ns_train_code,ns_start_station_name,ns_end_station_name,depart_date;
                end if;
                begin
                  declare tmp_row_count int;
                  select  count(*)-1 INTO tmp_row_count
                  from basic.train_dir
                  where train_dir.train_code = ns_train_code
                  and train_dir.start_station_name = ns_start_station_name
                  and train_dir.end_station_name = ns_end_station_name
                  and train_dir.stop_date >= depart_date
                  and train_dir.start_date <= depart_date;
                  select   CONCAT(train_dir.subbureau_code,lpad(rtrim(train_dir.train_code),8,'0'),train_dir.double_id,train_dir.schema_id)
                  INTO train_no
                  from basic.train_dir
                  where train_dir.train_code = ns_train_code
                  and train_dir.start_station_name = ns_start_station_name
                  and train_dir.end_station_name = ns_end_station_name
                  and train_dir.stop_date >= depart_date
                  and train_dir.start_date <= depart_date limit tmp_row_count, 1;
                end;

                select   station_dictionary.station_telecode
                INTO end_station_telecode
                from basic.station_dictionary
                where station_dictionary.station_name = ns_end_station_name;

                SET c_train_no = ns_train_code;
                SET return_code = 0;
                if out_flag=2 then
                  select '17_1====call arith.CJ30_train_code',ns_train_date,c_train_no,single_assign_station,out_flag;
                end if;
                begin
                  declare oo_single_assign_station varchar(20);
                  set oo_single_assign_station = single_assign_station;
                  -- IMPORTANT optimize the PROC
                  CALL arith.CJ30_train_code(ns_train_date,c_train_no,oo_single_assign_station,out_flag,'',return_out);
                end;
                if out_flag=2 then
                  select '17_2===end call arith.CJ30_train_code',ns_train_date,c_train_no,single_assign_station,out_flag;
                end if;
                if c_train_no <> '000000000000' then

                  select   max(stop_time.station_no)
                  INTO ll_max_station_no
                  from basic.stop_time
                  where stop_time.train_no = c_train_no;

                  select   stop_time.station_telecode
                  INTO ll_end_station_telecode
                  from basic.stop_time
                  where stop_time.train_no = c_train_no
                  and stop_time.station_no = ll_max_station_no;

                  if ll_end_station_telecode <> end_station_telecode then
                    SET c_train_no = '000000000000';
                  end if;
                end if;

                if c_train_no = '000000000000' or c_train_no <> train_no then

                  SET c_train_no = '000000000000';
                end if;



                if c_train_no = '000000000000' then

                  SET yz_count = -1;
                  SET yw_count = -1;
                  SET rz_count = -1;
                  SET rw_count = -1;
                  SET wz_count = -1;
                  LEAVE step_two;
                else
                  if ns_train_date = c_today and ns_start_time < c_current_date then

                    SET yz_count = -2;
                    SET yw_count = -2;
                    SET rz_count = -2;
                    SET rw_count = -2;
                    SET wz_count = -2;
                    LEAVE step_one;
                  end if;
                end if;
                if flag_in in(0,2) then

                  select   max(stop_time.station_no)
                  INTO ns_limit_station_no
                  from basic.stop_time
                  where stop_time.train_no = ns_train_no;

                  if @SWV_Error != 0 then
                    LEAVE SWL_return;
                  end if;
                  if ns_limit_station_no IS NULL then
                    SET ns_limit_station_no = '00';
                  end if;
                  SET ns_limit_station_name = ns_end_station_name;
                  if (yz_yn = 'n') then
                    SET yz_count = -3;
                  else
                    select   sum(wjk_tt_tmp_left_base_center.ticket_quantity)
                    INTO yz_count
                    from wjk_tt_tmp_left_base_center
                    where wjk_tt_tmp_left_base_center.train_no = ns_train_no
                    and wjk_tt_tmp_left_base_center.train_date = ns_train_date
                    and wjk_tt_tmp_left_base_center.limit_station = ns_limit_station_no
                    and LOCATE(wjk_tt_tmp_left_base_center.seat_type_code,yz_types) > 0;
                    if @SWV_Error != 0 then
                      LEAVE SWL_return;
                    end if;
                    if (yz_count IS NULL or yz_count <= 0) then
                      SET yz_count = 0;
                    end if;
                  end if;
                  if (yw_yn = 'n') then
                    SET yw_count = -3;
                  else
                    select   sum(wjk_tt_tmp_left_base_center.ticket_quantity)
                    INTO yw_count
                    from wjk_tt_tmp_left_base_center
                    where wjk_tt_tmp_left_base_center.train_no = ns_train_no
                    and wjk_tt_tmp_left_base_center.train_date = ns_train_date
                    and wjk_tt_tmp_left_base_center.limit_station = ns_limit_station_no
                    and LOCATE(wjk_tt_tmp_left_base_center.seat_type_code,yw_types) > 0;
                    if @SWV_Error != 0 then
                      LEAVE SWL_return;
                    end if;
                    if (yw_count IS NULL or yw_count <= 0) then
                      SET yw_count = 0;
                    end if;
                  end if;
                  if (rz_yn = 'n') then
                    SET rz_count = -3;
                  else
                    select   sum(wjk_tt_tmp_left_base_center.ticket_quantity)
                    INTO rz_count
                    from wjk_tt_tmp_left_base_center
                    where wjk_tt_tmp_left_base_center.train_no = ns_train_no
                    and wjk_tt_tmp_left_base_center.train_date = ns_train_date
                    and  wjk_tt_tmp_left_base_center.limit_station = ns_limit_station_no
                    and LOCATE(wjk_tt_tmp_left_base_center.seat_type_code,rz_types) > 0;
                    if @SWV_Error != 0 then
                      LEAVE SWL_return;
                    end if;
                    if (rz_count IS NULL or rz_count <= 0) then
                      SET rz_count = 0;
                    end if;
                  end if;
                  if (rw_yn = 'n') then
                    SET rw_count = -3;
                  else
                    select   sum(wjk_tt_tmp_left_base_center.ticket_quantity)
                    INTO rw_count
                    from wjk_tt_tmp_left_base_center
                    where wjk_tt_tmp_left_base_center.train_no = ns_train_no
                    and wjk_tt_tmp_left_base_center.train_date = ns_train_date
                    and wjk_tt_tmp_left_base_center.limit_station = ns_limit_station_no
                    and LOCATE(wjk_tt_tmp_left_base_center.seat_type_code,rw_types) > 0;
                    if @SWV_Error != 0 then
                      LEAVE SWL_return;
                    end if;
                    if (rw_count IS NULL or rw_count <= 0) then
                      SET rw_count = 0;
                    end if;
                  end if;
                  if (wz_yn = 'n') then
                    SET wz_count = -3;
                  else
                    select   sum(wjk_tt_tmp_left_base_center.ticket_quantity)
                    INTO wz_count
                    from wjk_tt_tmp_left_base_center
                    where wjk_tt_tmp_left_base_center.train_no = ns_train_no
                    and wjk_tt_tmp_left_base_center.train_date = ns_train_date
                    and  wjk_tt_tmp_left_base_center.limit_station = ns_limit_station_no
                    and LOCATE(wjk_tt_tmp_left_base_center.seat_type_code,wz_types) > 0;
                    if @SWV_Error != 0 then
                      LEAVE SWL_return;
                    end if;
                    if (wz_count IS NULL or wz_count <= 0) then
                      SET wz_count = 0;
                    end if;
                  end if;
                  LEAVE step_one;
                else
                  if not exists(select 1 from wjk_tt_tmp_left_base_center
                    where wjk_tt_tmp_left_base_center.train_date = ns_train_date
                    and wjk_tt_tmp_left_base_center.train_no = ns_train_no limit 1)
                    then

                    if (yz_yn = 'n') then
                      SET yz_count = -3;
                    else
                      SET yz_count = 0;
                    end if;
                    if (rz_yn = 'n') then
                      SET rz_count = -3;
                    else
                      SET rz_count = 0;
                    end if;
                    if (yw_yn = 'n') then
                      SET yw_count = -3;
                    else
                      SET yw_count = 0;
                    end if;
                    if (rw_yn = 'n') then
                      SET rw_count = -3;
                    else
                      SET rw_count = 0;
                    end if;
                    if (wz_yn = 'n') then
                      SET wz_count = -3;
                    else
                      SET wz_count = 0;
                    end if;
                    LEAVE step_one;
                  end if;
                  select   stop_time.station_no
                  INTO tmp_limit_station_no
                  from basic.stop_time
                  where stop_time.train_no = ns_train_no
                  and stop_time.station_telecode = single_assign_station
                  and stop_time.start_date <= ns_train_date and stop_date >= ns_train_date;
                  if tmp_limit_station_no IS NULL then
                    SET tmp_limit_station_no = '00';
                  end if;
                  begin


                    DECLARE get_limit CURSOR FOR
                    SELECT distinct limit_station
                    FROM wjk_tt_tmp_left_base_center
                    where wjk_tt_tmp_left_base_center.train_date = ns_train_date
                    and wjk_tt_tmp_left_base_center.train_no = ns_train_no
                    and wjk_tt_tmp_left_base_center.limit_station > tmp_limit_station_no;

                    OPEN get_limit;
                    SET NO_DATA = 0;
                    FETCH get_limit INTO ns_limit_station_no;
                    while NO_DATA != 2 DO
                      if NO_DATA = 1 then

                        SET @SWV_Error = 30111;
                        SET SWP_Ret_Value = -1;
                        LEAVE SWL_return;
                      end if;

                      select   stop_time.station_name
                      INTO ns_limit_station_name
                      from basic.stop_time
                      where stop_time.train_no = ns_train_no
                      and stop_time.station_no = ns_limit_station_no;

                      if @SWV_Error != 0 then
                        LEAVE SWL_return;
                      end if;
                      if ns_limit_station_no IS NULL then
                        SET ns_limit_station_no = '00';
                      end if;
                      if ns_limit_station_name IS NULL then
                        SET ns_limit_station_name = ' ';
                      end if;

                      if (yz_yn = 'n') then
                        SET yz_count = -3;
                      else
                        select   sum(wjk_tt_tmp_left_base_center.ticket_quantity)
                        INTO yz_count
                        from wjk_tt_tmp_left_base_center
                        where wjk_tt_tmp_left_base_center.train_no = ns_train_no
                        and wjk_tt_tmp_left_base_center.train_date = ns_train_date
                        and  wjk_tt_tmp_left_base_center.limit_station = ns_limit_station_no
                        and LOCATE(wjk_tt_tmp_left_base_center.seat_type_code,yz_types) > 0;
                        if @SWV_Error != 0 then
                          LEAVE SWL_return;
                        end if;
                        if (yz_count IS NULL or yz_count <= 0) then
                          SET yz_count = 0;
                        end if;
                      end if;
                      if (yw_yn = 'n') then
                        SET yw_count = -3;
                      else
                        select   sum(wjk_tt_tmp_left_base_center.ticket_quantity)
                        INTO yw_count
                        from wjk_tt_tmp_left_base_center
                        where wjk_tt_tmp_left_base_center.train_no = ns_train_no
                        and wjk_tt_tmp_left_base_center.train_date = ns_train_date
                        and  wjk_tt_tmp_left_base_center.limit_station = ns_limit_station_no
                        and LOCATE(wjk_tt_tmp_left_base_center.seat_type_code,yw_types) > 0;
                        if @SWV_Error != 0 then
                          LEAVE SWL_return;
                        end if;
                        if (yw_count IS NULL or yw_count <= 0) then
                          SET yw_count = 0;
                        end if;
                      end if;
                      if (rz_yn = 'n') then
                        SET rz_count = -3;
                      else
                        select   sum(wjk_tt_tmp_left_base_center.ticket_quantity)
                        INTO rz_count
                        from wjk_tt_tmp_left_base_center
                        where wjk_tt_tmp_left_base_center.train_no = ns_train_no
                        and wjk_tt_tmp_left_base_center.train_date = ns_train_date
                        and  wjk_tt_tmp_left_base_center.limit_station = ns_limit_station_no
                        and LOCATE(wjk_tt_tmp_left_base_center.seat_type_code,rz_types) > 0;
                        if @SWV_Error != 0 then
                          LEAVE SWL_return;
                        end if;
                        if (rz_count IS NULL or rz_count <= 0) then
                          SET rz_count = 0;
                        end if;
                      end if;
                      if (rw_yn = 'n') then
                        SET rw_count = -3;
                      else
                        select   sum(wjk_tt_tmp_left_base_center.ticket_quantity)
                        INTO rw_count
                        from wjk_tt_tmp_left_base_center
                        where wjk_tt_tmp_left_base_center.train_no = ns_train_no
                        and wjk_tt_tmp_left_base_center.train_date = ns_train_date
                        and  wjk_tt_tmp_left_base_center.limit_station = ns_limit_station_no
                        and LOCATE(wjk_tt_tmp_left_base_center.seat_type_code,rw_types) > 0;
                        if @SWV_Error != 0 then
                          LEAVE SWL_return;
                        end if;
                        if (rw_count IS NULL or rw_count <= 0) then
                          SET rw_count = 0;
                        end if;
                      end if;
                      if (wz_yn = 'n') then
                        SET wz_count = -3;
                      else
                        select   sum(wjk_tt_tmp_left_base_center.ticket_quantity)
                        INTO wz_count
                        from wjk_tt_tmp_left_base_center
                        where wjk_tt_tmp_left_base_center.train_no = ns_train_no
                        and wjk_tt_tmp_left_base_center.train_date = ns_train_date
                        and  wjk_tt_tmp_left_base_center.limit_station = ns_limit_station_no
                        and LOCATE(wjk_tt_tmp_left_base_center.seat_type_code,wz_types) > 0;
                        if @SWV_Error != 0 then
                          LEAVE SWL_return;
                        end if;
                        if (wz_count IS NULL or wz_count <= 0) then
                          SET wz_count = 0;
                        end if;
                      end if;


                      insert into tt_WJK_LEFT_remain_ticket
                      values(ns_station_telecode,
                        ns_train_no,
                        ns_station_train_code,
                        ns_train_date,
                        ns_start_station_name,
                        ns_end_station_name,
                        ns_limit_station_no,
                        ns_limit_station_name,
                        ns_direction_name,
                        ns_arrive_time,
                        ns_start_time,
                        yz_count,
                        yw_count,
                        rz_count,
                        rw_count,
                        wz_count);

                      SET NO_DATA = 0;
                      FETCH get_limit INTO ns_limit_station_no;
                    END WHILE;
                    CLOSE get_limit;
                end;
                LEAVE step_two;
              end if;
              END;
              leave step_one;
              end loop step_one;

              insert into tt_WJK_LEFT_remain_ticket
              values(ns_station_telecode,
                ns_train_no,
                ns_station_train_code,
                ns_train_date,
                ns_start_station_name,
                ns_end_station_name,
                ns_limit_station_no,
                ns_limit_station_name,
                ns_direction_name,
                ns_arrive_time,
                ns_start_time,
                yz_count,
                yw_count,
                rz_count,
                rw_count,
                wz_count);


            END;
            leave step_two;
            end loop step_two;
            SET ni_day = ni_day+1;
          end;
        END WHILE;
      end;
    END WHILE;
    SET tmp_no = tmp_no+1;
  END WHILE;


  -- IMPORTANT : ADD INDEX
  CREATE TEMPORARY TABLE IF not EXISTS  wjk_tt_tmp
  AS
  select tt_WJK_LEFT_remain_ticket.train_code
  from tt_WJK_LEFT_remain_ticket
  group by tt_WJK_LEFT_remain_ticket.train_code
  having count(*) >= 2;


  open cur_dele;
  SET NO_DATA = 0;
  fetch cur_dele into tmp_train_code;
  while NO_DATA != 2 DO
    if NO_DATA = 1 then

      SET @SWV_Error = 30111;
      SET SWP_Ret_Value = -1;
      LEAVE SWL_return;
    end if;

    --- IMPORTANT add index
    delete FROM tt_WJK_LEFT_remain_ticket
    where tt_WJK_LEFT_remain_ticket.train_code = tmp_train_code
    and tt_WJK_LEFT_remain_ticket.yz_count = -1
    and tt_WJK_LEFT_remain_ticket.yw_count = -1
    and tt_WJK_LEFT_remain_ticket.rz_count = -1
    and tt_WJK_LEFT_remain_ticket.rw_count = -1
    and tt_WJK_LEFT_remain_ticket.wz_count = -1;
    SET NO_DATA = 0;
    fetch cur_dele into tmp_train_code;
  END WHILE;
  close cur_dele;

  if out_flag=2 then
    select '21====',assign_station_in;
  end if;
  if LOCATE('BXP',assign_station_in) > 0 then
    update tt_WJK_LEFT_remain_ticket
    set tt_WJK_LEFT_remain_ticket.train_code = 'T97'
    where tt_WJK_LEFT_remain_ticket.train_code = 'Q97';
  end if;

  SET ns_train_date = DATE_FORMAT(TIMESTAMPADD(day,9,CURRENT_TIMESTAMP),'%Y%m%d');

  -- IMPORTANT ADD INDEX
  select tt_WJK_LEFT_remain_ticket.station_telecode,
  tt_WJK_LEFT_remain_ticket.train_no,
  tt_WJK_LEFT_remain_ticket.train_code,
  tt_WJK_LEFT_remain_ticket.train_date,
  tt_WJK_LEFT_remain_ticket.start_station_name,
  tt_WJK_LEFT_remain_ticket.end_station_name,
  tt_WJK_LEFT_remain_ticket.limit_station_name,
  tt_WJK_LEFT_remain_ticket.direction_name,
  tt_WJK_LEFT_remain_ticket.arrive_time,
  tt_WJK_LEFT_remain_ticket.start_time,
  tt_WJK_LEFT_remain_ticket.yz_count,
  tt_WJK_LEFT_remain_ticket.yw_count,
  tt_WJK_LEFT_remain_ticket.rz_count,
  tt_WJK_LEFT_remain_ticket.rw_count,
  tt_WJK_LEFT_remain_ticket.wz_count
  from tt_WJK_LEFT_remain_ticket
  order by tt_WJK_LEFT_remain_ticket.station_telecode,tt_WJK_LEFT_remain_ticket.train_date,tt_WJK_LEFT_remain_ticket.train_no,
    tt_WJK_LEFT_remain_ticket.direction_name,tt_WJK_LEFT_remain_ticket.limit_station_name;

  SET SWP_Ret_Value = 0;
END ;;
