CREATE DEFINER=`root`@`%` PROCEDURE `CJ30_train`(train_date CHAR(8),
  INOUT train_no CHAR(12) ,
  INOUT station CHAR(10) ,
  out_flag TINYINT UNSIGNED,INOUT SWP_Ret_Value INT)
BEGIN
  DECLARE train_code CHAR(8);
  DECLARE subbureau_code CHAR(2);
  DECLARE double_id CHAR(1);
  DECLARE schema_id CHAR(1);
  DECLARE start_date CHAR(8);
  DECLARE stop_date CHAR(8);
  DECLARE running_rule INT;
  DECLARE running_style TINYINT UNSIGNED;
  DECLARE running_true INT;
  DECLARE day_diff INT;
  DECLARE date_after INT;
  DECLARE board_train_code CHAR(8);
  DECLARE station_name CHAR(10);
  DECLARE station_telecode CHAR(3);
  DECLARE station_code CHAR(5);
  DECLARE station_no CHAR(2);
  DECLARE return_code INT;
  DECLARE l_count INT;
  DECLARE max_station_no CHAR(2);
  DECLARE min_station_no CHAR(2);
  IF out_flag is null then
    set out_flag = 0;
  END IF;

  if out_flag=2 then
    select '00==begin cj30_train';
  end if;
  SET running_true = -1;
  SET return_code = LENGTH(ltrim(rtrim(station)));
  IF return_code = 3 then

    SET station_telecode = upper(ltrim(rtrim(station)));
    select   station_dictionary.station_name
    INTO station_name
    FROM basic.station_dictionary
    WHERE station_dictionary.station_telecode = station_telecode
    AND station_dictionary.start_date <= train_date
    AND station_dictionary.stop_date >= train_date;
  ELSE
    IF return_code = 5 then

      SET station_code = ltrim(rtrim(station));


      select   station_dictionary.station_name
      INTO station_name
      FROM basic.station_dictionary
      WHERE station_dictionary.station_code = station_code
      AND station_dictionary.start_date <= train_date
      AND station_dictionary.stop_date >= train_date;
    ELSE
      IF return_code = 7 then

        SET station_code = INSERT(ltrim(rtrim(station)),6,2,'');


        select   station_dictionary.station_name
        INTO station_name
        FROM basic.station_dictionary
        WHERE station_dictionary.station_code = station_code
        AND station_dictionary.start_date <= train_date
        AND station_dictionary.stop_date >= train_date;
      ELSE
        SET station_name = station;
      end if;
    end if;
  end if;

  ERROROUT:loop
  IF station_name IS NULL then
    leave ERROROUT;
  end if;
  select   max(stop_time.station_no)
  INTO max_station_no
  FROM basic.stop_time
  WHERE stop_time.train_no = train_no;
  if out_flag=2 then
    select '4==',max_station_no,train_no;
  end if;
  IF max_station_no IS NULL then
    leave ERROROUT;
  end if;

  select   min(stop_time.station_no)
  INTO min_station_no
  FROM basic.stop_time
  WHERE stop_time.train_no = train_no;
  if out_flag=2 THEN
    select '5===',min_station_no,train_no;
  end if;
  IF min_station_no IS NULL then
    leave ERROROUT;
  end if;

  select   stop_time.station_no
  INTO station_no
  FROM basic.stop_time
  WHERE stop_time.train_no = train_no
  AND stop_time.station_name = station_name;
  if out_flag=2 THEN
    select '6===',station_no,train_no,station_name;
  end if;
  IF station_no IS NULL then
    leave ERROROUT;
  end if;

  IF max_station_no = station_no then

    select   stop_time.station_name
    INTO station_name
    FROM basic.stop_time
    WHERE stop_time.train_no = train_no
    AND stop_time.station_no = min_station_no;
  end if;

  SET station = station_name;


  SET train_code = SUBSTRING(train_no,3,8);
  SET subbureau_code = SUBSTRING(train_no,1,2);
  SET double_id = SUBSTRING(train_no,11,1);
  SET schema_id = SUBSTRING(train_no,12,1);
  SET running_true = -1;
  --- IMPORTANT   make sure the train_code format and use trim instead of SUBSTRING */
  set train_code = trim(LEADING '0' FROM train_code);
  set train_code = ltrim(rtrim(train_code));

  /* WHILE SUBSTRING(train_code,1,1) = '0' DO */
  /*   SET train_code = ltrim(rtrim(INSERT(train_code,1,1,''))); */
  /* END WHILE; */
  /* SET train_code = ltrim(rtrim(train_code)); */

  if out_flag=2 then
    select '3====',train_code,subbureau_code,double_id,schema_id;
  end if;

  select   train_dir.running_style,
  train_dir.running_rule
  INTO running_style,
  running_rule
  FROM basic.train_dir
  WHERE train_dir.train_code = train_code
  AND train_dir.subbureau_code = subbureau_code
  AND train_dir.double_id = double_id
  AND train_dir.schema_id = schema_id;
  IF ROW_COUNT() = 1 then
    select   IFNULL(stop_time.day_difference,0),
    stop_time.station_train_code,
    stop_time.start_date,
    stop_time.stop_date
    INTO day_diff,
    board_train_code,
    start_date,
    stop_date
    FROM basic.stop_time
    WHERE stop_time.train_no = train_no
    AND stop_time.station_name = station_name;
    SET train_date = DATE_FORMAT(TIMESTAMPADD(DAY,0 -day_diff,train_date),'%Y%m%d');
    SET date_after = TIMESTAMPDIFF(DAY,CAST(start_date AS DATETIME),CAST(train_date AS DATETIME));
    if out_flag=2 then
      select '1===',train_date,start_date,stop_date,running_true,running_rule,date_after,running_style,power(2,(date_after%running_style)),running_rule & power(2,(date_after%running_style));
    end if;
    IF train_date < start_date or train_date > stop_date then
      SET running_true = 0;
    ELSE
      IF running_style <> 1 then
        SET running_true = running_rule & power(2,(date_after%running_style));
      ELSE
        SET running_true = 1;
      end if;
    end if;
  end if;
  leave ERROROUT;
  end loop ERROROUT;
  if out_flag=2 then
    select '2===',running_true;
  end if;
  IF running_true < 1 then
    SET train_no = '000000000000';
    SET return_code = -1;
  ELSE
    SET return_code = 1;
  end if;
  IF out_flag = 1 then
    SELECT train_no,station;
  end if;
  SET SWP_Ret_Value = return_code;
END
