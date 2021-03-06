delimiter ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CJ30_train_code`(train_date CHAR(8),
	INOUT train_no CHAR(12) ,
	INOUT station CHAR(10) ,  
	out_flag TINYINT UNSIGNED,
	inner_code CHAR(3),INOUT SWP_Ret_Value INT)
SWL_return:
BEGIN
   DECLARE t_train_no CHAR(12); 
   DECLARE t_station_name CHAR(10);
   DECLARE station_telecode CHAR(3); 
   DECLARE station_code CHAR(5);
   DECLARE station_name CHAR(10); 
   DECLARE return_code INT;
   DECLARE l_match_string CHAR(12);
   DECLARE train_code CHAR(8);


   DECLARE NO_DATA INT DEFAULT 0;
   DECLARE cursor_no int ;
   DECLARE SWV_CurNum INT DEFAULT 0;
   
   
	  
   DECLARE CONTINUE HANDLER FOR NOT FOUND SET NO_DATA = 2;
		 
   
   
   IF out_flag is null then
      set out_flag = 0;
   END IF;
   IF LENGTH(ltrim(rtrim(train_date))) < 8 then 
      LEAVE SWL_return;
   end if;
   SET train_code = ltrim(rtrim(train_no));
   SET train_no = '000000000000';
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
            
            select   station_name.station_name 
			INTO station_name 
			FROM station_dictionary 
			WHERE station_name.station_code = station_code
            	AND station_name.start_date <= train_date
            	AND station_name.stop_date >= train_date;
         ELSE
            SET station_name = station;
         end if;
      end if;
   end if;
   
   IF station_name IS NULL then
      SET SWP_Ret_Value = -1;
      LEAVE SWL_return;
   end if;
	
   SET l_match_string = CONCAT('__',right(CONCAT('00000000',ltrim(rtrim(train_code))),8),'__');
   
	set NO_DATA=0;
   IF return_code = 1 then
     begin
		
	   DECLARE get_train CURSOR FOR 
	   SELECT stop_time.train_no,
	   	stop_time.station_name 
	   FROM basic.stop_time
	   WHERE stop_time.train_no LIKE l_match_string
	   	AND stop_time.start_date <= DATE_FORMAT(TIMESTAMPADD(DAY,0 -cast(stop_time.day_difference as signed),train_date),'%Y%m%d')
	  	 AND stop_time.stop_date >= DATE_FORMAT(TIMESTAMPADD(DAY,0 -cast(stop_time.day_difference as signed),train_date),'%Y%m%d')
	  	 AND station_name IN
		 	(SELECT start_station_name
	      		FROM basic.train_dir
	      		WHERE train_dir.train_code = train_code
	      		AND	train_dir.start_date <= DATE_FORMAT(TIMESTAMPADD(DAY,0+5,train_date),'%Y%m%d')
	      		AND  train_dir.stop_date >= DATE_FORMAT(TIMESTAMPADD(DAY,0 -5,train_date),'%Y%m%d')
			)
	   ORDER BY stop_time.stop_date DESC,stop_time.station_no ASC,stop_time.train_no ASC;
	   OPEN get_train;
		FETCH get_train INTO t_train_no,t_station_name;
		SWL_Label:loop
	   WHILE NO_DATA = 0 DO
			
		  CALL CJ30_train(train_date,t_train_no,t_station_name,0,@SWV_RetVal);
		  
		  SET train_no = t_train_no;
		  SET station = t_station_name;
		  IF t_train_no <> '000000000000' then
			 LEAVE SWL_Label;
		  end if;
		  
		  
		  FETCH get_train INTO t_train_no,t_station_name;
		
		  
	    
	   END WHILE;
	   leave SWL_Label;
	   end loop SWL_Label;
		CLOSE get_train;
		
	 end;
   ELSE
	 begin
     
	   DECLARE get_train CURSOR  FOR 
	   SELECT stop_time.train_no,
	   	stop_time.station_name 
	   FROM basic.stop_time
	   WHERE ((stop_time.train_no LIKE l_match_string)
				
	   		OR (stop_time.station_train_code = train_code))
	   	AND stop_time.station_name = station_name
	   	AND stop_time.start_date <= DATE_FORMAT(TIMESTAMPADD(DAY,0 -cast(stop_time.day_difference as signed),train_date),'%Y%m%d')
	   	AND stop_time.stop_date >= DATE_FORMAT(TIMESTAMPADD(DAY,0 -cast(stop_time.day_difference as signed),train_date),'%Y%m%d')
	    ORDER BY stop_time.stop_date DESC,stop_time.station_no ASC,stop_time.train_no ASC;
		
	    OPEN get_train;
		FETCH get_train INTO t_train_no,t_station_name;
		SWL_Label:loop
		   WHILE NO_DATA = 0 DO
				
			  CALL CJ30_train(train_date,t_train_no,t_station_name,0,@SWV_RetVal);
			  
			  SET train_no = t_train_no;
			  SET station = t_station_name;
			  IF t_train_no <> '000000000000' then
				 LEAVE SWL_Label;
			  end if;
			  
			  
			  FETCH get_train INTO t_train_no,t_station_name;
			
			  
			
		   END WHILE;
	    leave SWL_Label;
	    end loop SWL_Label;
		CLOSE get_train;
	 end;
   end if;
     
	
   

   IF out_flag = 1 then
      SELECT train_no,station;
   end if;
   IF train_no = '000000000000' then
      SET return_code = -1;
   ELSE 
      SET return_code = 1;
   end if;
   SET SWP_Ret_Value = return_code;
END
;;
delimiter ;

