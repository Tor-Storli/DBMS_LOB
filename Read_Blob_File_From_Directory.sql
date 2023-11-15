
/***************************************************************************************
  Import Excel workbook from Directory
 ***************************************************************************************/
 /*
 
  run as system user;
 ---------------------------
  grant create table to exceldemo;
  
  create table exceldemo.filetest(filetestid number(20,0), clobfile_data clob, blobfile_data blob, filename varchar2(250));
  
  grant select, update, delete, insert on exceldemo.filetest to exceldemo;
 
   grant read on directory excel_demo_dir to exceldemo;
 
 
 */
 
DECLARE

   v_bfile BFILE := bfilename('EXCEL_DEMO_DIR', 'ABBV_06112022081428.xlsx');
   v_blob BLOB;
   v_bfile_size INTEGER;
   v_source_offset  INTEGER := 1;
   v_destination_offset  INTEGER := 1;

   
BEGIN

          If dbms_lob.fileexists(v_bfile) = 1 AND NOT dbms_lob.isopen(v_bfile) = 1 Then
                      v_bfile_size :=  dbms_lob.getlength(v_bfile);
                      dbms_lob.open(v_bfile,   dbms_lob.file_readonly);
                      dbms_output.put_line('v_bfile_size: '||v_bfile_size);       
          end if;
          
       --   delete  from  filetestb where filename =  'ABBV_06112022081428';      
         
          insert into filetest (filetestid, blobfile_data, filename) values(2, empty_blob(),  'ABBV_06112022081428');
          
          select blobfile_data into v_blob from filetest where filename = 'ABBV_06112022081428';
          
          dbms_lob.open(v_blob,  dbms_lob.lob_readwrite);
          
          dbms_lob.loadblobfromfile(v_blob, v_bfile, dbms_lob.lobmaxsize, v_destination_offset, v_source_offset);
           
         dbms_output.put_line('v_blob: '||dbms_lob.getlength(v_blob));       
               
         dbms_lob.close(v_blob);
         dbms_lob.close(v_bfile);
         
         if v_bfile_size = dbms_lob.getlength(v_blob) then
                    commit;
                    dbms_output.put_line('File insert succeeded');
        else
                   rollback;
                    dbms_output.put_line('File insert failed');
                   raise  dbms_lob.operation_failed;
         end if;           
          
END;