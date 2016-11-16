CREATE TABLE AT_POOL 
(
  LOCATION_CODE NUMBER NOT NULL 
, POOL_CODE NUMBER NOT NULL 
, LOCATION_LEVEL_CODE_UPPER NUMBER NOT NULL 
, LOCATION_LEVEL_CODE_LOWER NUMBER NOT NULL 
, DATE_ZONE_CREATED_IN_DB DATE NOT NULL 
, NOTES VARCHAR(1999) 
, DOCUMENT_CODE_ZONE_PIC NUMBER 
, DISPLAY_NAME VARCHAR2(50) NOT NULL 
, CONSTRAINT AT_POOL_PK PRIMARY KEY 
  (
    LOCATION_CODE 
  , POOL_CODE 
  )
  ENABLE 
);

COMMENT ON COLUMN AT_POOL.LOCATION_CODE IS 'Primary Key. Foreign Key to Location Code of a Project';

COMMENT ON COLUMN AT_POOL.POOL_CODE IS 'Primary Key. Foreign Key to Pool Code';

COMMENT ON COLUMN AT_POOL.LOCATION_LEVEL_CODE_UPPER IS 'Upper Boundary of the Pool';

COMMENT ON COLUMN AT_POOL.LOCATION_LEVEL_CODE_LOWER IS 'Lower Boundary of the Pool';

COMMENT ON COLUMN AT_POOL.DATE_ZONE_CREATED_IN_DB IS 'Date this record was created in the database';

COMMENT ON COLUMN AT_POOL.NOTES IS 'Comments and notes about the Zone';

COMMENT ON COLUMN AT_POOL.DOCUMENT_CODE_ZONE_PIC IS 'Link to a zone picture';

COMMENT ON COLUMN AT_POOL.DISPLAY_NAME IS 'A short name to display the zone in maps and charts';


CREATE TABLE AT_POOL_TYPES 
(
  POOL_CODE NUMBER NOT NULL 
, OFFICE_CODE NUMBER NOT NULL 
, POOL_ID VARCHAR2(55) NOT NULL 
, DATE_CREATED DATE NOT NULL 
, CONSTRAINT AT_POOL_TYPES_PK PRIMARY KEY 
  (
    POOL_CODE 
  )
  ENABLE 
);

COMMENT ON COLUMN AT_POOL_TYPES.POOL_CODE IS 'Primary Key for the Pool Type';

COMMENT ON COLUMN AT_POOL_TYPES.OFFICE_CODE IS 'Foreign Key to office code';

COMMENT ON COLUMN AT_POOL_TYPES.POOL_ID IS 'The human readable text of the pool (i.e. Flood Pool)';

COMMENT ON COLUMN AT_POOL_TYPES.DATE_CREATED IS 'Date the record was created';



ALTER TABLE AT_POOL
ADD CONSTRAINT AT_POOL_FK1 FOREIGN KEY
(
  LOCATION_CODE 
)
REFERENCES AT_PHYSICAL_LOCATION
(
  LOCATION_CODE 
)
ENABLE;

ALTER TABLE AT_POOL
ADD CONSTRAINT AT_POOL_FK2 FOREIGN KEY
(
  POOL_CODE 
)
REFERENCES AT_POOL_TYPES
(
  POOL_CODE 
)
ENABLE;

ALTER TABLE AT_POOL
ADD CONSTRAINT AT_POOL_FK3 FOREIGN KEY
(
  LOCATION_LEVEL_CODE_UPPER 
)
REFERENCES AT_LOCATION_LEVEL
(
  LOCATION_LEVEL_CODE 
)
ENABLE;

ALTER TABLE AT_POOL
ADD CONSTRAINT AT_POOL_FK4 FOREIGN KEY
(
  LOCATION_LEVEL_CODE_LOWER 
)
REFERENCES AT_LOCATION_LEVEL
(
  LOCATION_LEVEL_CODE 
)
ENABLE;

ALTER TABLE AT_POOL
ADD CONSTRAINT AT_POOL_FK5 FOREIGN KEY
(
  DOCUMENT_CODE_ZONE_PIC 
)
REFERENCES AT_DOCUMENT
(
  DOCUMENT_CODE 
)
ENABLE;


ALTER TABLE AT_POOL_TYPES
ADD CONSTRAINT AT_POOL_TYPES_FK1 FOREIGN KEY
(
  OFFICE_CODE 
)
REFERENCES CWMS_OFFICE
(
  OFFICE_CODE 
)
ENABLE;

alter table at_pool_types add notes VARCHAR2(199);


CREATE or REPLACE VIEW AV_POOL AS 
SELECT l.db_Office_id
     , l.bounding_office_id
     , l.location_id
     , l.unit_System
     , p.*
     , ll1.location_level_id location_level_id_upper
     , ll2.location_level_id location_level_id_lower
  FROM at_pool p
     , av_loc l
     , av_location_level ll1
     , av_location_level ll2
 WHERE p.location_code = l.location_code
   AND l.unit_system = 'EN'
   AND p.locatioN_level_code_upper  = ll1.location_leveL_code
   AND p.location_level_code_lower  = ll2.location_level_code
   AND ll1.unit_system = 'EN'
   AND ll2.unit_system = 'EN'
   ;
   
   --SELECT * FROM av_location_level
   
CREATE PUBLIC SYNONYM cwms_v_pool FOR av_pool;   

CREATE or REPLACE VIEW av_pool_types AS 
SELECT pt.* 
     , o.office_id db_office_id
  FROM at_pool_types pt
      , cwms_v_office o
  WHERE pt.office_code = o.office_code;
  
CREATE PUBLIC SYNONYM cwms_v_pool_types  FOR av_pool_types;



INSERT INTO at_pool_types (pool_code, office_code, pool_id, date_created, notes)
 VALUES
  (1, 53, 'Flood Pool', SYSDATE, 'The Flood Pool of the Project');

INSERT INTO at_pool_types (pool_code, office_code, pool_id, date_created, notes)
 VALUES
  (2, 53, 'Conservation Pool', SYSDATE, 'The Conservation Pool of the Project');

INSERT INTO at_pool_types (pool_code, office_code, pool_id, date_created, notes)
 VALUES
  (3, 53, 'Power Pool', SYSDATE, 'The Power Pool of the Project');
  
INSERT INTO at_pool_types (pool_code, office_code, pool_id, date_created, notes)
 VALUES
  (4, 53, 'Dead Pool', SYSDATE, 'The Dead Pool of the Project');  

INSERT INTO at_pool_types (pool_code, office_code, pool_id, date_created, notes)
 VALUES
  (5, 53, 'Navigation Pool', SYSDATE, 'The Navigation Pool of the Project');  

INSERT INTO at_pool_types (pool_code, office_code, pool_id, date_created, notes)
 VALUES
  (6, 53, 'Project Pool', SYSDATE, 'The Total Project Pool, from the top of the Dead Pool to the Top of Dam');  

INSERT INTO at_pool_types (pool_code, office_code, pool_id, date_created, notes)
 VALUES
  (7, 53, 'Surcharge Pool', SYSDATE, 'The Surcharge Pool, above the flood pool');  

/*
SELECT * FROM cwms_v_pool_types
*/

/* SQL to test APIs
*/

/*
BEGIN
cwms_loc.store_pool_type ( p_pool_id      => 'NAE test 2'
                         , p_notes        => 'Test of the API Update 6'
                         , p_db_office_id => 'NAE'
                         );
COMMIT;
--SELECT * FROM cwms_v_pool_types

END;
*/
/*
SELECT * FROM cwms_v_loc WHERE locatioN_id = 'UVD'

SELECT * FROM cwms_v_location_level WHERE locatioN_code = 8177021
*/

/*
BEGIN

cwms_loc.store_pool (p_location_code               => 8177021
                       , p_pool_code                  => 1
                       , p_location_level_code_upper  => 21080021
                       , p_location_level_code_lower  => 23419021
                       , p_notes                      => 'Test of API 2'
                       , p_document_code_zone_pic     => NULL
                       , p_display_name               => 'test of display name 2'
                       );
  
  COMMIT;                     
END;
*/
/*
BEGIN
cwms_loc.delete_pool(8177021, 1);
END;

SELECT * FROM cwms_v_pool

SELECT * FROM at_pool_types

DELETE at_pool_types WHERE office_code = 21

SELECT * FROM cwms_v_office WHERE office_id = 'NAE'

INSERT INTO at_Pool_types  (POOL_CODE, OFFICE_CODE, POOL_ID, DATE_CREATED, NOTES)
       VALUES ( cwms_seq.nextval
               , 21
               , 'TEST Pool'
               , SYSDATE
               , 'Test JDK'
               );
               
               SELECT * FROM at_pool_types
               

               SELECT * FROM cwms_v_pool_types


     MERGE INTO at_pool_types pt
       USING dual
        ON (pt.pool_id = 'Test JDK 3' AND pt.office_code = 21)
      WHEN MATCHED THEN
       UPDATE SET pt.notes = 'Test JDK 3'
      WHEN NOT MATCHED THEN
      INSERT (pt.POOL_CODE, pt.OFFICE_CODE, pt.POOL_ID, pt.DATE_CREATED, pt.NOTES)
       VALUES ( cwms_seq.nextval
               , 21
               , 'TEST Pool 3'
               , SYSDATE
               , 'Test JDK 3'
               );

*/