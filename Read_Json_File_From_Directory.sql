
/***************************************************************************************
  Import Json File from Directory
 ***************************************************************************************

 --------------------------------------------------------------------------------------------------------------------------------------------------------------
  run as system user;
 -------------------------------------------------------------------------------------------------------------------------------------------------------------
  grant create table to exceldemo;
   
 --------------------------------------------------------------------------------------------------------------------------------------------------------------
 run as exceldemo user;
 -------------------------------------------------------------------------------------------------------------------------------------------------------------
  drop table exceldemo.filetest;

  create table filetest(filetestid number(20,0), clobfile_data clob, blobfile_data blob, filename varchar2(250));

 -------------------------------------------------------------------------------------------------------------------------------------------------------------
  run as system user;
 -------------------------------------------------------------------------------------------------------------------------------------------------------------
  grant select, update, delete, insert on exceldemo.filetest to exceldemo;
 
  grant read on directory excel_demo_dir to exceldemo;
 
 
 select * from dba_directories;
 
 
  select value from nls_database_parameters where parameter = 'NLS_CHARACTERSET';
 
--------------------------------------------------------------------------------------------------------------------------------------------------------------
 run as exceldemo user;
 -------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

declare
   v_bfile BFILE := BFILENAME('EXCEL_DEMO_DIR', 'us_food_restaurants_compressed.json');
   v_clob clob;
   v_source_offset  integer := 1;
   v_destination_offset  integer := 1;
   v_language_context integer := dbms_lob.default_lang_ctx;
   v_warning_message integer;
   v_bfile_size INTEGER;
BEGIN

         If dbms_lob.fileexists(v_bfile) = 1 AND NOT dbms_lob.isopen(v_bfile) = 1 Then
                      dbms_lob.open(v_bfile,   dbms_lob.file_readonly);
                      v_bfile_size :=  dbms_lob.getlength(v_bfile);
                      dbms_output.put_line('v_bfile_size: '||v_bfile_size);       
          end if;

        --  truncate table filetest;
        -- delete from filetest where filename = 'us_food_restaurants_compressed';
          insert into filetest (filetestid, clobfile_data, filename) values(2, EMPTY_CLOB(),  'us_food_restaurants_compressed');
       
          select clobfile_data into v_clob from filetest where filename = 'us_food_restaurants_compressed';
       
          dbms_lob.open(v_clob,  dbms_lob.lob_readwrite);
          
          dbms_lob.loadclobfromfile(v_clob, 
                                        v_bfile, 
                                        dbms_lob.lobmaxsize, 
                                        v_destination_offset, 
                                        v_source_offset, 
                                        NLS_CHARSET_ID('AL32UTF8'), 
                                        v_language_context, 
                                        v_warning_message);         
        
         if v_warning_message = dbms_lob.warn_inconvertible_char then
                    dbms_output.put_line('Warning, Oracle had problems converting some of the characters. Verify that you are using the correct NLS_CHARSET_ID characterset.');
         end if;        
         
         dbms_output.put_line('v_clob: '||dbms_lob.getlength(v_clob) );
          
         dbms_lob.close(v_clob);
         dbms_lob.close(v_bfile);
         
        -- if v_bfile_size = dbms_lob.getlength(v_clob) then
                    commit;
          --          dbms_output.put_line('File insert succeeded');
        -- else
        --            rollback;
         --            dbms_output.put_line('File insert failed');
         --           raise  dbms_lob.operation_failed;
        -- end if;           
     
END;
