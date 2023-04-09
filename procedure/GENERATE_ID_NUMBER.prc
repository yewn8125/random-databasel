CREATE OR REPLACE PROCEDURE GENERATE_ID_NUMBER(NUM_OF_IDS IN NUMBER)
/*******************************************************************
  @AUTHOR：YANYUN
  @CREATE_DATE:2023-03-25
  @DESCRIPTION:改存储过程用于随机生成中国大陆居民身份证号码，输入生成
  条数（NUM_OF_IDS），插入至身份证号码临时表（ID_NUMBER_TEMP_TABLE）中
  @MODIFICATION_HISTORY：
         M0.AUTHOR_CREATE-DATE_DESCRIPTION 20230325
  ********************************************************************/
 AS
  ID_NUMBER       VARCHAR2(20);
  REGION_CODE     VARCHAR2(20);
  BIRTHDAY        VARCHAR2(20);
  CHECK_CODE      VARCHAR2(20);
  SEQUENCE_NUMBER VARCHAR2(20);
  LOG_STEP        INTEGER;
  PROCNAME        VARCHAR2(80);
  LOG_MESSAGE     VARCHAR2(1000);
BEGIN
  LOG_STEP    := 0;
  PROCNAME    := UPPER('generate_id_number');
  LOG_MESSAGE := '参数初始化处理';
  SP_RANDOM_LOG(LOG_STEP, PROCNAME, SYSTIMESTAMP, LOG_MESSAGE);

  -- 清空身份证号码临时表
  DELETE FROM ID_NUMBER_TEMP_TABLE;

  LOG_STEP    := 1;
  PROCNAME    := UPPER('generate_id_number');
  LOG_MESSAGE := '清空身份证号码临时表完成';
  SP_RANDOM_LOG(LOG_STEP, PROCNAME, SYSTIMESTAMP, LOG_MESSAGE);

  FOR I IN 1 .. NUM_OF_IDS LOOP
    -- 随机取自中国省市区县代码表
    SELECT TO_CHAR(REGION_CODE)
      INTO REGION_CODE
      FROM (SELECT REGION_CODE
              FROM CHINA_REGION_CODE
             ORDER BY DBMS_RANDOM.VALUE())
     WHERE ROWNUM = 1;
  
    -- 生成随机出生日期
    BIRTHDAY := TO_CHAR(TO_DATE('1937-01-01', 'YYYY-MM-DD') +
                        DBMS_RANDOM.VALUE(1, 31031),
                        'YYYYMMDD');
  
    -- 生成顺序码
    SEQUENCE_NUMBER := TO_CHAR(MOD(DBMS_RANDOM.VALUE(1, 999), 1000),
                               'FM000');
  
    -- 生成校验码
    CHECK_CODE := TO_CHAR(DBMS_RANDOM.VALUE(1, 10), 'FM00');
    CASE CHECK_CODE
      WHEN '01' THEN
        CHECK_CODE := '1';
      WHEN '02' THEN
        CHECK_CODE := '2';
      WHEN '03' THEN
        CHECK_CODE := '3';
      WHEN '04' THEN
        CHECK_CODE := '4';
      WHEN '05' THEN
        CHECK_CODE := '5';
      WHEN '06' THEN
        CHECK_CODE := '6';
      WHEN '07' THEN
        CHECK_CODE := '7';
      WHEN '08' THEN
        CHECK_CODE := '8';
      WHEN '09' THEN
        CHECK_CODE := '9';
      ELSE
        CHECK_CODE := 'X';
    END CASE;
  
    -- 拼接号码
    ID_NUMBER := TO_CHAR(REGION_CODE || BIRTHDAY || SEQUENCE_NUMBER ||
                         CHECK_CODE);
  
    -- 将生成的身份证号码插入到临时表中
    INSERT INTO ID_NUMBER_TEMP_TABLE (ID_NUMBER) VALUES (ID_NUMBER);
    COMMIT;
  END LOOP;

  LOG_STEP    := 2;
  PROCNAME    := UPPER('generate_id_number');
  LOG_MESSAGE := '身份证号码已插入到临时表中，随机生成了' || NUM_OF_IDS || '条数据';
  SP_RANDOM_LOG(LOG_STEP, PROCNAME, SYSTIMESTAMP, LOG_MESSAGE);

EXCEPTION
  WHEN OTHERS THEN
    -- 记录异常信息
    LOG_STEP    := 2;
    PROCNAME    := UPPER('generate_id_number');
    LOG_MESSAGE := '发生异常，异常信息为：' || TO_CHAR(SQLCODE) || TO_CHAR(SQLERRM);
    SP_RANDOM_LOG(LOG_STEP, PROCNAME, SYSTIMESTAMP, LOG_MESSAGE);
    RAISE;
  
END;
/
